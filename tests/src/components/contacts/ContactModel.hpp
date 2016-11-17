#ifndef CONTACT_MODEL_H
#define CONTACT_MODEL_H

#include <QObject>

#include <linphone++/linphone.hh>

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
    QStringList sipAddresses
    READ getSipAddresses
    WRITE setSipAddresses
    NOTIFY contactUpdated
  );

public:
  ContactModel (std::shared_ptr<linphone::Friend> linphone_friend) {
    m_linphone_friend = linphone_friend;
    m_sip_addresses << "jiiji";
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

  QStringList getSipAddresses () const;
  void setSipAddresses (const QStringList &sip_addresses);

  QString m_username;
  QString m_avatar;
  Presence::PresenceStatus m_presence_status = Presence::Offline;
  QStringList m_sip_addresses;

  std::shared_ptr<linphone::Friend> m_linphone_friend;
};

Q_DECLARE_METATYPE(ContactModel*);

#endif // CONTACT_MODEL_H
