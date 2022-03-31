/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef CONFERENCE_MODEL_H_
#define CONFERENCE_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>

class ConferenceModel : public QObject, public linphone::ConferenceListener{
	Q_OBJECT
public:
	static std::shared_ptr<ConferenceModel> create(std::shared_ptr<linphone::Conference> chatRoom, QObject *parent = Q_NULLPTR);
	ConferenceModel(std::shared_ptr<linphone::Conference> content, QObject *parent = Q_NULLPTR);
	virtual ~ConferenceModel();
	
	std::shared_ptr<linphone::Conference> getConference()const;

// LINPHONE LISTENERS
	virtual void onParticipantAdded(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant) override;
	virtual void onParticipantRemoved(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant) override;
	virtual void onParticipantDeviceAdded(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice) override;
	virtual void onParticipantDeviceRemoved(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice) override;
	virtual void onParticipantAdminStatusChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::Participant> & participant) override;
	virtual void onParticipantDeviceLeft(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & device) override;
	virtual void onParticipantDeviceJoined(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & device) override;
	virtual void onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::ParticipantDevice> & device) override;
	virtual void onStateChanged(const std::shared_ptr<linphone::Conference> & conference, linphone::Conference::State newState) override;
	virtual void onSubjectChanged(const std::shared_ptr<linphone::Conference> & conference, const std::string & subject) override;
	virtual void onAudioDeviceChanged(const std::shared_ptr<linphone::Conference> & conference, const std::shared_ptr<const linphone::AudioDevice> & audioDevice) override;
//---------------------------------------------------------------------------
	
signals:
	void participantDeviceAdded(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceRemoved(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceLeft(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceJoined(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceMediaAvailabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void conferenceStateChanged(linphone::Conference::State newState);

private:
	std::shared_ptr<linphone::Conference> mConference;
	std::weak_ptr<ConferenceModel> mSelf;
};
Q_DECLARE_METATYPE(std::shared_ptr<ConferenceModel>)

#endif
