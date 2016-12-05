#include <QFileInfo>
#include <QImageReader>
#include <QUuid>
#include <QtDebug>

#include <belcard/belcard.hpp>

#include "../../app/Database.hpp"
#include "../../utils.hpp"

#include "ContactModel.hpp"

using namespace std;

// ===================================================================

inline shared_ptr<belcard::BelCard> getBelCard (
  const shared_ptr<linphone::Friend> &linphone_friend
) {
  shared_ptr<linphone::Vcard> vcard = linphone_friend->getVcard();
  return *reinterpret_cast<shared_ptr<belcard::BelCard> *>(vcard.get());
}

// -------------------------------------------------------------------

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

bool ContactModel::setAvatar (const QString &path) {
  // Try to copy photo in avatars folder.
  QFile file(path);

  if (!file.exists() || QImageReader::imageFormat(path).size() == 0)
    return false;

  QFileInfo info(file);
  QString file_id = QUuid::createUuid().toString() + "." + info.suffix();
  QString dest = Utils::linphoneStringToQString(Database::getAvatarsPath()) +
    file_id;

  if (!file.copy(dest))
    return false;

  qInfo() << QStringLiteral("Update avatar of `%1`. (path=%2)")
    .arg(getUsername()).arg(dest);

  // Remove oldest photos.
  shared_ptr<belcard::BelCard> belCard = getBelCard(m_linphone_friend);

  for (const auto &photo : belCard->getPhotos()) {
    qDebug() << Utils::linphoneStringToQString(photo->getValue());
    belCard->removePhoto(photo);
  }

  // Update.
  shared_ptr<belcard::BelCardPhoto> photo =
    belcard::BelCardGeneric::create<belcard::BelCardPhoto>();
  photo->setValue(Utils::qStringToLinphoneString(file_id));
  belCard->addPhoto(photo);


  emit contactUpdated();
  return true;
}

QString ContactModel::getSipAddress () const {
  return Utils::linphoneStringToQString(
    m_linphone_friend->getAddress()->asString()
  );
}
