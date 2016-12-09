#include <QFileInfo>
#include <QImageReader>
#include <QUuid>
#include <QtDebug>

#include <belcard/belcard.hpp>

#include "../../app/AvatarProvider.hpp"
#include "../../app/Database.hpp"
#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "ContactModel.hpp"

#define VCARD_SCHEME "linphone-desktop:/"

using namespace std;

// ===================================================================

template<class T>
inline shared_ptr<T> findBelCardValue (
  const list<shared_ptr<T> > &list,
  const QString &value
) {
  string match = Utils::qStringToLinphoneString(value);

  auto it = find_if(
    list.cbegin(), list.cend(),
    [&match](const shared_ptr<T> &entry) {
      return match == entry->getValue();
    }
  );

  return *it;
}

// -------------------------------------------------------------------

ContactModel::ContactModel (shared_ptr<linphone::Friend> linphone_friend) {
  linphone_friend->setData("contact-model", *this);
  m_linphone_friend = linphone_friend;
}

// -------------------------------------------------------------------

QString ContactModel::getUsername () const {
  return Utils::linphoneStringToQString(
    m_linphone_friend->getName()
  );
}

void ContactModel::setUsername (const QString &username) {
  if (username.length() == 0 || username == getUsername())
    return;

  m_linphone_friend->edit();

  if (!m_linphone_friend->setName(Utils::qStringToLinphoneString(username)))
    emit contactUpdated();

  m_linphone_friend->done();
}

// -------------------------------------------------------------------

QString ContactModel::getAvatar () const {
  // Find desktop avatar.
  list<shared_ptr<belcard::BelCardPhoto> > photos =
    m_linphone_friend->getVcard()->getBelcard()->getPhotos();
  auto it = find_if(
    photos.cbegin(), photos.cend(), [](const shared_ptr<belcard::BelCardPhoto> &photo) {
      return !photo->getValue().compare(0, sizeof(VCARD_SCHEME) - 1, VCARD_SCHEME);
    }
  );

  // No path found.
  if (it == photos.cend())
    return "";

  // Returns right path.
  return QStringLiteral("image://%1/%2")
    .arg(AvatarProvider::PROVIDER_ID)
    .arg(Utils::linphoneStringToQString(
      (*it)->getValue().substr(sizeof(VCARD_SCHEME) - 1)
    ));
}

void ContactModel::setAvatar (const QString &path) {
  // 1. Try to copy photo in avatars folder.
  QFile file(path);

  if (!file.exists() || QImageReader::imageFormat(path).size() == 0)
    return;

  QFileInfo info(file);
  QString uuid = QUuid::createUuid().toString();
  QString file_id = QStringLiteral("%1.%2")
    .arg(uuid.mid(1, uuid.length() - 2)) // Remove `{}`.
    .arg(info.suffix());

  QString dest = Utils::linphoneStringToQString(Database::getAvatarsPath()) +
    file_id;

  if (!file.copy(dest))
    return;

  qInfo() << QStringLiteral("Update avatar of `%1`. (path=%2)")
    .arg(getUsername()).arg(dest);

  // 2. Edit vcard.
  m_linphone_friend->edit();

  shared_ptr<belcard::BelCard> belCard = m_linphone_friend->getVcard()->getBelcard();
  list<shared_ptr<belcard::BelCardPhoto> > photos = belCard->getPhotos();

  // 3. Remove oldest photo.
  auto it = find_if(
    photos.begin(), photos.end(), [](const shared_ptr<belcard::BelCardPhoto> &photo) {
      return !photo->getValue().compare(0, sizeof(VCARD_SCHEME) - 1, VCARD_SCHEME);
    }
  );

  if (it != photos.end()) {
    QString image_path(Utils::linphoneStringToQString(
      Database::getAvatarsPath() + (*it)->getValue().substr(sizeof(VCARD_SCHEME) - 1)
    ));
    if (!QFile::remove(image_path))
      qWarning() << QStringLiteral("Unable to remove `%1`.").arg(image_path);
    belCard->removePhoto(*it);
  }

  // 4. Update.
  shared_ptr<belcard::BelCardPhoto> photo =
    belcard::BelCardGeneric::create<belcard::BelCardPhoto>();
  photo->setValue(VCARD_SCHEME + Utils::qStringToLinphoneString(file_id));
  belCard->addPhoto(photo);

  m_linphone_friend->done();

  emit contactUpdated();

  return;
}

// -------------------------------------------------------------------

QVariantList ContactModel::getSipAddresses () const {
  QVariantList list;

  for (const auto &address : m_linphone_friend->getAddresses())
    list.append(Utils::linphoneStringToQString(address->asString()));

  return list;
}

void ContactModel::addSipAddress (const QString &sip_address) {
  shared_ptr<linphone::Address> address =
    CoreManager::getInstance()->getCore()->createAddress(
      Utils::qStringToLinphoneString(sip_address)
    );

  if (!address) {
    qWarning() << QStringLiteral("Unable to add invalid sip address: `%1`.").arg(sip_address);
    return;
  }

  qInfo() << QStringLiteral("Add new sip address: `%1`.").arg(sip_address);

  m_linphone_friend->edit();
  m_linphone_friend->addAddress(address);
  m_linphone_friend->done();

  emit contactUpdated();
}

bool ContactModel::removeSipAddress (const QString &sip_address) {
  list<shared_ptr<linphone::Address> > addresses = m_linphone_friend->getAddresses();
  string match = Utils::qStringToLinphoneString(sip_address);

  auto it = find_if(
    addresses.cbegin(), addresses.cend(),
    [&match](const shared_ptr<linphone::Address> &address) {
      return match == address->asString();
    }
  );

  if (it == addresses.cend()) {
    qWarning() << QStringLiteral("Unable to found sip address: `%1`.")
      .arg(sip_address);
    return false;
  }

  if (addresses.size() == 1) {
    qWarning() << QStringLiteral("Unable to remove the only existing sip address: `%1`.")
      .arg(sip_address);
    return false;
  }

  qInfo() << QStringLiteral("Remove sip address: `%1`.").arg(sip_address);

  m_linphone_friend->edit();
  m_linphone_friend->removeAddress(*it);
  m_linphone_friend->done();

  emit contactUpdated();

  return true;
}

void ContactModel::updateSipAddress (const QString &old_sip_address, const QString &sip_address) {
  if (old_sip_address == sip_address || !removeSipAddress(old_sip_address))
    return;

  addSipAddress(sip_address);
}

// -------------------------------------------------------------------

QVariantList ContactModel::getCompanies () const {
  QVariantList list;

  for (const auto &company : m_linphone_friend->getVcard()->getBelcard()->getRoles())
    list.append(Utils::linphoneStringToQString(company->getValue()));

  return list;
}

void ContactModel::addCompany (const QString &company) {
  shared_ptr<belcard::BelCard> belCard = m_linphone_friend->getVcard()->getBelcard();
  shared_ptr<belcard::BelCardRole> value =
    belcard::BelCardGeneric::create<belcard::BelCardRole>();
  value->setValue(Utils::qStringToLinphoneString(company));

  qInfo() << QStringLiteral("Add new company: `%1`.").arg(company);

  m_linphone_friend->edit();
  belCard->addRole(value);
  m_linphone_friend->done();

  emit contactUpdated();
}

bool ContactModel::removeCompany (const QString &company) {
  shared_ptr<belcard::BelCard> belCard = m_linphone_friend->getVcard()->getBelcard();
  shared_ptr<belcard::BelCardRole> value = findBelCardValue(belCard->getRoles(), company);

  if (!value) {
    qWarning() << QStringLiteral("Unable to remove company: `%1`.").arg(company);
    return false;
  }

  qInfo() << QStringLiteral("Remove company: `%1`.").arg(company);

  m_linphone_friend->edit();
  belCard->removeRole(value);
  m_linphone_friend->done();

  emit contactUpdated();

  return true;
}

void ContactModel::updateCompany (const QString &old_company, const QString &company) {
  if (old_company == company || !removeCompany(old_company))
    return;

  addCompany(company);
}

// -------------------------------------------------------------------

QVariantList ContactModel::getEmails () const {
  QVariantList list;

  for (const auto &email : m_linphone_friend->getVcard()->getBelcard()->getEmails())
    list.append(Utils::linphoneStringToQString(email->getValue()));

  return list;
}

void ContactModel::addEmail (const QString &email) {
  shared_ptr<belcard::BelCard> belCard = m_linphone_friend->getVcard()->getBelcard();
  shared_ptr<belcard::BelCardEmail> value =
    belcard::BelCardGeneric::create<belcard::BelCardEmail>();
  value->setValue(Utils::qStringToLinphoneString(email));

  qInfo() << QStringLiteral("Add new email: `%1`.").arg(email);

  m_linphone_friend->edit();
  belCard->addEmail(value);
  m_linphone_friend->done();

  emit contactUpdated();
}

bool ContactModel::removeEmail (const QString &email) {
  shared_ptr<belcard::BelCard> belCard = m_linphone_friend->getVcard()->getBelcard();
  shared_ptr<belcard::BelCardEmail> value = findBelCardValue(belCard->getEmails(), email);

  if (!value) {
    qWarning() << QStringLiteral("Unable to remove email: `%1`.").arg(email);
    return false;
  }

  qInfo() << QStringLiteral("Remove email: `%1`.").arg(email);

  m_linphone_friend->edit();
  belCard->removeEmail(value);
  m_linphone_friend->done();

  emit contactUpdated();

  return true;
}

void ContactModel::updateEmail (const QString &old_email, const QString &email) {
  if (old_email == email || !removeEmail(old_email))
    return;

  addEmail(email);
}

// -------------------------------------------------------------------

QVariantList ContactModel::getUrls () const {
  QVariantList list;

  for (const auto &url : m_linphone_friend->getVcard()->getBelcard()->getURLs())
    list.append(Utils::linphoneStringToQString(url->getValue()));

  return list;
}

void ContactModel::addUrl (const QString &url) {
  shared_ptr<belcard::BelCard> belCard = m_linphone_friend->getVcard()->getBelcard();
  shared_ptr<belcard::BelCardURL> value =
    belcard::BelCardGeneric::create<belcard::BelCardURL>();
  value->setValue(Utils::qStringToLinphoneString(url));

  qInfo() << QStringLiteral("Add new url: `%1`.").arg(url);

  m_linphone_friend->edit();
  belCard->addURL(value);
  m_linphone_friend->done();

  emit contactUpdated();
}

bool ContactModel::removeUrl (const QString &url) {
  shared_ptr<belcard::BelCard> belCard = m_linphone_friend->getVcard()->getBelcard();
  shared_ptr<belcard::BelCardURL> value = findBelCardValue(belCard->getURLs(), url);

  if (!value) {
    qWarning() << QStringLiteral("Unable to remove url: `%1`.").arg(url);
    return false;
  }

  qInfo() << QStringLiteral("Remove url: `%1`.").arg(url);

  m_linphone_friend->edit();
  belCard->removeURL(value);
  m_linphone_friend->done();

  emit contactUpdated();

  return true;
}

void ContactModel::updateUrl (const QString &old_url, const QString &url) {
  if (old_url == url || !removeUrl(old_url))
    return;

  addUrl(url);
}

// -------------------------------------------------------------------

QList<QVariantMap> ContactModel::getAddresses () const {

}

// -------------------------------------------------------------------

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return m_presence_status;
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(m_presence_status);
}
QString ContactModel::getSipAddress () const {
  return Utils::linphoneStringToQString(
    m_linphone_friend->getAddress()->asString()
  );
}
