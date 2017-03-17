/*
 * PresenceStatusModel.cpp
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
 *  Created on: March 14, 2017
 *      Author: Ghislain MARY
 */

#include <QtDebug>

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "PresenceStatusModel.hpp"

// =============================================================================

Presence::PresenceLevel PresenceStatusModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(getPresenceStatus());
}

Presence::PresenceStatus PresenceStatusModel::getPresenceStatus () const {
  return static_cast<Presence::PresenceStatus>(CoreManager::getInstance()->getCore()->getConsolidatedPresence());
}

void PresenceStatusModel::setPresenceStatus (Presence::PresenceStatus status) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  core->setConsolidatedPresence(static_cast<linphone::ConsolidatedPresence>(status));
  emit presenceStatusChanged(status);
  emit presenceLevelChanged(Presence::getPresenceLevel(status));
}

// -----------------------------------------------------------------------------

QVariantList PresenceStatusModel::getStatuses () const {
  QVariantList statuses;

  QVariantMap online_status;
  online_status["presenceLevel"] = Presence::Green;
  online_status["presenceStatus"] = Presence::Online;
  online_status["presenceIcon"] = Presence::getPresenceLevelIconName(Presence::Green);
  online_status["presenceLabel"] = Presence::getPresenceStatusAsString(Presence::Online);
  statuses << online_status;

  QVariantMap busy_status;
  busy_status["presenceLevel"] = Presence::Orange;
  busy_status["presenceStatus"] = Presence::Busy;
  busy_status["presenceIcon"] = Presence::getPresenceLevelIconName(Presence::Orange);
  busy_status["presenceLabel"] = Presence::getPresenceStatusAsString(Presence::Busy);
  statuses << busy_status;

  QVariantMap do_not_disturb_status;
  do_not_disturb_status["presenceLevel"] = Presence::Red;
  do_not_disturb_status["presenceStatus"] = Presence::DoNotDisturb;
  do_not_disturb_status["presenceIcon"] = Presence::getPresenceLevelIconName(Presence::Red);
  do_not_disturb_status["presenceLabel"] = Presence::getPresenceStatusAsString(Presence::DoNotDisturb);
  statuses << do_not_disturb_status;

  QVariantMap offline_status;
  offline_status["presenceLevel"] = Presence::White;
  offline_status["presenceStatus"] = Presence::Offline;
  offline_status["presenceIcon"] = Presence::getPresenceLevelIconName(Presence::White);
  offline_status["presenceLabel"] = Presence::getPresenceStatusAsString(Presence::Offline);
  statuses << offline_status;

  return statuses;
}
