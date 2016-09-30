#ifndef ACCOUNT_SETTINGS_MODEL_H_
#define ACCOUNT_SETTINGS_MODEL_H_

#include <QObject>

// ===================================================================

class AccountSettingsModel : public QObject {
  Q_OBJECT

  Q_PROPERTY(
    QString username
    READ getUsername
    WRITE setUsername
  );

  Q_PROPERTY(
    Presence presence
    READ getPresence
    WRITE setPresence
  );

public:
  // See: https://tools.ietf.org/html/rfc4480#section-3.2
  // Activities, section 3.2 of RFC 4480
  enum Presence {
    Away,
    BeRightBack,
    Busy,
    DoNotDisturb,
    Moved,
    Offline,
    OnThePhone,
    Online,
    OutToLunch,
    UsingAnotherMessagingService
  };

  AccountSettingsModel (QObject *parent = Q_NULLPTR);

private:
  QString getUsername () const;
  void setUsername (const QString &username);

  Presence getPresence () const;
  void setPresence (Presence presence);
};

#endif // ACCOUNT_SETTINGS_MODEL_H_
