/*
 * VcardModel.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#include <belcard/belcard.hpp>
#include <QFileInfo>
#include <QImageReader>
#include <QtDebug>
#include <QUuid>

#include "../../app/App.hpp"
#include "../../app/paths/Paths.hpp"
#include "../../app/providers/AvatarProvider.hpp"
#include "../../Utils.hpp"
#include "../core/CoreManager.hpp"

#include "VcardModel.hpp"

#define VCARD_SCHEME "linphone-desktop:/"

using namespace std;

// =============================================================================

template<class T>
inline shared_ptr<T> findBelCardValue (const list<shared_ptr<T> > &list, const QString &value) {
  string match = ::Utils::qStringToLinphoneString(value);

  auto it = find_if(
      list.cbegin(), list.cend(), [&match](const shared_ptr<T> &entry) {
        return match == entry->getValue();
      }
    );

  if (it != list.cend())
    return *it;

  return nullptr;
}

inline shared_ptr<belcard::BelCardPhoto> findBelCardPhoto (const list<shared_ptr<belcard::BelCardPhoto> > &photos) {
  auto it = find_if(
      photos.cbegin(), photos.cend(), [](const shared_ptr<belcard::BelCardPhoto> &photo) {
        return !photo->getValue().compare(0, sizeof(VCARD_SCHEME) - 1, VCARD_SCHEME);
      }
    );

  if (it != photos.cend())
    return *it;

  return nullptr;
}

// -----------------------------------------------------------------------------

VcardModel::VcardModel (shared_ptr<linphone::Vcard> vcard) {
  Q_ASSERT(vcard != nullptr);
  mVcard = vcard;
}

VcardModel::~VcardModel () {
  // If it's a detached Vcard, the linked photo must be destroyed from fs.
  if (App::getInstance()->getEngine()->objectOwnership(this) != QQmlEngine::CppOwnership) {
    shared_ptr<belcard::BelCardPhoto> photo(findBelCardPhoto(mVcard->getVcard()->getPhotos()));
    if (!photo)
      return;

    QString imagePath(
      ::Utils::linphoneStringToQString(
        Paths::getAvatarsDirPath() +
        photo->getValue().substr(sizeof(VCARD_SCHEME) - 1)
      )
    );

    if (!QFile::remove(imagePath))
      qWarning() << QStringLiteral("Unable to remove `%1`.").arg(imagePath);

    qInfo() << QStringLiteral("Destroy detached vcard:") << this;
  } else
    qInfo() << QStringLiteral("Destroy attached vcard:") << this;
}

// -----------------------------------------------------------------------------

VcardModel *VcardModel::clone () const {
  shared_ptr<linphone::Vcard> vcard = mVcard->clone();
  Q_ASSERT(vcard != nullptr);
  Q_ASSERT(vcard->getVcard() != nullptr);

  VcardModel *vcardModel = new VcardModel(vcard);
  qInfo() << QStringLiteral("Clone vcard:") << this << vcardModel;

  return vcardModel;
}

// -----------------------------------------------------------------------------

QString VcardModel::getUsername () const {
  return ::Utils::linphoneStringToQString(mVcard->getFullName());
}

void VcardModel::setUsername (const QString &username) {
  if (username.length() == 0 || username == getUsername())
    return;

  mVcard->setFullName(::Utils::qStringToLinphoneString(username));
  emit vcardUpdated();
}

// -----------------------------------------------------------------------------

QString VcardModel::getAvatar () const {
  // Find desktop avatar.
  list<shared_ptr<belcard::BelCardPhoto> > photos = mVcard->getVcard()->getPhotos();
  shared_ptr<belcard::BelCardPhoto> photo = findBelCardPhoto(photos);

  // No path found.
  if (!photo)
    return QStringLiteral("");

  // Returns right path.
  return QStringLiteral("image://%1/%2").arg(AvatarProvider::PROVIDER_ID).arg(
    ::Utils::linphoneStringToQString(photo->getValue().substr(sizeof(VCARD_SCHEME) - 1))
  );
}

bool VcardModel::setAvatar (const QString &path) {
  // 1. Try to copy photo in avatars folder.
  QFile file(path);

  if (!file.exists() || QImageReader::imageFormat(path).size() == 0)
    return false;

  QFileInfo info(file);
  QString uuid = QUuid::createUuid().toString();
  QString fileId = QStringLiteral("%1.%2")
    .arg(uuid.mid(1, uuid.length() - 2)) // Remove `{}`.
    .arg(info.suffix());

  QString dest = ::Utils::linphoneStringToQString(Paths::getAvatarsDirPath()) + fileId;

  if (!file.copy(dest))
    return false;

  qInfo() << QStringLiteral("Update avatar of `%1`. (path=%2)").arg(getUsername()).arg(dest);

  // 2. Edit vcard.
  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  list<shared_ptr<belcard::BelCardPhoto> > photos = belcard->getPhotos();

  // 3. Remove oldest photo.
  shared_ptr<belcard::BelCardPhoto> oldPhoto = findBelCardPhoto(photos);
  if (oldPhoto) {
    QString imagePath(
      ::Utils::linphoneStringToQString(
        Paths::getAvatarsDirPath() + oldPhoto->getValue().substr(sizeof(VCARD_SCHEME) - 1)
      )
    );

    if (!QFile::remove(imagePath))
      qWarning() << QStringLiteral("Unable to remove `%1`.").arg(imagePath);
    belcard->removePhoto(oldPhoto);
  }

  // 4. Update.
  shared_ptr<belcard::BelCardPhoto> photo = belcard::BelCardGeneric::create<belcard::BelCardPhoto>();
  photo->setValue(VCARD_SCHEME + ::Utils::qStringToLinphoneString(fileId));

  if (!belcard->addPhoto(photo))
    return false;

  emit vcardUpdated();
  return true;
}

// -----------------------------------------------------------------------------

inline shared_ptr<belcard::BelCardAddress> getOrCreateBelCardAddress (shared_ptr<belcard::BelCard> belcard) {
  list<shared_ptr<belcard::BelCardAddress> > addresses = belcard->getAddresses();
  shared_ptr<belcard::BelCardAddress> address;

  if (addresses.empty()) {
    address = belcard::BelCardGeneric::create<belcard::BelCardAddress>();
    if (!belcard->addAddress(address))
      qWarning() << "Unable to create a new address on vcard.";
  } else
    address = addresses.front();

  return address;
}

QVariantMap VcardModel::getAddress () const {
  list<shared_ptr<belcard::BelCardAddress> > addresses = mVcard->getVcard()->getAddresses();
  QVariantMap map;

  if (addresses.empty())
    return map;

  shared_ptr<belcard::BelCardAddress> address = addresses.front();
  map["street"] = ::Utils::linphoneStringToQString(address->getStreet());
  map["locality"] = ::Utils::linphoneStringToQString(address->getLocality());
  map["postalCode"] = ::Utils::linphoneStringToQString(address->getPostalCode());
  map["country"] = ::Utils::linphoneStringToQString(address->getCountry());

  return map;
}

void VcardModel::setStreet (const QString &street) {
  shared_ptr<belcard::BelCardAddress> address = getOrCreateBelCardAddress(mVcard->getVcard());
  address->setStreet(::Utils::qStringToLinphoneString(street));
  emit vcardUpdated();
}

void VcardModel::setLocality (const QString &locality) {
  shared_ptr<belcard::BelCardAddress> address = getOrCreateBelCardAddress(mVcard->getVcard());
  address->setLocality(::Utils::qStringToLinphoneString(locality));
  emit vcardUpdated();
}

void VcardModel::setPostalCode (const QString &postalCode) {
  shared_ptr<belcard::BelCardAddress> address = getOrCreateBelCardAddress(mVcard->getVcard());
  address->setPostalCode(::Utils::qStringToLinphoneString(postalCode));
  emit vcardUpdated();
}

void VcardModel::setCountry (const QString &country) {
  shared_ptr<belcard::BelCardAddress> address = getOrCreateBelCardAddress(mVcard->getVcard());
  address->setCountry(::Utils::qStringToLinphoneString(country));
  emit vcardUpdated();
}

// -----------------------------------------------------------------------------

QVariantList VcardModel::getSipAddresses () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  QVariantList list;

  for (const auto &address : mVcard->getVcard()->getImpp()) {
    string value = address->getValue();
    shared_ptr<linphone::Address> linphoneAddress = core->createAddress(value);

    if (linphoneAddress)
      list.append(::Utils::linphoneStringToQString(linphoneAddress->asStringUriOnly()));
  }

  return list;
}

bool VcardModel::addSipAddress (const QString &sipAddress) {
  // Check sip address format.
  shared_ptr<linphone::Address> linphoneAddress = CoreManager::getInstance()->getCore()->interpretUrl(
      ::Utils::qStringToLinphoneString(sipAddress)
    );

  if (!linphoneAddress) {
    qWarning() << QStringLiteral("Unable to add invalid sip address on vcard: `%1`.").arg(sipAddress);
    return false;
  }

  // Add sip address in belcard.
  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  shared_ptr<belcard::BelCardImpp> value = belcard::BelCardGeneric::create<belcard::BelCardImpp>();
  value->setValue(linphoneAddress->asStringUriOnly());

  qInfo() << QStringLiteral("Add new sip address on vcard: `%1`.").arg(sipAddress);

  if (!belcard->addImpp(value)) {
    qWarning() << QStringLiteral("Unable to add sip address on vcard: `%1`.").arg(sipAddress);
    return false;
  }

  emit vcardUpdated();
  return true;
}

void VcardModel::removeSipAddress (const QString &sipAddress) {
  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  list<shared_ptr<belcard::BelCardImpp> > addresses = belcard->getImpp();
  shared_ptr<belcard::BelCardImpp> value = findBelCardValue(addresses, sipAddress);

  if (!value) {
    qWarning() << QStringLiteral("Unable to remove sip address on vcard: `%1`.").arg(sipAddress);
    return;
  }

  if (addresses.size() == 1) {
    qWarning() << QStringLiteral("Unable to remove the only existing sip address on vcard: `%1`.")
      .arg(sipAddress);
    return;
  }

  qInfo() << QStringLiteral("Remove sip address on vcard: `%1`.").arg(sipAddress);
  belcard->removeImpp(value);

  emit vcardUpdated();
}

bool VcardModel::updateSipAddress (const QString &oldSipAddress, const QString &sipAddress) {
  if (oldSipAddress == sipAddress || !addSipAddress(sipAddress))
    return false;

  removeSipAddress(oldSipAddress);

  return true;
}

// -----------------------------------------------------------------------------

QVariantList VcardModel::getCompanies () const {
  QVariantList list;

  for (const auto &company : mVcard->getVcard()->getRoles())
    list.append(::Utils::linphoneStringToQString(company->getValue()));

  return list;
}

bool VcardModel::addCompany (const QString &company) {
  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  shared_ptr<belcard::BelCardRole> value = belcard::BelCardGeneric::create<belcard::BelCardRole>();
  value->setValue(::Utils::qStringToLinphoneString(company));

  qInfo() << QStringLiteral("Add new company on vcard: `%1`.").arg(company);

  if (!belcard->addRole(value)) {
    qWarning() << QStringLiteral("Unable to add company on vcard: `%1`.").arg(company);
    return false;
  }

  emit vcardUpdated();
  return true;
}

void VcardModel::removeCompany (const QString &company) {
  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  shared_ptr<belcard::BelCardRole> value = findBelCardValue(belcard->getRoles(), company);

  if (!value) {
    qWarning() << QStringLiteral("Unable to remove company on vcard: `%1`.").arg(company);
    return;
  }

  qInfo() << QStringLiteral("Remove company on vcard: `%1`.").arg(company);
  belcard->removeRole(value);

  emit vcardUpdated();
}

bool VcardModel::updateCompany (const QString &oldCompany, const QString &company) {
  if (oldCompany == company || !addCompany(company))
    return false;

  removeCompany(oldCompany);

  return true;
}

// -----------------------------------------------------------------------------

QVariantList VcardModel::getEmails () const {
  QVariantList list;

  for (const auto &email : mVcard->getVcard()->getEmails())
    list.append(::Utils::linphoneStringToQString(email->getValue()));

  return list;
}

bool VcardModel::addEmail (const QString &email) {
  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  shared_ptr<belcard::BelCardEmail> value = belcard::BelCardGeneric::create<belcard::BelCardEmail>();
  value->setValue(::Utils::qStringToLinphoneString(email));

  qInfo() << QStringLiteral("Add new email on vcard: `%1`.").arg(email);

  if (!belcard->addEmail(value)) {
    qWarning() << QStringLiteral("Unable to add email on vcard: `%1`.").arg(email);
    return false;
  }

  emit vcardUpdated();
  return true;
}

void VcardModel::removeEmail (const QString &email) {
  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  shared_ptr<belcard::BelCardEmail> value = findBelCardValue(belcard->getEmails(), email);

  if (!value) {
    qWarning() << QStringLiteral("Unable to remove email on vcard: `%1`.").arg(email);
    return;
  }

  qInfo() << QStringLiteral("Remove email on vcard: `%1`.").arg(email);
  belcard->removeEmail(value);

  emit vcardUpdated();
}

bool VcardModel::updateEmail (const QString &oldEmail, const QString &email) {
  if (oldEmail == email || !addEmail(email))
    return false;

  removeEmail(oldEmail);

  return true;
}

// -----------------------------------------------------------------------------

QVariantList VcardModel::getUrls () const {
  QVariantList list;

  for (const auto &url : mVcard->getVcard()->getURLs())
    list.append(::Utils::linphoneStringToQString(url->getValue()));

  return list;
}

bool VcardModel::addUrl (const QString &url) {
  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  shared_ptr<belcard::BelCardURL> value = belcard::BelCardGeneric::create<belcard::BelCardURL>();
  value->setValue(::Utils::qStringToLinphoneString(url));

  qInfo() << QStringLiteral("Add new url on vcard: `%1`.").arg(url);

  if (!belcard->addURL(value)) {
    qWarning() << QStringLiteral("Unable to add url on vcard: `%1`.").arg(url);
    return false;
  }

  emit vcardUpdated();
  return true;
}

void VcardModel::removeUrl (const QString &url) {
  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  shared_ptr<belcard::BelCardURL> value = findBelCardValue(belcard->getURLs(), url);

  if (!value) {
    qWarning() << QStringLiteral("Unable to remove url on vcard: `%1`.").arg(url);
    return;
  }

  qInfo() << QStringLiteral("Remove url on vcard: `%1`.").arg(url);
  belcard->removeURL(value);

  emit vcardUpdated();
}

bool VcardModel::updateUrl (const QString &oldUrl, const QString &url) {
  if (oldUrl == url || !addUrl(url))
    return false;

  removeUrl(oldUrl);

  return true;
}
