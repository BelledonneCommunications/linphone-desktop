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

#include "Call.hpp"
#include "core/App.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(Call)

Call::Call(const std::shared_ptr<linphone::Call> &call) : QObject(nullptr) {
	// Should be call from model Thread
	mustBeInLinphoneThread(getClassName());
	mCallModel = Utils::makeQObject_ptr<CallModel>(call);
	connect(mCallModel.get(), &CallModel::stateChanged, this, &Call::onStateChanged);
	connect(this, &Call::lAccept, mCallModel.get(), &CallModel::accept);
	connect(this, &Call::lDecline, mCallModel.get(), &CallModel::decline);
	connect(this, &Call::lTerminate, mCallModel.get(), &CallModel::terminate);
	mCallModel->setSelf(mCallModel);
	mState = LinphoneEnums::fromLinphone(call->getState());
}

Call::~Call() {
	mustBeInMainThread("~" + getClassName());
	emit mCallModel->removeListener();
}

LinphoneEnums::CallStatus Call::getStatus() const {
	return mStatus;
}

void Call::setStatus(LinphoneEnums::CallStatus status) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mStatus != status) {
		mStatus = status;
		emit statusChanged(mStatus);
	}
}

LinphoneEnums::CallState Call::getState() const {
	return mState;
}

void Call::setState(LinphoneEnums::CallState state, const QString &message) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mState != state) {
		mState = state;
		if (state == LinphoneEnums::CallState::Error) setLastErrorMessage(message);
		emit stateChanged(mState);
	}
}

void Call::onStateChanged(linphone::Call::State state, const std::string &message) {
	setState(LinphoneEnums::fromLinphone(state), Utils::coreStringToAppString(message));
}

QString Call::getLastErrorMessage() const {
	return mLastErrorMessage;
}
void Call::setLastErrorMessage(const QString &message) {
	if (mLastErrorMessage != message) {
		mLastErrorMessage = message;
		emit lastErrorMessageChanged();
	}
}
