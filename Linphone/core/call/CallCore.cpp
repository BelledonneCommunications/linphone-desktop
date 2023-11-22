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
#include "model/tool/ToolModel.hpp"
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
	mDir = LinphoneEnums::fromLinphone(call->getDir());
	mCallModel = Utils::makeQObject_ptr<CallModel>(call);
	mCallModel->setSelf(mCallModel);
	mDuration = call->getDuration();
	mMicrophoneMuted = call->getMicrophoneMuted();
	// mSpeakerMuted = call->getSpeakerMuted();
	mCameraEnabled = call->cameraEnabled();
	mDuration = call->getDuration();
	mState = LinphoneEnums::fromLinphone(call->getState());
	mPeerAddress = Utils::coreStringToAppString(mCallModel->getRemoteAddress()->asString());
	mStatus = LinphoneEnums::fromLinphone(call->getCallLog()->getStatus());
	mTransferState = LinphoneEnums::fromLinphone(call->getTransferState());
	auto encryption = LinphoneEnums::fromLinphone(call->getCurrentParams()->getMediaEncryption());
	auto tokenVerified = mCallModel->getAuthenticationTokenVerified();
	mPeerSecured = (encryption == LinphoneEnums::MediaEncryption::Zrtp && tokenVerified) ||
	               encryption == LinphoneEnums::MediaEncryption::Srtp ||
	               encryption == LinphoneEnums::MediaEncryption::Dtls;
	mPaused = mState == LinphoneEnums::CallState::Pausing || mState == LinphoneEnums::CallState::Paused ||
	          mState == LinphoneEnums::CallState::PausedByRemote;
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
	// mAccountModelConnection->makeConnect(this, &CallCore::lSetSpeakerMuted, [this](bool isMuted) {
	// 	mAccountModelConnection->invokeToModel([this, isMuted]() { mCallModel->setSpeakerMuted(isMuted); });
	// });
	// mAccountModelConnection->makeConnect(mCallModel.get(), &CallModel::speakerMutedChanged, [this](bool isMuted) {
	// 	mAccountModelConnection->invokeToCore([this, isMuted]() { setSpeakerMuted(isMuted); });
	// });
	mAccountModelConnection->makeConnect(this, &CallCore::lSetCameraEnabled, [this](bool enabled) {
		mAccountModelConnection->invokeToModel([this, enabled]() { mCallModel->setCameraEnabled(enabled); });
	});
	mAccountModelConnection->makeConnect(mCallModel.get(), &CallModel::cameraEnabledChanged, [this](bool enabled) {
		mAccountModelConnection->invokeToCore([this, enabled]() { setCameraEnabled(enabled); });
	});
	mAccountModelConnection->makeConnect(mCallModel.get(), &CallModel::durationChanged, [this](int duration) {
		mAccountModelConnection->invokeToCore([this, duration]() { setDuration(duration); });
	});
	connect(mCallModel.get(), &CallModel::stateChanged, this,
	        [this](linphone::Call::State state, const std::string &message) {
		        mAccountModelConnection->invokeToCore([this, state, message]() {
			        setState(LinphoneEnums::fromLinphone(state), Utils::coreStringToAppString(message));
		        });
	        });
	connect(mCallModel.get(), &CallModel::statusChanged, this, [this](linphone::Call::Status status) {
		mAccountModelConnection->invokeToCore([this, status]() { setStatus(LinphoneEnums::fromLinphone(status)); });
	});
	mAccountModelConnection->makeConnect(this, &CallCore::lSetPaused, [this](bool paused) {
		mAccountModelConnection->invokeToModel([this, paused]() { mCallModel->setPaused(paused); });
	});
	mAccountModelConnection->makeConnect(mCallModel.get(), &CallModel::pausedChanged, [this](bool paused) {
		mAccountModelConnection->invokeToCore([this, paused]() { setPaused(paused); });
	});

	mAccountModelConnection->makeConnect(this, &CallCore::lTransferCall, [this](const QString &address) {
		mAccountModelConnection->invokeToModel(
		    [this, address]() { mCallModel->transferTo(ToolModel::interpretUrl(address)); });
	});
	mAccountModelConnection->makeConnect(
	    mCallModel.get(), &CallModel::transferStateChanged,
	    [this](const std::shared_ptr<linphone::Call> &call, linphone::Call::State state) {
		    mAccountModelConnection->invokeToCore([this, state]() {
			    QString message;
			    if (state == linphone::Call::State::Error) {
				    message = "L'appel n'a pas pu être transféré.";
			    }
			    setTransferState(LinphoneEnums::fromLinphone(state), message);
		    });
	    });
	mAccountModelConnection->makeConnect(
	    mCallModel.get(), &CallModel::encryptionChanged,
	    [this](const std::shared_ptr<linphone::Call> &call, bool on, const std::string &authenticationToken) {
		    auto encryption = LinphoneEnums::fromLinphone(call->getCurrentParams()->getMediaEncryption());
		    auto tokenVerified = mCallModel->getAuthenticationTokenVerified();
		    mAccountModelConnection->invokeToCore([this, call, encryption, tokenVerified]() {
			    setPeerSecured((encryption == LinphoneEnums::MediaEncryption::Zrtp && tokenVerified) ||
			                   encryption == LinphoneEnums::MediaEncryption::Srtp ||
			                   encryption == LinphoneEnums::MediaEncryption::Dtls);
		    });
	    });
	mAccountModelConnection->makeConnect(this, &CallCore::lAccept, [this](bool withVideo) {
		mAccountModelConnection->invokeToModel([this, withVideo]() { mCallModel->accept(withVideo); });
	});
	mAccountModelConnection->makeConnect(this, &CallCore::lDecline, [this]() {
		mAccountModelConnection->invokeToModel([this]() { mCallModel->decline(); });
	});
	mAccountModelConnection->makeConnect(this, &CallCore::lTerminate, [this]() {
		mAccountModelConnection->invokeToModel([this]() { mCallModel->terminate(); });
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

LinphoneEnums::CallDir CallCore::getDir() const {
	return mDir;
}

void CallCore::setDir(LinphoneEnums::CallDir dir) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mDir != dir) {
		mDir = dir;
		emit dirChanged(mDir);
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

bool CallCore::getCameraEnabled() const {
	return mCameraEnabled;
}

void CallCore::setCameraEnabled(bool enabled) {
	if (mCameraEnabled != enabled) {
		mCameraEnabled = enabled;
		emit cameraEnabledChanged();
	}
}

bool CallCore::getPaused() const {
	return mPaused;
}

void CallCore::setPaused(bool paused) {
	if (mPaused != paused) {
		mPaused = paused;
		emit pausedChanged();
	}
}

bool CallCore::getPeerSecured() const {
	return mPeerSecured;
}
void CallCore::setPeerSecured(bool secured) {
	if (mPeerSecured != secured) {
		mPeerSecured = secured;
		emit peerSecuredChanged();
	}
}

LinphoneEnums::CallState CallCore::getTransferState() const {
	return mTransferState;
}

void CallCore::setTransferState(LinphoneEnums::CallState state, const QString &message) {
	if (mTransferState != state) {
		mTransferState = state;
		if (state == LinphoneEnums::CallState::Error) setLastErrorMessage(message);
		emit transferStateChanged();
	}
}