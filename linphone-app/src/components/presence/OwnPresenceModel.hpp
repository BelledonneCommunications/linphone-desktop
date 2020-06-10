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

#ifndef OWN_PRESENCE_MODEL_H_
#define OWN_PRESENCE_MODEL_H_

#include "Presence.hpp"

// =============================================================================
// Gives the statuses list informations (icons, label, level, status).
// Can set/get the presence status of the linphone user app.
// =============================================================================

class OwnPresenceModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(QVariantList statuses READ getStatuses CONSTANT);

  Q_PROPERTY(Presence::PresenceLevel presenceLevel READ getPresenceLevel NOTIFY presenceLevelChanged);
  Q_PROPERTY(Presence::PresenceStatus presenceStatus READ getPresenceStatus WRITE setPresenceStatus NOTIFY presenceStatusChanged);

public:
  OwnPresenceModel (QObject *parent = Q_NULLPTR);

signals:
  void presenceLevelChanged (Presence::PresenceLevel level);
  void presenceStatusChanged (Presence::PresenceStatus status);

private:
  Presence::PresenceLevel getPresenceLevel () const;
  Presence::PresenceStatus getPresenceStatus () const;
  void setPresenceStatus (Presence::PresenceStatus status);

  QVariantList getStatuses () const;
};

#endif // OWN_PRESENCE_MODEL_H_
