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
#include <QUuid>

#include "../../app/App.hpp"
#include "../../app/paths/Paths.hpp"
#include "../../app/providers/AvatarProvider.hpp"
#include "../../utils/Utils.hpp"
#include "../core/CoreManager.hpp"

#include "VcardModel.hpp"

#define VCARD_SCHEME "linphone-desktop:/"

#define CHECK_VCARD_IS_WRITABLE(VCARD) Q_ASSERT(VCARD->mIsReadOnly == false)

using namespace std;

// =============================================================================

template<class T>
inline shared_ptr<T> findBelCardValue (const list<shared_ptr<T> > &list, const string &value) {
  auto it = find_if(list.cbegin(), list.cend(), [&value](const shared_ptr<T> &entry) {
        return value == entry->getValue();
      });

  return it != list.cend() ? *it : nullptr;
}

template<class T>
inline shared_ptr<T> findBelCardValue (const list<shared_ptr<T> > &list, const QString &value) {
  return ::findBelCardValue(list, ::Utils::appStringToCoreString(value));
}

inline bool isLinphoneDesktopPhoto (const shared_ptr<belcard::BelCardPhoto> &photo) {
  return !photo->getValue().compare(0, sizeof(VCARD_SCHEME) - 1, VCARD_SCHEME);
}

static shared_ptr<belcard::BelCardPhoto> findBelcardPhoto (const shared_ptr<belcard::BelCard> &belcard) {
  const list<shared_ptr<belcard::BelCardPhoto> > &photos = belcard->getPhotos();
  auto it = find_if(photos.cbegin(), photos.cend(), ::isLinphoneDesktopPhoto);
  if (it != photos.cend())
    return *it;

  return nullptr;
}

static void removeBelcardPhoto (const shared_ptr<belcard::BelCard> &belcard, bool cleanPathsOnly = false) {
  list<shared_ptr<belcard::BelCardPhoto> > photos;
  for (const auto photo : belcard->getPhotos()) {
    if (::isLinphoneDesktopPhoto(photo))
      photos.push_back(photo);
  }

  for (const auto photo : photos) {
    QString imagePath(
      ::Utils::coreStringToAppString(
        Paths::getAvatarsDirPath() + photo->getValue().substr(sizeof(VCARD_SCHEME) - 1)
      )
    );

    if (!cleanPathsOnly) {
      if (!QFile::remove(imagePath))
        qWarning() << QStringLiteral("Unable to remove `%1`.").arg(imagePath);
      else
        qInfo() << QStringLiteral("Remove `%1`.").arg(imagePath);
    }

    belcard->removePhoto(photo);
  }
}

static string interpretSipAddress (const QString &sipAddress) {
  string out;

  shared_ptr<linphone::Address> linphoneAddress = CoreManager::getInstance()->getCore()->interpretUrl(
      ::Utils::appStringToCoreString(sipAddress)
    );

  if (!linphoneAddress) {
    qWarning() << QStringLiteral("Unable to interpret invalid sip address: `%1`.").arg(sipAddress);
    return out;
  }

  return linphoneAddress->asStringUriOnly();
}

// -----------------------------------------------------------------------------

VcardModel::VcardModel (shared_ptr<linphone::Vcard> vcard, bool isReadOnly) {
  Q_CHECK_PTR(vcard);
  mVcard = vcard;
  mIsReadOnly = isReadOnly;
}

VcardModel::~VcardModel () {
  if (!mIsReadOnly) {
    qInfo() << QStringLiteral("Destroy detached vcard:") << this;
    if (!mAvatarIsReadOnly)
      ::removeBelcardPhoto(mVcard->getVcard());
  } else
    qInfo() << QStringLiteral("Destroy attached vcard:") << this;
}

// -----------------------------------------------------------------------------

QString VcardModel::getAvatar () const {
  // Find desktop avatar.
  shared_ptr<belcard::BelCardPhoto> photo = ::findBelcardPhoto(mVcard->getVcard());

  // No path found.
  if (!photo)
    return QString("");

  // Returns right path.
  return QStringLiteral("image://%1/%2").arg(AvatarProvider::PROVIDER_ID).arg(
    ::Utils::coreStringToAppString(photo->getValue().substr(sizeof(VCARD_SCHEME) - 1))
  );
}

inline QString getFileIdFromAppPath (const QString &path) {
  const static QString appPrefix = QStringLiteral("image://%1/").arg(AvatarProvider::PROVIDER_ID);
  return path.mid(appPrefix.length());
}

bool VcardModel::setAvatar (const QString &path) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  QString fileId;
  QFile file;

  // 1. Try to copy photo in avatars folder if it's a right path file and
  // not a application path like `image:`.
  if (!path.isEmpty()) {
    if (path.startsWith("image:"))
      fileId = ::getFileIdFromAppPath(path);
    else {
      file.setFileName(path);

      if (!file.exists() || QImageReader::imageFormat(path).size() == 0)
        return false;

      QFileInfo info(file);
      QString uuid = QUuid::createUuid().toString();
      fileId = QStringLiteral("%1.%2")
        .arg(uuid.mid(1, uuid.length() - 2)) // Remove `{}`.
        .arg(info.suffix());

      QString dest = ::Utils::coreStringToAppString(Paths::getAvatarsDirPath()) + fileId;

      if (!file.copy(dest))
        return false;

      qInfo() << QStringLiteral("Update avatar of `%1`. (path=%2)").arg(getUsername()).arg(dest);
    }
  }

  // 2. Remove oldest photo.
  ::removeBelcardPhoto(belcard, mAvatarIsReadOnly);
  mAvatarIsReadOnly = false;

  // 3. Update new photo.
  if (!path.isEmpty()) {
    shared_ptr<belcard::BelCardPhoto> photo = belcard::BelCardGeneric::create<belcard::BelCardPhoto>();
    photo->setValue(VCARD_SCHEME + ::Utils::appStringToCoreString(fileId));

    if (!belcard->addPhoto(photo)) {
      file.remove();
      return false;
    }
  }

  emit vcardUpdated();

  return true;
}

// -----------------------------------------------------------------------------

QString VcardModel::getUsername () const {
  return ::Utils::coreStringToAppString(mVcard->getFullName());
}

void VcardModel::setUsername (const QString &username) {
  CHECK_VCARD_IS_WRITABLE(this);

  if (username.length() == 0 || username == getUsername())
    return;

  mVcard->setFullName(::Utils::appStringToCoreString(username));
  emit vcardUpdated();
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
  map["street"] = ::Utils::coreStringToAppString(address->getStreet());
  map["locality"] = ::Utils::coreStringToAppString(address->getLocality());
  map["postalCode"] = ::Utils::coreStringToAppString(address->getPostalCode());
  map["country"] = ::Utils::coreStringToAppString(address->getCountry());

  return map;
}

void VcardModel::setStreet (const QString &street) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCardAddress> address = ::getOrCreateBelCardAddress(mVcard->getVcard());
  address->setStreet(::Utils::appStringToCoreString(street));
  emit vcardUpdated();
}

void VcardModel::setLocality (const QString &locality) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCardAddress> address = ::getOrCreateBelCardAddress(mVcard->getVcard());
  address->setLocality(::Utils::appStringToCoreString(locality));
  emit vcardUpdated();
}

void VcardModel::setPostalCode (const QString &postalCode) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCardAddress> address = ::getOrCreateBelCardAddress(mVcard->getVcard());
  address->setPostalCode(::Utils::appStringToCoreString(postalCode));
  emit vcardUpdated();
}

void VcardModel::setCountry (const QString &country) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCardAddress> address = ::getOrCreateBelCardAddress(mVcard->getVcard());
  address->setCountry(::Utils::appStringToCoreString(country));
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
      list << ::Utils::coreStringToAppString(linphoneAddress->asStringUriOnly());
    else
      qWarning() << QStringLiteral("Unable to parse sip address: `%1`")
        .arg(::Utils::coreStringToAppString(value));
  }

  return list;
}

bool VcardModel::addSipAddress (const QString &sipAddress) {
  CHECK_VCARD_IS_WRITABLE(this);

  string interpretedSipAddress = ::interpretSipAddress(sipAddress);
  if (interpretedSipAddress.empty())
    return false;

  // Add sip address in belcard.
  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  if (::findBelCardValue(belcard->getImpp(), interpretedSipAddress))
    return false;

  shared_ptr<belcard::BelCardImpp> value = belcard::BelCardGeneric::create<belcard::BelCardImpp>();
  value->setValue(interpretedSipAddress);

  if (!belcard->addImpp(value)) {
    qWarning() << QStringLiteral("Unable to add sip address on vcard: `%1`.").arg(sipAddress);
    return false;
  }

  qInfo() << QStringLiteral("Add new sip address on vcard: `%1`.").arg(sipAddress);

  emit vcardUpdated();
  return true;
}

void VcardModel::removeSipAddress (const QString &sipAddress) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  list<shared_ptr<belcard::BelCardImpp> > addresses = belcard->getImpp();
  shared_ptr<belcard::BelCardImpp> value = ::findBelCardValue(
      addresses, ::Utils::coreStringToAppString(::interpretSipAddress(sipAddress))
    );

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
  bool soFarSoGood = addSipAddress(sipAddress);
  removeSipAddress(oldSipAddress); // Remove after. Avoid `Unable to remove the only sip address...` error.
  return soFarSoGood;
}

// -----------------------------------------------------------------------------

QVariantList VcardModel::getCompanies () const {
  QVariantList list;

  for (const auto &company : mVcard->getVcard()->getRoles())
    list.append(::Utils::coreStringToAppString(company->getValue()));

  return list;
}

bool VcardModel::addCompany (const QString &company) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  if (::findBelCardValue(belcard->getRoles(), company))
    return false;

  shared_ptr<belcard::BelCardRole> value = belcard::BelCardGeneric::create<belcard::BelCardRole>();
  value->setValue(::Utils::appStringToCoreString(company));

  if (!belcard->addRole(value)) {
    qWarning() << QStringLiteral("Unable to add company on vcard: `%1`.").arg(company);
    return false;
  }

  qInfo() << QStringLiteral("Add new company on vcard: `%1`.").arg(company);

  emit vcardUpdated();
  return true;
}

void VcardModel::removeCompany (const QString &company) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  shared_ptr<belcard::BelCardRole> value = ::findBelCardValue(belcard->getRoles(), company);

  if (!value) {
    qWarning() << QStringLiteral("Unable to remove company on vcard: `%1`.").arg(company);
    return;
  }

  qInfo() << QStringLiteral("Remove company on vcard: `%1`.").arg(company);
  belcard->removeRole(value);

  emit vcardUpdated();
}

bool VcardModel::updateCompany (const QString &oldCompany, const QString &company) {
  removeCompany(oldCompany);
  return addCompany(company);
}

// -----------------------------------------------------------------------------

QVariantList VcardModel::getEmails () const {
  QVariantList list;

  for (const auto &email : mVcard->getVcard()->getEmails())
    list.append(::Utils::coreStringToAppString(email->getValue()));

  return list;
}

bool VcardModel::addEmail (const QString &email) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  if (::findBelCardValue(belcard->getEmails(), email))
    return false;

  shared_ptr<belcard::BelCardEmail> value = belcard::BelCardGeneric::create<belcard::BelCardEmail>();
  value->setValue(::Utils::appStringToCoreString(email));

  if (!belcard->addEmail(value)) {
    qWarning() << QStringLiteral("Unable to add email on vcard: `%1`.").arg(email);
    return false;
  }

  qInfo() << QStringLiteral("Add new email on vcard: `%1`.").arg(email);

  emit vcardUpdated();

  return true;
}

void VcardModel::removeEmail (const QString &email) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  shared_ptr<belcard::BelCardEmail> value = ::findBelCardValue(belcard->getEmails(), email);

  if (!value) {
    qWarning() << QStringLiteral("Unable to remove email on vcard: `%1`.").arg(email);
    return;
  }

  qInfo() << QStringLiteral("Remove email on vcard: `%1`.").arg(email);
  belcard->removeEmail(value);

  emit vcardUpdated();
}

bool VcardModel::updateEmail (const QString &oldEmail, const QString &email) {
  removeEmail(oldEmail);
  return addEmail(email);
}

// -----------------------------------------------------------------------------

QVariantList VcardModel::getUrls () const {
  QVariantList list;

  for (const auto &url : mVcard->getVcard()->getURLs())
    list.append(::Utils::coreStringToAppString(url->getValue()));

  return list;
}

bool VcardModel::addUrl (const QString &url) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  if (::findBelCardValue(belcard->getURLs(), url))
    return false;

  shared_ptr<belcard::BelCardURL> value = belcard::BelCardGeneric::create<belcard::BelCardURL>();
  value->setValue(::Utils::appStringToCoreString(url));

  if (!belcard->addURL(value)) {
    qWarning() << QStringLiteral("Unable to add url on vcard: `%1`.").arg(url);
    return false;
  }

  qInfo() << QStringLiteral("Add new url on vcard: `%1`.").arg(url);

  emit vcardUpdated();

  return true;
}

void VcardModel::removeUrl (const QString &url) {
  CHECK_VCARD_IS_WRITABLE(this);

  shared_ptr<belcard::BelCard> belcard = mVcard->getVcard();
  shared_ptr<belcard::BelCardURL> value = ::findBelCardValue(belcard->getURLs(), url);

  if (!value) {
    qWarning() << QStringLiteral("Unable to remove url on vcard: `%1`.").arg(url);
    return;
  }

  qInfo() << QStringLiteral("Remove url on vcard: `%1`.").arg(url);
  belcard->removeURL(value);

  emit vcardUpdated();
}

bool VcardModel::updateUrl (const QString &oldUrl, const QString &url) {
  removeUrl(oldUrl);
  return addUrl(url);
}
