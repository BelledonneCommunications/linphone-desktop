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

#include "Presence.hpp"

// =============================================================================

Presence::PresenceLevel Presence::getPresenceLevel (const PresenceStatus &status) {
  switch (status) {
    case Online:
      return Green;
    case Busy:
      return Orange;
    case DoNotDisturb:
      return Red;
    default:
      break;
  }

  return White;
}

QString Presence::getPresenceStatusAsString (const PresenceStatus &status) {
  switch (status) {
    case Online:
      return tr("presenceOnline");
    case Busy:
      return tr("presenceBusy");
    case DoNotDisturb:
      return tr("presenceDoNotDisturb");
    default:
      break;
  }

  return tr("presenceOffline");
}

QString Presence::getPresenceLevelIconName (const PresenceLevel &level) {
  switch (level) {
    case Green:
      return QStringLiteral("led_green");
    case Orange:
      return QStringLiteral("led_orange");
    case Red:
      return QStringLiteral("led_red");
    case White:
      return QStringLiteral("led_white");
  }

  return QString("");
}
