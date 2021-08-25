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

#ifndef PARTICIPANT_IMDN_STATE_MODEL_H_
#define PARTICIPANT_IMDN_STATE_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>

#include "utils/LinphoneEnums.hpp"

class ParticipantModel;

class ParticipantImdnStateModel : public QObject {
    Q_OBJECT

public:
    ParticipantImdnStateModel (const std::shared_ptr<const linphone::ParticipantImdnState> imdn, QObject * parent = nullptr);
	
	Q_PROPERTY(LinphoneEnums::ChatMessageState state MEMBER mState WRITE setState NOTIFY stateChanged)
	Q_PROPERTY(QDateTime stateChangeTime MEMBER mStateChangeTime WRITE setStateChangeTime NOTIFY stateChangeTimeChanged)
	Q_PROPERTY(QString displayName READ getDisplayName NOTIFY displayNameChanged)
  
	LinphoneEnums::ChatMessageState getState() const;
	QDateTime getStateChangeTime() const;
	QString getDisplayName() const;
	std::shared_ptr<const linphone::Address> getAddress() const;
	
	void update(const std::shared_ptr<const linphone::ParticipantImdnState> state);
	void setState(LinphoneEnums::ChatMessageState state);
	void setStateChangeTime(const QDateTime& changeTime);
	
signals:
	void stateChanged();
	void stateChangeTimeChanged();
	void displayNameChanged();


private:
    std::shared_ptr<linphone::Address> mAddress;
	LinphoneEnums::ChatMessageState mState;	
	QDateTime mStateChangeTime;
};

Q_DECLARE_METATYPE(std::shared_ptr<ParticipantImdnStateModel>);

#endif
