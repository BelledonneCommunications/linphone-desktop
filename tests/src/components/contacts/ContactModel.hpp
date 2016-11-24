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
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    QString avatar
    READ getAvatar
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

  QString getAvatar () const {
    return "";
  }

  Presence::PresenceStatus getPresenceStatus () const;
  Presence::PresenceLevel getPresenceLevel () const;

  QString getSipAddress () const;

  Presence::PresenceStatus m_presence_status = Presence::Offline;

  std::shared_ptr<linphone::Friend> m_linphone_friend;
};

Q_DECLARE_METATYPE(ContactModel*);

#endif // CONTACT_MODEL_H_
