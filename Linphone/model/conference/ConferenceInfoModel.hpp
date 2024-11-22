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

#ifndef CONFERENCE_INFO_MODEL_H_
#define CONFERENCE_INFO_MODEL_H_

#include "model/conference/ConferenceSchedulerModel.hpp"
#include "tool/AbstractObject.hpp"

#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

class ConferenceInfoModel : public QObject, public AbstractObject {
	Q_OBJECT
public:
	ConferenceInfoModel(const std::shared_ptr<linphone::ConferenceInfo> &conferenceInfo, QObject *parent = nullptr);
	~ConferenceInfoModel();

	std::shared_ptr<linphone::ConferenceInfo> getConferenceInfo() const;

	std::shared_ptr<ConferenceSchedulerModel> getConferenceScheduler() const;
	void setConferenceScheduler(const std::shared_ptr<ConferenceSchedulerModel> &model);
	QDateTime getDateTime() const;
	int getDuration() const;
	QDateTime getEndTime() const;
	QString getSubject() const;
	linphone::ConferenceInfo::State getState() const;
	QString getOrganizerName() const;
	QString getOrganizerAddress() const;
	QString getDescription() const;
	QString getUri() const;
	std::list<std::shared_ptr<linphone::ParticipantInfo>> getParticipantInfos() const;
	bool inviteEnabled() const;

	void setDateTime(const QDateTime &date);
	void setDuration(int duration);
	void setSubject(const QString &subject);
	void setOrganizer(const QString &organizerAddress);
	void setDescription(const QString &description);
	void setParticipantInfos(const std::list<std::shared_ptr<linphone::ParticipantInfo>> &participantInfos);
	void deleteConferenceInfo();
	void cancelConference();
	void updateConferenceInfo();
	void enableInvite(bool enable);

signals:
	void dateTimeChanged(const QDateTime &date);
	void durationChanged(int duration);
	void organizerChanged(const QString &organizer);
	void subjectChanged(const QString &subject);
	void descriptionChanged(const QString &description);
	void participantsChanged();
	void conferenceInfoDeleted();
	void conferenceInfoCanceled();
	void schedulerStateChanged(linphone::ConferenceScheduler::State state);
	void infoStateChanged(linphone::ConferenceInfo::State state);
	void invitationsSent(const std::list<std::shared_ptr<linphone::Address>> &failedInvitations);
	void inviteEnabledChanged(bool enable);

private:
	std::shared_ptr<linphone::ConferenceInfo> mConferenceInfo;
	std::shared_ptr<ConferenceSchedulerModel> mConferenceSchedulerModel = nullptr;
	bool mInviteEnabled = true;
	DECLARE_ABSTRACT_OBJECT
};

#endif
