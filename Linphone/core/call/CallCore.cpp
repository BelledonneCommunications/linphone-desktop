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
	mSpeakerMuted = call->getSpeakerMuted();
	mCameraEnabled = call->cameraEnabled();
	mDuration = call->getDuration();
	mState = LinphoneEnums::fromLinphone(call->getState());
	mPeerAddress = Utils::coreStringToAppString(mCallModel->getRemoteAddress()->asString());
	mStatus = LinphoneEnums::fromLinphone(call->getCallLog()->getStatus());
	mTransferState = LinphoneEnums::fromLinphone(call->getTransferState());
	mEncryption = LinphoneEnums::fromLinphone(call->getParams()->getMediaEncryption());
	auto tokenVerified = mCallModel->getAuthenticationTokenVerified();
	mIsSecured = (mEncryption == LinphoneEnums::MediaEncryption::Zrtp && tokenVerified) ||
	             mEncryption == LinphoneEnums::MediaEncryption::Srtp ||
	             mEncryption == LinphoneEnums::MediaEncryption::Dtls;
	mPaused = mState == LinphoneEnums::CallState::Pausing || mState == LinphoneEnums::CallState::Paused ||
	          mState == LinphoneEnums::CallState::PausedByRemote;
	mRecording = call->getParams() && call->getParams()->isRecording();
	mRemoteRecording = call->getRemoteParams() && call->getRemoteParams()->isRecording();
	mRecordable = mState == LinphoneEnums::CallState::StreamsRunning;
}

CallCore::~CallCore() {
	qDebug() << "[CallCore] delete" << this;
	mustBeInMainThread("~" + getClassName());
	emit mCallModel->removeListener();
}

void CallCore::setSelf(QSharedPointer<CallCore> me) {
	mCallModelConnection = QSharedPointer<SafeConnection<CallCore, CallModel>>(
	    new SafeConnection<CallCore, CallModel>(me, mCallModel), &QObject::deleteLater);
	mCallModelConnection->makeConnectToCore(&CallCore::lSetMicrophoneMuted, [this](bool isMuted) {
		mCallModelConnection->invokeToModel([this, isMuted]() { mCallModel->setMicrophoneMuted(isMuted); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::microphoneMutedChanged, [this](bool isMuted) {
		mCallModelConnection->invokeToCore([this, isMuted]() { setMicrophoneMuted(isMuted); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::remoteVideoEnabledChanged, [this](bool enabled) {
		mCallModelConnection->invokeToCore([this, enabled]() { setRemoteVideoEnabled(enabled); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lSetSpeakerMuted, [this](bool isMuted) {
		mCallModelConnection->invokeToModel([this, isMuted]() { mCallModel->setSpeakerMuted(isMuted); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::speakerMutedChanged, [this](bool isMuted) {
		mCallModelConnection->invokeToCore([this, isMuted]() { setSpeakerMuted(isMuted); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lSetCameraEnabled, [this](bool enabled) {
		mCallModelConnection->invokeToModel([this, enabled]() { mCallModel->setCameraEnabled(enabled); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lStartRecording, [this]() {
		mCallModelConnection->invokeToModel([this]() { mCallModel->startRecording(); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lStopRecording, [this]() {
		mCallModelConnection->invokeToModel([this]() { mCallModel->stopRecording(); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::recordingChanged, [this](bool recording) {
		mCallModelConnection->invokeToCore([this, recording]() { setRecording(recording); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lVerifyAuthenticationToken, [this](bool verified) {
		mCallModelConnection->invokeToModel(
		    [this, verified]() { mCallModel->setAuthenticationTokenVerified(verified); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::authenticationTokenVerifiedChanged, [this](bool verified) {
		mCallModelConnection->invokeToCore([this, verified]() { setIsSecured(verified); });
	});
	mCallModelConnection->makeConnectToModel(
	    &CallModel::remoteRecording, [this](const std::shared_ptr<linphone::Call> &call, bool recording) {
		    mCallModelConnection->invokeToCore([this, recording]() { setRemoteRecording(recording); });
	    });
	mCallModelConnection->makeConnectToModel(&CallModel::cameraEnabledChanged, [this](bool enabled) {
		mCallModelConnection->invokeToCore([this, enabled]() { setCameraEnabled(enabled); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::durationChanged, [this](int duration) {
		mCallModelConnection->invokeToCore([this, duration]() { setDuration(duration); });
	});
	mCallModelConnection->makeConnectToModel(
	    &CallModel::stateChanged, [this](linphone::Call::State state, const std::string &message) {
		    mCallModelConnection->invokeToCore([this, state, message]() {
			    setState(LinphoneEnums::fromLinphone(state), Utils::coreStringToAppString(message));
		    });
	    });
	mCallModelConnection->makeConnectToModel(&CallModel::statusChanged, [this](linphone::Call::Status status) {
		mCallModelConnection->invokeToCore([this, status]() { setStatus(LinphoneEnums::fromLinphone(status)); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::stateChanged,
	                                         [this](linphone::Call::State state, const std::string &message) {
		                                         mCallModelConnection->invokeToCore([this, state]() {
			                                         setRecordable(state == linphone::Call::State::StreamsRunning);
		                                         });
	                                         });
	mCallModelConnection->makeConnectToCore(&CallCore::lSetPaused, [this](bool paused) {
		mCallModelConnection->invokeToModel([this, paused]() { mCallModel->setPaused(paused); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::pausedChanged, [this](bool paused) {
		mCallModelConnection->invokeToCore([this, paused]() { setPaused(paused); });
	});

	mCallModelConnection->makeConnectToCore(&CallCore::lTransferCall, [this](const QString &address) {
		mCallModelConnection->invokeToModel(
		    [this, address]() { mCallModel->transferTo(ToolModel::interpretUrl(address)); });
	});
	mCallModelConnection->makeConnectToModel(
	    &CallModel::transferStateChanged,
	    [this](const std::shared_ptr<linphone::Call> &call, linphone::Call::State state) {
		    mCallModelConnection->invokeToCore([this, state]() {
			    QString message;
			    if (state == linphone::Call::State::Error) {
				    message = "L'appel n'a pas pu être transféré.";
			    }
			    setTransferState(LinphoneEnums::fromLinphone(state), message);
		    });
	    });
	mCallModelConnection->makeConnectToModel(
	    &CallModel::encryptionChanged,
	    [this](const std::shared_ptr<linphone::Call> &call, bool on, const std::string &authenticationToken) {
		    auto encryption = LinphoneEnums::fromLinphone(call->getCurrentParams()->getMediaEncryption());
		    auto tokenVerified = mCallModel->getAuthenticationTokenVerified();
		    auto token = Utils::coreStringToAppString(mCallModel->getAuthenticationToken());
		    mCallModelConnection->invokeToCore([this, call, encryption, tokenVerified, token]() {
			    auto localToken =
			        mDir == LinphoneEnums::CallDir::Incoming ? token.left(2).toUpper() : token.right(2).toUpper();
			    auto remoteToken =
			        mDir == LinphoneEnums::CallDir::Outgoing ? token.left(2).toUpper() : token.right(2).toUpper();
			    setLocalSas(localToken);
			    setRemoteSas(remoteToken);
			    setEncryption(encryption);
			    setIsSecured((encryption == LinphoneEnums::MediaEncryption::Zrtp && tokenVerified) ||
			                 encryption == LinphoneEnums::MediaEncryption::Srtp ||
			                 encryption == LinphoneEnums::MediaEncryption::Dtls);
		    });
	    });
	mCallModelConnection->makeConnectToCore(&CallCore::lAccept, [this](bool withVideo) {
		mCallModelConnection->invokeToModel([this, withVideo]() { mCallModel->accept(withVideo); });
	});
	mCallModelConnection->makeConnectToCore(
	    &CallCore::lDecline, [this]() { mCallModelConnection->invokeToModel([this]() { mCallModel->decline(); }); });
	mCallModelConnection->makeConnectToCore(&CallCore::lTerminate, [this]() {
		mCallModelConnection->invokeToModel([this]() { mCallModel->terminate(); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lTerminateAllCalls, [this]() {
		mCallModelConnection->invokeToModel([this]() { mCallModel->terminateAllCalls(); });
	});
}

QString CallCore::getPeerAddress() const {
	return mPeerAddress;
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

bool CallCore::getSpeakerMuted() const {
	return mSpeakerMuted;
}

void CallCore::setSpeakerMuted(bool isMuted) {
	if (mSpeakerMuted != isMuted) {
		mSpeakerMuted = isMuted;
		emit speakerMutedChanged();
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

bool CallCore::isSecured() const {
	return mIsSecured;
}

void CallCore::setIsSecured(bool secured) {
	if (mIsSecured != secured) {
		mIsSecured = secured;
		emit securityUpdated();
	}
}

QString CallCore::getLocalSas() {
	return mLocalSas;
}

QString CallCore::getRemoteSas() {
	return mRemoteSas;
}

void CallCore::setLocalSas(const QString &sas) {
	if (mLocalSas != sas) {
		mLocalSas = sas;
		emit localSasChanged();
	}
}

void CallCore::setRemoteSas(const QString &sas) {
	if (mRemoteSas != sas) {
		mRemoteSas = sas;
		emit remoteSasChanged();
	}
}

LinphoneEnums::MediaEncryption CallCore::getEncryption() const {
	return mEncryption;
}

void CallCore::setEncryption(LinphoneEnums::MediaEncryption encryption) {
	if (mEncryption != encryption) {
		mEncryption = encryption;
		emit securityUpdated();
	}
}

bool CallCore::getRemoteVideoEnabled() const {
	return mRemoteVideoEnabled;
}

void CallCore::setRemoteVideoEnabled(bool enabled) {
	if (mRemoteVideoEnabled != enabled) {
		mRemoteVideoEnabled = enabled;
		emit remoteVideoEnabledChanged(mRemoteVideoEnabled);
	}
}

bool CallCore::getRecording() const {
	return mRecording;
}
void CallCore::setRecording(bool recording) {
	if (mRecording != recording) {
		mRecording = recording;
		emit recordingChanged();
	}
}

bool CallCore::getRemoteRecording() const {
	return mRemoteRecording;
}
void CallCore::setRemoteRecording(bool recording) {
	if (mRemoteRecording != recording) {
		mRemoteRecording = recording;
		emit remoteRecordingChanged();
	}
}

bool CallCore::getRecordable() const {
	return mRecordable;
}
void CallCore::setRecordable(bool recordable) {
	if (mRecordable != recordable) {
		mRecordable = recordable;
		emit recordableChanged();
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

std::shared_ptr<CallModel> CallCore::getModel() const {
	return mCallModel;
}
