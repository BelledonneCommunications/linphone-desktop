#ifndef PRESENCE_H_
#define PRESENCE_H_

#include <QObject>

// ===================================================================

class Presence : public QObject {
  Q_OBJECT;

public:
  enum PresenceStatus {
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
  Q_ENUM(PresenceStatus);

  enum PresenceLevel {
    Green,
    Orange,
    Red,
    White
  };
  Q_ENUM(PresenceLevel);

  Presence (QObject *parent = Q_NULLPTR): QObject(parent) { }

  static PresenceLevel getPresenceLevel (const PresenceStatus &presenceStatus) {
    if (presenceStatus == Online)
      return Green;
    if (presenceStatus == DoNotDisturb)
      return Red;
    if (presenceStatus == Offline)
      return White;

    return Orange;
  }
};

#endif // PRESENCE_H_
