#ifndef ACCOUNT_SETTINGS_MODEL_H_
#define ACCOUNT_SETTINGS_MODEL_H_

#include <QObject>

#include "../presence/Presence.hpp"

// ===================================================================

class AccountSettingsModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(
    QString username
    READ getUsername
    WRITE setUsername
  );

  Q_PROPERTY(
    QString sipAddress
    READ getSipAddress
    CONSTANT
  );

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

  Q_PROPERTY(
    bool autoAnswerStatus
    READ getAutoAnswerStatus
    CONSTANT
  );

public:
  AccountSettingsModel (QObject *parent = Q_NULLPTR);

private:
  QString getUsername () const;
  void setUsername (const QString &username);

  Presence::PresenceLevel getPresenceLevel () const;
  Presence::PresenceStatus getPresenceStatus () const;

  QString getSipAddress () const;

  bool getAutoAnswerStatus () const;
};

#endif // ACCOUNT_SETTINGS_MODEL_H_
