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

#ifndef CONFERENCE_SCHEDULER_H_
#define CONFERENCE_SCHEDULER_H_

#include <linphone++/linphone.hh>
#include <QDateTime>
#include <QObject>

class ConferenceSchedulerListener;

class ConferenceScheduler : public QObject {
	Q_OBJECT
	
public:
	static QSharedPointer<ConferenceScheduler> create(QObject *parent = Q_NULLPTR);
	ConferenceScheduler (QObject * parent = nullptr);
	virtual ~ConferenceScheduler ();
	std::shared_ptr<linphone::ConferenceScheduler> getConferenceScheduler();
	
	virtual void onStateChanged(linphone::ConferenceSchedulerState state);
	virtual void onInvitationsSent(const std::list<std::shared_ptr<linphone::Address>> & failedInvitations);
	
	int mSendInvite = 1;// TODO : Enum for app = 1, email=2. Both = 3
	
signals:
	void stateChanged(linphone::ConferenceSchedulerState state);
	void invitationsSent(const std::list<std::shared_ptr<linphone::Address>> & failedInvitations);

private:

	void connectTo(ConferenceSchedulerListener * listener);
	
	std::shared_ptr<linphone::ConferenceScheduler> mConferenceScheduler;
	std::shared_ptr<ConferenceSchedulerListener> mConferenceSchedulerListener;
	
};

Q_DECLARE_METATYPE(QSharedPointer<ConferenceScheduler>)

#endif
