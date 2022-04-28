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

#ifndef PARTICIPANT_DEVICE_MODEL_H_
#define PARTICIPANT_DEVICE_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include <QSharedPointer>

class CallModel;
class ParticipantDeviceListener;

class ParticipantDeviceModel : public QObject {
    Q_OBJECT

	
public:
    ParticipantDeviceModel (CallModel * callModel, std::shared_ptr<linphone::ParticipantDevice> device, const bool& isMe = false, QObject *parent = nullptr);
    virtual ~ParticipantDeviceModel();
    //ParticipantDeviceModel (CallModel * call, const bool& isMe = true, QObject *parent = nullptr);
    
    static QSharedPointer<ParticipantDeviceModel> create(CallModel* callModel, std::shared_ptr<linphone::ParticipantDevice> device, const bool& isMe = false, QObject *parent = nullptr);
    //static std::shared_ptr<ParticipantDeviceModel> create(CallModel * call, const bool& isMe = true, QObject *parent = nullptr);
	
	Q_PROPERTY(QString displayName READ getDisplayName CONSTANT)
	Q_PROPERTY(QString name READ getName CONSTANT)
	Q_PROPERTY(QString address READ getAddress CONSTANT)
	Q_PROPERTY(int securityLevel READ getSecurityLevel NOTIFY securityLevelChanged)
	Q_PROPERTY(time_t timeOfJoining READ getTimeOfJoining CONSTANT)
	Q_PROPERTY(bool videoEnabled READ isVideoEnabled NOTIFY videoEnabledChanged)
	Q_PROPERTY(bool isMe READ isMe CONSTANT)
	Q_PROPERTY(bool isPaused READ getPaused WRITE setPaused NOTIFY isPausedChanged)
	Q_PROPERTY(bool isSpeaking READ getIsSpeaking WRITE setIsSpeaking NOTIFY isSpeakingChanged)
	Q_PROPERTY(bool isMuted READ getIsMuted NOTIFY isMutedChanged)
  
	QString getName() const;
	QString getDisplayName() const;
    QString getAddress() const;
	int getSecurityLevel() const;
	time_t getTimeOfJoining() const;
	bool isVideoEnabled() const;
	bool isMe() const;
	bool getPaused() const;
	bool getIsSpeaking() const;
	bool getIsMuted() const;
	
	std::shared_ptr<linphone::ParticipantDevice>  getDevice();
	
	void setPaused(bool paused);
	void setIsSpeaking(bool speaking);
	
	//void deviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	virtual void onIsSpeakingChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isSpeaking);
	virtual void onIsMuted(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool isMuted);
	virtual void onConferenceJoined(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice);
	virtual void onConferenceLeft(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice);
	virtual void onStreamCapabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, linphone::MediaDirection direction, linphone::StreamType streamType);
	virtual void onStreamAvailabilityChanged(const std::shared_ptr<linphone::ParticipantDevice> & participantDevice, bool available, linphone::StreamType streamType);
	
	void connectTo(ParticipantDeviceListener * listener);
	void updateVideoEnabled();
	
public slots:
	void onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void onCallStatusChanged();
signals:
	void securityLevelChanged();
	void videoEnabledChanged();
	void isPausedChanged();
	void isSpeakingChanged();
	void isMutedChanged();

private:

	bool mIsMe = false;
	bool mIsVideoEnabled;
	bool mIsPaused = false;
	bool mIsSpeaking = false;

    std::shared_ptr<linphone::ParticipantDevice> mParticipantDevice;
    std::shared_ptr<ParticipantDeviceListener> mParticipantDeviceListener;	// This is passed to linpĥone object and must be in shared_ptr
    
    CallModel * mCall;
	QWeakPointer<ParticipantDeviceModel> mSelf;
};
Q_DECLARE_METATYPE(QSharedPointer<ParticipantDeviceModel>)

#endif // PARTICIPANT_MODEL_H_
