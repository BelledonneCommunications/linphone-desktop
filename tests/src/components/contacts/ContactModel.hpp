#ifndef CONTACT_MODEL_H
#define CONTACT_MODEL_H

#include <QObject>

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
    Presence presence
    READ getPresence
    CONSTANT
  );

  Q_PROPERTY(
    PresenceLevel presenceLevel
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
  enum Presence {
    Online,
    BeRightBack,
    Away,
    OnThePhone,
    OutToLunch,
    DoNotDisturb,
    Moved,
    UsingAnotherMessagingService,
    Offline
  };
  Q_ENUM(Presence);

  enum PresenceLevel {
    Green,
    Orange,
    Red,
    White
  };
  Q_ENUM(PresenceLevel);

  ContactModel (QObject *parent = Q_NULLPTR) : QObject(parent) { }
  ContactModel (
    const QString &username,
    const QString &avatar,
    const Presence &presence,
    const QStringList &sip_addresses
  ): ContactModel() {
    m_username = username;
    m_avatar = avatar;
    m_presence = presence;
    m_sip_addresses = sip_addresses;
  }

signals:
  void contactUpdated ();

private:
  QString getUsername () const {
    return m_username;
  }

  void setUsername (const QString &username) {
    m_username = username;
  }

  QString getAvatar () const {
    return m_avatar;
  }

  void setAvatar (const QString &avatar) {
    m_avatar = avatar;
  }

  Presence getPresence () const {
    return m_presence;
  }

  PresenceLevel getPresenceLevel () const;

  QStringList getSipAddresses () const {
    return m_sip_addresses;
  }

  void setSipAddresses (const QStringList &sip_addresses) {
    m_sip_addresses = sip_addresses;
  }

  QString m_username;
  QString m_avatar;
  Presence m_presence = Online;
  QStringList m_sip_addresses;
};

Q_DECLARE_METATYPE(ContactModel*);

#endif // CONTACT_MODEL_H
