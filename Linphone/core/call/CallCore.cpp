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

#include "CallCore.hpp"
#include "core/App.hpp"
#include "model/object/VariantObject.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(CallCore)

QSharedPointer<CallCore> CallCore::create(const std::shared_ptr<linphone::Call> &call) {
	auto sharedPointer = QSharedPointer<CallCore>(new CallCore(call), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

CallCore::CallCore(const std::shared_ptr<linphone::Call> &call) : QObject(nullptr) {
	qDebug() << "[CallCore] new" << this;
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	// Should be call from model Thread
	mustBeInLinphoneThread(getClassName());
	mDuration = call->getDuration();
	mMicrophoneMuted = call->getMicrophoneMuted();
	mCallModel = Utils::makeQObject_ptr<CallModel>(call);
	connect(mCallModel.get(), &CallModel::stateChanged, this, &CallCore::onStateChanged);
	connect(this, &CallCore::lAccept, mCallModel.get(), &CallModel::accept);
	connect(this, &CallCore::lDecline, mCallModel.get(), &CallModel::decline);
	connect(this, &CallCore::lTerminate, mCallModel.get(), &CallModel::terminate);
	mCallModel->setSelf(mCallModel);
	mState = LinphoneEnums::fromLinphone(call->getState());
}

CallCore::~CallCore() {
	qDebug() << "[CallCore] delete" << this;
	mustBeInMainThread("~" + getClassName());
	emit mCallModel->removeListener();
}

void CallCore::setSelf(QSharedPointer<CallCore> me) {
	mAccountModelConnection = QSharedPointer<SafeConnection>(
	    new SafeConnection(me.objectCast<QObject>(), std::dynamic_pointer_cast<QObject>(mCallModel)),
	    &QObject::deleteLater);
	mAccountModelConnection->makeConnect(this, &CallCore::lSetMicrophoneMuted, [this](bool isMuted) {
		mAccountModelConnection->invokeToModel([this, isMuted]() { mCallModel->setMicrophoneMuted(isMuted); });
	});
	mAccountModelConnection->makeConnect(mCallModel.get(), &CallModel::microphoneMutedChanged, [this](bool isMuted) {
		mAccountModelConnection->invokeToCore([this, isMuted]() { setMicrophoneMuted(isMuted); });
	});
	mAccountModelConnection->makeConnect(mCallModel.get(), &CallModel::durationChanged, [this](int duration) {
		mAccountModelConnection->invokeToCore([this, duration]() { setDuration(duration); });
	});
}

LinphoneEnums::CallStatus CallCore::getStatus() const {
	return mStatus;
}

void CallCore::setStatus(LinphoneEnums::CallStatus status) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mStatus != status) {
		mStatus = status;
		emit statusChanged(mStatus);
	}
}

LinphoneEnums::CallState CallCore::getState() const {
	return mState;
}

void CallCore::setState(LinphoneEnums::CallState state, const QString &message) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mState != state) {
		mState = state;
		if (state == LinphoneEnums::CallState::Error) setLastErrorMessage(message);
		emit stateChanged(mState);
	}
}

void CallCore::onStateChanged(linphone::Call::State state, const std::string &message) {
	setState(LinphoneEnums::fromLinphone(state), Utils::coreStringToAppString(message));
}

QString CallCore::getLastErrorMessage() const {
	return mLastErrorMessage;
}
void CallCore::setLastErrorMessage(const QString &message) {
	if (mLastErrorMessage != message) {
		mLastErrorMessage = message;
		emit lastErrorMessageChanged();
	}
}

int CallCore::getDuration() {
	return mDuration;
}

void CallCore::setDuration(int duration) {
	if (mDuration != duration) {
		mDuration = duration;
		emit durationChanged(mDuration);
	}
}

bool CallCore::getMicrophoneMuted() const {
	return mMicrophoneMuted;
}

void CallCore::setMicrophoneMuted(bool isMuted) {
	if (mMicrophoneMuted != isMuted) {
		mMicrophoneMuted = isMuted;
		emit microphoneMutedChanged();
	}
}
