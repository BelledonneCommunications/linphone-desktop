#ifndef PRESENCE_MODEL_H_
#define PRESENCE_MODEL_H_

#include <QObject>

// ===================================================================

class PresenceModel : public QObject {
  Q_OBJECT;

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

  PresenceModel (QObject *parent = Q_NULLPTR) { }

  static PresenceLevel getPresenceLevel (const Presence &presence) {
    if (presence == Online)
      return Green;
    if (presence == DoNotDisturb)
      return Red;
    if (presence == Offline)
      return White;

    return Orange;
  }
};

#endif // PRESENCE_MODEL_H_
