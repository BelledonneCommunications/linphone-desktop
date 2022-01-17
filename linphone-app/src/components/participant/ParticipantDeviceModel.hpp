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

class CallModel;

class ParticipantDeviceModel : public QObject {
    Q_OBJECT

public:
    ParticipantDeviceModel (std::shared_ptr<linphone::ParticipantDevice> device, const bool& isMe = false, QObject *parent = nullptr);
    ParticipantDeviceModel (CallModel * call, const bool& isMe = true, QObject *parent = nullptr);
	
	Q_PROPERTY(QString name READ getName CONSTANT)
	Q_PROPERTY(QString address READ getAddress CONSTANT)
	Q_PROPERTY(int securityLevel READ getSecurityLevel NOTIFY securityLevelChanged)
	Q_PROPERTY(time_t timeOfJoining READ getTimeOfJoining CONSTANT)
	Q_PROPERTY(bool videoEnabled READ isVideoEnabled NOTIFY videoEnabledChanged)
	Q_PROPERTY(bool isMe READ isMe CONSTANT)
  
	QString getName() const;
    QString getAddress() const;
	int getSecurityLevel() const;
	time_t getTimeOfJoining() const;
	bool isVideoEnabled() const;
	bool isMe() const;
	
	std::shared_ptr<linphone::ParticipantDevice>  getDevice();
	
	//void deviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	
public slots:
	void onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
signals:
	void securityLevelChanged();
	void videoEnabledChanged();

private:

	bool mIsMe = false;

    std::shared_ptr<linphone::ParticipantDevice> mParticipantDevice;
    CallModel * mCall;
	
};

//Q_DECLARE_METATYPE(ParticipantModel *);
Q_DECLARE_METATYPE(std::shared_ptr<ParticipantDeviceModel>)

#endif // PARTICIPANT_MODEL_H_
