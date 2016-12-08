#include <QFileInfo>
#include <QImageReader>
#include <QUuid>
#include <QtDebug>

#include <belcard/belcard.hpp>

#include "../../app/AvatarProvider.hpp"
#include "../../app/Database.hpp"
#include "../../utils.hpp"

#include "ContactModel.hpp"

#define VCARD_SCHEME "linphone-desktop:/"

using namespace std;

// ===================================================================

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

  if (!m_linphone_friend->setName(Utils::qStringToLinphoneString(username)))
    emit contactUpdated();
}

// -------------------------------------------------------------------

QString ContactModel::getAvatar () const {
  // Find desktop avatar.
  list<shared_ptr<belcard::BelCardPhoto> > photos =
    m_linphone_friend->getVcard()->getBelcard()->getPhotos();
  auto it = find_if(
    photos.begin(), photos.end(), [](const shared_ptr<belcard::BelCardPhoto> &photo) {
      return !photo->getValue().compare(0, sizeof(VCARD_SCHEME) - 1, VCARD_SCHEME);
    }
  );

  // Returns right path.
  if (it == photos.end())
    return "";

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

void ContactModel::setSipAddresses (const QVariantList &sip_addresses) {
  // TODO.
}

// -------------------------------------------------------------------

QVariantList ContactModel::getCompanies () const {
  QVariantList list;

  for (const auto &company : m_linphone_friend->getVcard()->getBelcard()->getOrganizations())
    list.append(Utils::linphoneStringToQString(company->getValue()));

  return list;
}

void ContactModel::setCompanies (const QVariantList &companies) {
  // TODO.
}

// -------------------------------------------------------------------

QVariantList ContactModel::getEmails () const {
  QVariantList list;

  for (const auto &email : m_linphone_friend->getVcard()->getBelcard()->getEmails())
    list.append(Utils::linphoneStringToQString(email->getValue()));

  return list;
}

void ContactModel::setEmails (const QVariantList &emails) {
  // TODO.
}

// -------------------------------------------------------------------

QVariantList ContactModel::getUrls () const {
  QVariantList list;

  for (const auto &url : m_linphone_friend->getVcard()->getBelcard()->getURLs())
    list.append(Utils::linphoneStringToQString(url->getValue()));

  return list;
}

void ContactModel::setUrls (const QVariantList &urls) {
  // TODO.
}

// -------------------------------------------------------------------

QList<QVariantMap> ContactModel::getAddresses () const {

}

void ContactModel::setAddresses (const QList<QVariantMap> &addresses) {

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
