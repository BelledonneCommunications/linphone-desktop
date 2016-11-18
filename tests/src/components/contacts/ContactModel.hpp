#ifndef CONTACT_MODEL_H
#define CONTACT_MODEL_H

#include <QObject>
#include <linphone++/linphone.hh>

#include "../../utils.hpp"
#include "../presence/Presence.hpp"

// ===================================================================

class ContactModel : public QObject {
  friend class ContactsListProxyModel;

  Q_OBJECT;

  Q_PROPERTY(
    QString username
    READ getUsername
    WRITE setUsername
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    QString avatar
    READ getAvatar
    WRITE setAvatar
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    Presence::PresenceStatus presenceStatus
    READ getPresenceStatus
    CONSTANT
  );

  Q_PROPERTY(
    Presence::PresenceLevel presenceLevel
    READ getPresenceLevel
    CONSTANT
  );

  Q_PROPERTY(
    QString sipAddress
    READ getSipAddress
    NOTIFY contactUpdated
  );

public:
  ContactModel (std::shared_ptr<linphone::Friend> linphone_friend) {
    m_linphone_friend = linphone_friend;
  }

signals:
  void contactUpdated ();

private:
  QString getUsername () const;
  void setUsername (const QString &username);

  QString getAvatar () const;
  void setAvatar (const QString &avatar);

  Presence::PresenceStatus getPresenceStatus () const;
  Presence::PresenceLevel getPresenceLevel () const;

  QString getSipAddress () const {
    // FIXME.
    return "toto@linphone.org";

    return Utils::linphoneStringToQString(
      m_linphone_friend->getAddress()->asString()
    );
  }

  QString m_username;
  QString m_avatar;
  Presence::PresenceStatus m_presence_status = Presence::Offline;

  std::shared_ptr<linphone::Friend> m_linphone_friend;
};

Q_DECLARE_METATYPE(ContactModel*);

#endif // CONTACT_MODEL_H
