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
	return getPresenceLevel(static_cast<linphone::ConsolidatedPresence>(status));
}
Presence::PresenceLevel Presence::getPresenceLevel (const linphone::ConsolidatedPresence &status) {
  switch (status) {
    case linphone::ConsolidatedPresence::Online:
      return Green;
    case linphone::ConsolidatedPresence::Busy:
      return Orange;
    case linphone::ConsolidatedPresence::DoNotDisturb:
      return Red;
    default:
      break;
  }

  return White;
}

QString Presence::getPresenceStatusAsString (const PresenceStatus &status) {
	return getPresenceStatusAsString(static_cast<linphone::ConsolidatedPresence>(status));
}
QString Presence::getPresenceStatusAsString (const linphone::ConsolidatedPresence &status) {
  switch (status) {
    case linphone::ConsolidatedPresence::Online:
      return tr("presenceOnline");
    case linphone::ConsolidatedPresence::Busy:
      return tr("presenceBusy");
    case linphone::ConsolidatedPresence::DoNotDisturb:
      return tr("presenceDoNotDisturb");
    default:
      break;
  }

  return tr("presenceOffline");
}

QString Presence::getBetterPresenceLevelIconName (const PresenceLevel &level) {
  switch (level) {
    case Green:
      return QStringLiteral("current_account_status_online");
    case Orange:
      return QStringLiteral("current_account_status_busy");
    case Red:
      return QStringLiteral("current_account_status_dnd");
    case White:
      return QStringLiteral("current_account_status_offline");
  }

  return QString("");
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
