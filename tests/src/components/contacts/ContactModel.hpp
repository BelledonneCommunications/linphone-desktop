#ifndef CONTACT_MODEL_H_
#define CONTACT_MODEL_H_

#include <QObject>
#include <linphone++/linphone.hh>

#include "../presence/Presence.hpp"

// ===================================================================

class ContactModel : public QObject {
  friend class ContactsListModel;
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
    QVariantList sipAddresses
    READ getSipAddresses
    WRITE setSipAddresses
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    Presence::PresenceStatus presenceStatus
    READ getPresenceStatus
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    Presence::PresenceLevel presenceLevel
    READ getPresenceLevel
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    QString sipAddress
    READ getSipAddress
    NOTIFY contactUpdated
  );

public:
  ContactModel (std::shared_ptr<linphone::Friend> linphone_friend);

signals:
  void contactUpdated ();

private:
  QString getUsername () const;
  bool setUsername (const QString &username);

  QString getAvatar () const;
  bool setAvatar (const QString &path);

  QVariantList getSipAddresses () const;
  void setSipAddresses (const QVariantList &sip_addresses);

  Presence::PresenceStatus getPresenceStatus () const;
  Presence::PresenceLevel getPresenceLevel () const;

  QString getSipAddress () const;

  Presence::PresenceStatus m_presence_status = Presence::Offline;

  std::shared_ptr<linphone::Friend> m_linphone_friend;
};

Q_DECLARE_METATYPE(ContactModel*);

#endif // CONTACT_MODEL_H_
