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

#include <QVariantMap>

#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"

#include "OwnPresenceModel.hpp"


// =============================================================================

using namespace std;

OwnPresenceModel::OwnPresenceModel (QObject *parent) : QObject(parent) {
  AccountSettingsModel *accountSettingsModel = CoreManager::getInstance()->getAccountSettingsModel();
// Update status when changing the publish presence from settings
  QObject::connect(accountSettingsModel, &AccountSettingsModel::publishPresenceChanged, this, [this]() {
    Presence::PresenceStatus status = static_cast<Presence::PresenceStatus>(CoreManager::getInstance()->getCore()->getConsolidatedPresence());
    emit presenceStatusChanged(status);
    emit presenceLevelChanged(Presence::getPresenceLevel(status));
  });
}

Presence::PresenceLevel OwnPresenceModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(getPresenceStatus());
}

Presence::PresenceStatus OwnPresenceModel::getPresenceStatus () const {
  return static_cast<Presence::PresenceStatus>(CoreManager::getInstance()->getCore()->getConsolidatedPresence());
}

void OwnPresenceModel::setPresenceStatus (Presence::PresenceStatus status) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  core->setConsolidatedPresence(static_cast<linphone::ConsolidatedPresence>(status));
  emit presenceStatusChanged(status);
  emit presenceLevelChanged(Presence::getPresenceLevel(status));
}

// -----------------------------------------------------------------------------

static inline void addBuildStatus (QVariantList &list, Presence::PresenceStatus status) {
  Presence::PresenceLevel level = Presence::getPresenceLevel(status);

  QVariantMap map;
  map["presenceLevel"] = level;
  map["presenceStatus"] = status;
  map["presenceIcon"] = Presence::getPresenceLevelIconName(level);
  map["presenceLabel"] = Presence::getPresenceStatusAsString(status);

  list << map;
}

QVariantList OwnPresenceModel::getStatuses () const {
  QVariantList statuses;

  addBuildStatus(statuses, Presence::Online);
  addBuildStatus(statuses, Presence::Busy);
  addBuildStatus(statuses, Presence::DoNotDisturb);
  addBuildStatus(statuses, Presence::Offline);

  return statuses;
}
