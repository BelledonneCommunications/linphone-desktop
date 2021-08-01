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
#include "ParticipantImdnStateModel.hpp"

#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "components/core/CoreManager.hpp"

// =============================================================================

ParticipantImdnStateModel::ParticipantImdnStateModel (const std::shared_ptr<const linphone::ParticipantImdnState> imdn, QObject * parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	setState(LinphoneEnums::fromLinphone(imdn->getState()));
	setStateChangeTime(QDateTime::fromSecsSinceEpoch(imdn->getStateChangeTime())) ;
	mAddress = imdn->getParticipant()->getAddress()->clone();
}

// -----------------------------------------------------------------------------

LinphoneEnums::ChatMessageState ParticipantImdnStateModel::getState() const{
	return mState;
}

QDateTime ParticipantImdnStateModel::getStateChangeTime() const{
	return mStateChangeTime;
}

QString ParticipantImdnStateModel::getDisplayName() const{
	return Utils::getDisplayName(mAddress);
}
std::shared_ptr<const linphone::Address> ParticipantImdnStateModel::getAddress() const{
	return mAddress;
}


void ParticipantImdnStateModel::update(const std::shared_ptr<const linphone::ParticipantImdnState> imdn){
	setState(LinphoneEnums::fromLinphone(imdn->getState()));
	setStateChangeTime(QDateTime::fromSecsSinceEpoch(imdn->getStateChangeTime())) ;
}

void ParticipantImdnStateModel::setState(LinphoneEnums::ChatMessageState state){
	if(state != mState){
		mState = state;
		emit stateChanged();
	}
}

void ParticipantImdnStateModel::setStateChangeTime(const QDateTime& changeTime){
	if(changeTime != mStateChangeTime){
		mStateChangeTime = changeTime;
		emit stateChangeTimeChanged();
	}
}
