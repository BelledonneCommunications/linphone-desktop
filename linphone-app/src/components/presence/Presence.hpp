/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef PRESENCE_H_
#define PRESENCE_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================
// A helper to get the presence level of a presence status and to get a
// presence status as string.
// =============================================================================

class Presence : public QObject {
  Q_OBJECT;

public:
  enum PresenceStatus {
    Online = int(linphone::ConsolidatedPresence::Online),
    Busy = int(linphone::ConsolidatedPresence::Busy),
    DoNotDisturb = int(linphone::ConsolidatedPresence::DoNotDisturb),
    Offline = int(linphone::ConsolidatedPresence::Offline)
  };
  Q_ENUM(PresenceStatus);

  enum PresenceLevel {
    Green,
    Orange,
    Red,
    White
  };
  Q_ENUM(PresenceLevel);

  Presence (QObject *parent = Q_NULLPTR) : QObject(parent) {}

  Q_INVOKABLE static PresenceLevel getPresenceLevel (const PresenceStatus &status);

  Q_INVOKABLE static QString getPresenceStatusAsString (const PresenceStatus &status);
  Q_INVOKABLE static QString getPresenceLevelIconName (const PresenceLevel &level);
};

#endif // PRESENCE_H_
