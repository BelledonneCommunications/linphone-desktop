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

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return m_presence_status;
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(m_presence_status);
}

QString ContactModel::getUsername () const {
  return Utils::linphoneStringToQString(
    m_linphone_friend->getName()
  );
}

bool ContactModel::setUsername (const QString &username) {
  if (username.length() == 0)
    return false;

  return !m_linphone_friend->setName(
    Utils::qStringToLinphoneString(username)
  );
}

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

bool ContactModel::setAvatar (const QString &path) {
  // 1. Try to copy photo in avatars folder.
  QFile file(path);

  if (!file.exists() || QImageReader::imageFormat(path).size() == 0)
    return false;

  QFileInfo info(file);
  QString uuid = QUuid::createUuid().toString();
  QString file_id = QStringLiteral("%1.%2")
    .arg(uuid.mid(1, uuid.length() - 2)) // Remove `{}`.
    .arg(info.suffix());

  QString dest = Utils::linphoneStringToQString(Database::getAvatarsPath()) +
    file_id;

  if (!file.copy(dest))
    return false;

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

  return true;
}

QVariantList ContactModel::getSipAddresses () const {
  QVariantList list;

  for (const auto &address : m_linphone_friend->getAddresses())
    list.append(Utils::linphoneStringToQString(address->asString()));

  return list;
}

void ContactModel::setSipAddresses (const QVariantList &sip_addresses) {

}

QString ContactModel::getSipAddress () const {
  return Utils::linphoneStringToQString(
    m_linphone_friend->getAddress()->asString()
  );
}
