/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#ifndef CONFERENCE_SCHEDULER_MODEL_H_
#define CONFERENCE_SCHEDULER_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"

#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

class ConferenceSchedulerModel
    : public ::Listener<linphone::ConferenceScheduler, linphone::ConferenceSchedulerListener>,
      public linphone::ConferenceSchedulerListener,
      public AbstractObject {
	Q_OBJECT
public:
	ConferenceSchedulerModel(const std::shared_ptr<linphone::ConferenceScheduler> &conferenceScheduler,
	                         QObject *parent = nullptr);
	~ConferenceSchedulerModel();

	QString getUri();
	linphone::ConferenceScheduler::State getState() const;
	std::shared_ptr<const linphone::ConferenceInfo> getConferenceInfo() const;
	void setInfo(const std::shared_ptr<linphone::ConferenceInfo> &confInfo);
	void cancelConference(const std::shared_ptr<linphone::ConferenceInfo> &confInfo);

signals:
	void stateChanged(linphone::ConferenceScheduler::State state);
	void invitationsSent(const std::list<std::shared_ptr<linphone::Address>> &failedInvitations);

private:
	DECLARE_ABSTRACT_OBJECT
	linphone::ConferenceScheduler::State mState;

	//--------------------------------------------------------------------------------
	// LINPHONE
	//--------------------------------------------------------------------------------
	virtual void onStateChanged(const std::shared_ptr<linphone::ConferenceScheduler> &conferenceScheduler,
	                            linphone::ConferenceScheduler::State state) override;
	virtual void onInvitationsSent(const std::shared_ptr<linphone::ConferenceScheduler> &conferenceScheduler,
	                               const std::list<std::shared_ptr<linphone::Address>> &failedInvitations) override;
};

#endif
