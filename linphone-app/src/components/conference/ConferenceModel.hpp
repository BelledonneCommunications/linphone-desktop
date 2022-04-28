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

class ConferenceListener;

class ConferenceModel : public QObject{
	Q_OBJECT
public:

	Q_PROPERTY(QString subject READ getSubject NOTIFY subjectChanged)
	Q_PROPERTY(QDateTime startDate READ getStartDate CONSTANT)

	static QSharedPointer<ConferenceModel> create(std::shared_ptr<linphone::Conference> chatRoom, QObject *parent = Q_NULLPTR);
	ConferenceModel(std::shared_ptr<linphone::Conference> content, QObject *parent = Q_NULLPTR);
	virtual ~ConferenceModel();
	
	std::shared_ptr<linphone::Conference> getConference()const;
	
	QString getSubject() const;
	QDateTime getStartDate() const;
	Q_INVOKABLE qint64 getElapsedSeconds() const;

	virtual void onParticipantAdded(const std::shared_ptr<const linphone::Participant> & participant);
	virtual void onParticipantRemoved(const std::shared_ptr<const linphone::Participant> & participant);
	virtual void onParticipantDeviceAdded(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	virtual void onParticipantDeviceRemoved(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	virtual void onParticipantDeviceLeft(const std::shared_ptr<const linphone::ParticipantDevice> & device);
	virtual void onParticipantDeviceJoined(const std::shared_ptr<const linphone::ParticipantDevice> & device);
	virtual void onParticipantDeviceMediaCapabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & device);
	virtual void onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & device);
	virtual void onParticipantDeviceIsSpeakingChanged(const std::shared_ptr<const linphone::ParticipantDevice> & device, bool isSpeaking);
	virtual void onConferenceStateChanged(linphone::Conference::State newState);
	virtual void onSubjectChanged(const std::string& subject);
//---------------------------------------------------------------------------
	
signals:
	void participantAdded(const std::shared_ptr<const linphone::Participant> & participant);
	void participantRemoved(const std::shared_ptr<const linphone::Participant> & participant);
	void participantDeviceAdded(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceRemoved(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceLeft(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceJoined(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceMediaCapabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceMediaAvailabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice);
	void participantDeviceIsSpeakingChanged(const std::shared_ptr<const linphone::ParticipantDevice> & device, bool isSpeaking);
	void conferenceStateChanged(linphone::Conference::State newState);
	void subjectChanged();

private:
	void connectTo(ConferenceListener * listener);
	
	std::shared_ptr<linphone::Conference> mConference;
	std::shared_ptr<ConferenceListener> mConferenceListener;
};
Q_DECLARE_METATYPE(QSharedPointer<ConferenceModel>)

#endif
