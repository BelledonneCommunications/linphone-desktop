/*
 * Presence.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
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
    Online = linphone::ConsolidatedPresenceOnline,
    Busy = linphone::ConsolidatedPresenceBusy,
    DoNotDisturb = linphone::ConsolidatedPresenceDoNotDisturb,
    Offline = linphone::ConsolidatedPresenceOffline
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

  ~Presence () = default;

  Q_INVOKABLE static PresenceLevel getPresenceLevel (const PresenceStatus &status);

  Q_INVOKABLE static QString getPresenceStatusAsString (const PresenceStatus &status);
  Q_INVOKABLE static QString getPresenceLevelIconName (const PresenceLevel &level);
};

#endif // PRESENCE_H_
