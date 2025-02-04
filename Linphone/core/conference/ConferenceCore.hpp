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

#ifndef CONFERENCE_CORE_H_
#define CONFERENCE_CORE_H_

#include "core/participant/ParticipantCore.hpp"
#include "core/participant/ParticipantDeviceCore.hpp"
#include "core/participant/ParticipantDeviceGui.hpp"
#include "core/participant/ParticipantGui.hpp"
#include "model/conference/ConferenceModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QDateTime>
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class ConferenceCore : public QObject, public AbstractObject {
	Q_OBJECT
public:
	Q_PROPERTY(QDateTime startDate READ getStartDate CONSTANT)
	// Q_PROPERTY(ParticipantDeviceList *participantDevices READ getParticipantDeviceList CONSTANT)
	// Q_PROPERTY(ParticipantModel* localParticipant READ getLocalParticipant NOTIFY localParticipantChanged)
	Q_PROPERTY(bool isReady MEMBER mIsReady WRITE setIsReady NOTIFY isReadyChanged)
	Q_PROPERTY(bool isRecording READ isRecording WRITE setRecording NOTIFY isRecordingChanged)

	Q_PROPERTY(QString subject READ getSubject WRITE setSubject NOTIFY subjectChanged)
	Q_PROPERTY(bool isLocalScreenSharing MEMBER mIsLocalScreenSharing WRITE setIsLocalScreenSharing NOTIFY
	               isLocalScreenSharingChanged)
	Q_PROPERTY(bool isScreenSharingEnabled MEMBER mIsScreenSharingEnabled WRITE setIsScreenSharingEnabled NOTIFY
	               isScreenSharingEnabledChanged)
	Q_PROPERTY(int participantDeviceCount READ getParticipantDeviceCount NOTIFY participantDeviceCountChanged)
	Q_PROPERTY(
	    ParticipantDeviceGui *activeSpeakerDevice READ getActiveSpeakerDeviceGui NOTIFY activeSpeakerDeviceChanged)
	Q_PROPERTY(ParticipantGui *me READ getMeGui)

	// Should be call from model Thread. Will be automatically in App thread after initialization
	static QSharedPointer<ConferenceCore> create(const std::shared_ptr<linphone::Conference> &conference);
	ConferenceCore(const std::shared_ptr<linphone::Conference> &conference);
	~ConferenceCore();
	void setSelf(QSharedPointer<ConferenceCore> me);

	bool updateLocalParticipant(); // true if changed

	QString getSubject() const;
	void setSubject(const QString &subject);
	QDateTime getStartDate() const;
	Q_INVOKABLE qint64 getElapsedSeconds() const;
	int getParticipantDeviceCount() const;
	void setParticipantDeviceCount(int count);

	bool isRecording() const;
	void setRecording(bool recording);

	ParticipantDeviceCore *getActiveSpeakerDevice() const;
	ParticipantDeviceGui *getActiveSpeakerDeviceGui() const;
	void setActiveSpeakerDevice(const QSharedPointer<ParticipantDeviceCore> &device);
	ParticipantGui *getMeGui() const;

	void setIsReady(bool state);

	void setIsLocalScreenSharing(bool state);
	void setIsScreenSharingEnabled(bool state);

	std::shared_ptr<ConferenceModel> getModel() const;

	//---------------------------------------------------------------------------

signals:
	void isReadyChanged();
	void isLocalScreenSharingChanged();
	void isScreenSharingEnabledChanged();
	void participantDeviceCountChanged();
	void activeSpeakerDeviceChanged();
	void subjectChanged();
	void isRecordingChanged();

	void lToggleScreenSharing();

private:
	QSharedPointer<SafeConnection<ConferenceCore, ConferenceModel>> mConferenceModelConnection;
	std::shared_ptr<ConferenceModel> mConferenceModel;
	QSharedPointer<ParticipantDeviceCore> mActiveSpeakerDevice;
	QSharedPointer<ParticipantCore> mMe;
	int mParticipantDeviceCount = 0;

	bool mIsReady = false;
	bool mIsRecording = false;
	bool mIsLocalScreenSharing = false;
	bool mIsScreenSharingEnabled = false;
	QString mSubject;
	QDateTime mStartDate = QDateTime::currentDateTime();

	DECLARE_ABSTRACT_OBJECT
};

Q_DECLARE_METATYPE(ConferenceCore *)
#endif
