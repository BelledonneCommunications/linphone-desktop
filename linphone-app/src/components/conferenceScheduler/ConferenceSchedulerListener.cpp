/*
 * Copyright (c) 2021-2022 Belledonne Communications SARL.
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

#include "ConferenceSchedulerListener.hpp"

#include <QQmlApplicationEngine>
#include "app/App.hpp"
#include "components/core/CoreManager.hpp"

// =============================================================================

ConferenceSchedulerListener::ConferenceSchedulerListener () : QObject(nullptr){
}

ConferenceSchedulerListener::~ConferenceSchedulerListener () {
}


void ConferenceSchedulerListener::onStateChanged(const std::shared_ptr<linphone::ConferenceScheduler> & conferenceScheduler, linphone::ConferenceSchedulerState state) {
	qWarning() << "ConferenceSchedulerListener::onStateChanged" << (int) state;
	emit stateChanged(state);
}

void ConferenceSchedulerListener::onInvitationsSent(const std::shared_ptr<linphone::ConferenceScheduler> & conferenceScheduler, const std::list<std::shared_ptr<linphone::Address>> & failedInvitations) {
	qWarning() << "ConferenceSchedulerListener::onInvitationsSent";
	emit invitationsSent(failedInvitations);
}
