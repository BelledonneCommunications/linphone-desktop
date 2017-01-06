#ifndef ACCOUNT_SETTINGS_MODEL_H_
#define ACCOUNT_SETTINGS_MODEL_H_

#include <QObject>

#include "../presence/Presence.hpp"

// ===================================================================

class AccountSettingsModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(QString username READ getUsername WRITE setUsername NOTIFY accountUpdated);
  Q_PROPERTY(QString sipAddress READ getSipAddress NOTIFY accountUpdated);

  Q_PROPERTY(
    Presence::PresenceLevel presenceLevel
    READ getPresenceLevel
    CONSTANT
  );

  Q_PROPERTY(
    Presence::PresenceStatus presenceStatus
    READ getPresenceStatus
    CONSTANT
  );

public:
  AccountSettingsModel (QObject *parent = Q_NULLPTR);

signals:
  void accountUpdated ();

private:
  QString getUsername () const;
  void setUsername (const QString &username);

  Presence::PresenceLevel getPresenceLevel () const;
  Presence::PresenceStatus getPresenceStatus () const;

  QString getSipAddress () const;

  std::shared_ptr<linphone::Address> getDefaultSipAddress () const;

  std::shared_ptr<linphone::ProxyConfig> m_default_proxy;
};

#endif // ACCOUNT_SETTINGS_MODEL_H_
