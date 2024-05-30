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
#include "core/conference/ConferenceCore.hpp"
#include "core/conference/ConferenceGui.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(CallCore)

QVariant createDeviceVariant(const QString &id, const QString &name) {
	QVariantMap map;
	map.insert("id", id);
	map.insert("name", name);
	return map;
}

QSharedPointer<CallCore> CallCore::create(const std::shared_ptr<linphone::Call> &call) {
	auto sharedPointer = QSharedPointer<CallCore>(new CallCore(call), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

CallCore::CallCore(const std::shared_ptr<linphone::Call> &call) : QObject(nullptr) {
	lDebug() << "[CallCore] new" << this;
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	// Should be call from model Thread
	mustBeInLinphoneThread(getClassName());
	mDir = LinphoneEnums::fromLinphone(call->getDir());
	mCallModel = Utils::makeQObject_ptr<CallModel>(call);
	mCallModel->setSelf(mCallModel);
	mDuration = call->getDuration();
	mMicrophoneMuted = call->getMicrophoneMuted();
	mSpeakerMuted = call->getSpeakerMuted();
	auto videoDirection = call->getCurrentParams()->getVideoDirection();
	mLocalVideoEnabled =
	    videoDirection == linphone::MediaDirection::SendOnly || videoDirection == linphone::MediaDirection::SendRecv;
	auto remoteParams = call->getRemoteParams();
	videoDirection = remoteParams ? remoteParams->getVideoDirection() : linphone::MediaDirection::Inactive;
	mRemoteVideoEnabled =
	    videoDirection == linphone::MediaDirection::SendOnly || videoDirection == linphone::MediaDirection::SendRecv;
	mState = LinphoneEnums::fromLinphone(call->getState());
	mPeerAddress = Utils::coreStringToAppString(call->getRemoteAddress()->asStringUriOnly());
	mLocalAddress = Utils::coreStringToAppString(call->getCallLog()->getLocalAddress()->asStringUriOnly());
	mStatus = LinphoneEnums::fromLinphone(call->getCallLog()->getStatus());
	mTransferState = LinphoneEnums::fromLinphone(call->getTransferState());
	auto token = Utils::coreStringToAppString(mCallModel->getAuthenticationToken());
	auto localToken = mDir == LinphoneEnums::CallDir::Incoming ? token.left(2).toUpper() : token.right(2).toUpper();
	auto remoteToken = mDir == LinphoneEnums::CallDir::Outgoing ? token.left(2).toUpper() : token.right(2).toUpper();
	mEncryption = LinphoneEnums::fromLinphone(call->getParams()->getMediaEncryption());
	auto tokenVerified = call->getAuthenticationTokenVerified();
	mLocalSas = localToken;
	mRemoteSas = remoteToken;
	mIsSecured = (mEncryption == LinphoneEnums::MediaEncryption::Zrtp && tokenVerified) ||
	             mEncryption == LinphoneEnums::MediaEncryption::Srtp ||
	             mEncryption == LinphoneEnums::MediaEncryption::Dtls;
	auto conference = call->getConference();
	mIsConference = conference != nullptr;
	if (mIsConference) {
		mConference = ConferenceCore::create(conference);
	}
	mPaused = mState == LinphoneEnums::CallState::Pausing || mState == LinphoneEnums::CallState::Paused ||
	          mState == LinphoneEnums::CallState::PausedByRemote;

	mRecording = call->getParams() && call->getParams()->isRecording();
	mRemoteRecording = call->getRemoteParams() && call->getRemoteParams()->isRecording();
	mSpeakerVolumeGain = mCallModel->getSpeakerVolumeGain();
	// TODO : change this with settings value when settings done
	if (mSpeakerVolumeGain < 0) {
		auto vol = CoreModel::getInstance()->getCore()->getPlaybackGainDb();
		call->setSpeakerVolumeGain(vol);
		mSpeakerVolumeGain = vol;
	}
	mMicrophoneVolumeGain = call->getMicrophoneVolumeGain();
	// TODO : change this with settings value when settings done
	if (mMicrophoneVolumeGain < 0) {
		auto vol = CoreModel::getInstance()->getCore()->getMicGainDb();
		call->setMicrophoneVolumeGain(vol);
		mMicrophoneVolumeGain = vol;
	}
	mMicrophoneVolume = call->getRecordVolume();
	mRecordable = mState == LinphoneEnums::CallState::StreamsRunning;
	mConferenceVideoLayout = mCallModel->getConferenceVideoLayout();
	auto videoSource = call->getVideoSource();
	mVideoSourceDescriptor = VideoSourceDescriptorCore::create(videoSource ? videoSource->clone() : nullptr);
}

CallCore::~CallCore() {
	lDebug() << "[CallCore] delete" << this;
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
	mCallModelConnection->makeConnectToCore(&CallCore::lSetLocalVideoEnabled, [this](bool enabled) {
		mCallModelConnection->invokeToModel([this, enabled]() { mCallModel->setLocalVideoEnabled(enabled); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lStartRecording, [this]() {
		mCallModelConnection->invokeToModel([this]() { mCallModel->startRecording(); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lStopRecording, [this]() {
		mCallModelConnection->invokeToModel([this]() { mCallModel->stopRecording(); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::recordingChanged, [this](bool recording) {
		mCallModelConnection->invokeToCore([this, recording]() {
			setRecording(recording);
			if (recording == false) {
				Utils::showInformationPopup(tr("Enregistrement terminé"),
				                            tr("L'appel a été enregistré dans le fichier : %1")
				                                .arg(QString::fromStdString(mCallModel->getRecordFile())),
				                            true, App::getInstance()->getCallsWindow());
			}
		});
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
	mCallModelConnection->makeConnectToModel(&CallModel::localVideoEnabledChanged, [this](bool enabled) {
		mCallModelConnection->invokeToCore([this, enabled]() { setLocalVideoEnabled(enabled); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::durationChanged, [this](int duration) {
		mCallModelConnection->invokeToCore([this, duration]() { setDuration(duration); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::speakerVolumeGainChanged, [this](float volume) {
		mCallModelConnection->invokeToCore([this, volume]() { setSpeakerVolumeGain(volume); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::microphoneVolumeGainChanged, [this](float volume) {
		mCallModelConnection->invokeToCore([this, volume]() { setMicrophoneVolumeGain(volume); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::microphoneVolumeChanged, [this](float volume) {
		mCallModelConnection->invokeToCore([this, volume]() { setMicrophoneVolume(volume); });
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
	mCallModelConnection->makeConnectToModel(
	    &CallModel::stateChanged, [this](linphone::Call::State state, const std::string &message) {
		    double speakerVolume = mSpeakerVolumeGain;
		    double micVolume = mMicrophoneVolumeGain;
		    if (state == linphone::Call::State::StreamsRunning) {
			    speakerVolume = mCallModel->getSpeakerVolumeGain();
			    if (speakerVolume < 0) {
				    speakerVolume = CoreModel::getInstance()->getCore()->getPlaybackGainDb();
			    }
			    micVolume = mCallModel->getMicrophoneVolumeGain();
			    if (micVolume < 0) {
				    micVolume = CoreModel::getInstance()->getCore()->getMicGainDb();
			    }
		    }
		    mCallModelConnection->invokeToCore([this, state, speakerVolume, micVolume]() {
			    setSpeakerVolumeGain(speakerVolume);
			    setMicrophoneVolumeGain(micVolume);
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
			    if (token.size() == 4) {
				    auto localToken =
				        mDir == LinphoneEnums::CallDir::Incoming ? token.left(2).toUpper() : token.right(2).toUpper();
				    auto remoteToken =
				        mDir == LinphoneEnums::CallDir::Outgoing ? token.left(2).toUpper() : token.right(2).toUpper();
				    setLocalSas(localToken);
				    setRemoteSas(remoteToken);
			    }
			    setEncryption(encryption);
			    setIsSecured((encryption == LinphoneEnums::MediaEncryption::Zrtp &&
			                  tokenVerified)); // ||
			                                   //  encryption == LinphoneEnums::MediaEncryption::Srtp ||
			                                   //  encryption == LinphoneEnums::MediaEncryption::Dtls);
			                                   // TODO : change this when api available in sdk
		    });
	    });
	mCallModelConnection->makeConnectToCore(&CallCore::lSetSpeakerVolumeGain, [this](float gain) {
		mCallModelConnection->invokeToModel([this, gain]() { mCallModel->setSpeakerVolumeGain(gain); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::speakerVolumeGainChanged, [this](float gain) {
		mCallModelConnection->invokeToCore([this, gain]() { setSpeakerVolumeGain(gain); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lSetMicrophoneVolumeGain, [this](float gain) {
		mCallModelConnection->invokeToModel([this, gain]() { mCallModel->setMicrophoneVolumeGain(gain); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::microphoneVolumeGainChanged, [this](float gain) {
		mCallModelConnection->invokeToCore([this, gain]() { setMicrophoneVolumeGain(gain); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lSetInputAudioDevice, [this](QString id) {
		mCallModelConnection->invokeToModel([this, id]() {
			if (auto device = ToolModel::findAudioDevice(id)) {
				mCallModel->setInputAudioDevice(device);
			}
		});
	});
	mCallModelConnection->makeConnectToModel(&CallModel::inputAudioDeviceChanged, [this](const std::string &id) {
		mCallModelConnection->invokeToCore([this, id]() {});
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lSetOutputAudioDevice, [this](QString id) {
		mCallModelConnection->invokeToModel([this, id]() {
			if (auto device = ToolModel::findAudioDevice(id)) {
				mCallModel->setOutputAudioDevice(device);
			}
		});
	});
	mCallModelConnection->makeConnectToModel(&CallModel::conferenceChanged, [this]() {
		auto conference = mCallModel->getMonitor()->getConference();
		QSharedPointer<ConferenceCore> core = conference ? ConferenceCore::create(conference) : nullptr;
		mCallModelConnection->invokeToCore([this, core]() { setConference(core); });
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
	mCallModelConnection->makeConnectToModel(
	    &CallModel::conferenceVideoLayoutChanged, [this](LinphoneEnums::ConferenceLayout layout) {
		    mCallModelConnection->invokeToCore([this, layout]() { setConferenceVideoLayout(layout); });
	    });
	mCallModelConnection->makeConnectToCore(
	    &CallCore::lSetConferenceVideoLayout, [this](LinphoneEnums::ConferenceLayout layout) {
		    mCallModelConnection->invokeToModel([this, layout]() { mCallModel->changeConferenceVideoLayout(layout); });
	    });
	mCallModelConnection->makeConnectToCore(
	    &CallCore::lSetVideoSourceDescriptor, [this](VideoSourceDescriptorGui *gui) {
		    mCallModelConnection->invokeToModel(
		        [this, model = gui->getCore()->getModel()]() { mCallModel->setVideoSourceDescriptorModel(model); });
	    });

	mCallModelConnection->makeConnectToModel(&CallModel::videoDescriptorChanged, [this]() {
		auto videoSource = mCallModel->getMonitor()->getVideoSource();
		auto core = VideoSourceDescriptorCore::create(videoSource ? videoSource->clone() : nullptr);
		mCallModelConnection->invokeToCore([this, core]() { setVideoSourceDescriptor(core); });
	});
}

QString CallCore::getPeerAddress() const {
	return mPeerAddress;
}

QString CallCore::getLocalAddress() const {
	return mLocalAddress;
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
		if (state == LinphoneEnums::CallState::Error) {
			lDebug() << "[CallCore] Error message : " << message;
			setLastErrorMessage(message);
		}
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

bool CallCore::getLocalVideoEnabled() const {
	return mLocalVideoEnabled;
}

void CallCore::setLocalVideoEnabled(bool enabled) {
	if (mLocalVideoEnabled != enabled) {
		mLocalVideoEnabled = enabled;
		lDebug() << "LocalVideoEnabled: " << mLocalVideoEnabled;
		emit localVideoEnabledChanged();
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

bool CallCore::isConference() const {
	return mIsConference;
}

ConferenceGui *CallCore::getConferenceGui() const {
	return mConference ? new ConferenceGui(mConference) : nullptr;
}

QSharedPointer<ConferenceCore> CallCore::getConferenceCore() const {
	return mConference;
}

void CallCore::setConference(const QSharedPointer<ConferenceCore> &conference) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mConference != conference) {
		mConference = conference;
		mIsConference = (mConference != nullptr);
		lDebug() << "[CallCore] Set conference : " << mConference;
		emit conferenceChanged();
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

float CallCore::getSpeakerVolumeGain() const {
	return mSpeakerVolumeGain;
}
void CallCore::setSpeakerVolumeGain(float gain) {
	if (mSpeakerVolumeGain != gain) {
		mSpeakerVolumeGain = gain;
		emit speakerVolumeGainChanged();
	}
}

float CallCore::getMicrophoneVolume() const {
	return mMicrophoneVolume;
}
void CallCore::setMicrophoneVolume(float vol) {
	if (mMicrophoneVolume != vol) {
		mMicrophoneVolume = vol;
		emit microphoneVolumeChanged();
	}
}

float CallCore::getMicrophoneVolumeGain() const {
	return mMicrophoneVolumeGain;
}
void CallCore::setMicrophoneVolumeGain(float gain) {
	if (mMicrophoneVolumeGain != gain) {
		mMicrophoneVolumeGain = gain;
		emit microphoneVolumeGainChanged();
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

LinphoneEnums::ConferenceLayout CallCore::getConferenceVideoLayout() const {
	return mConferenceVideoLayout;
}

VideoSourceDescriptorGui *CallCore::getVideoSourceDescriptorGui() const {
	return new VideoSourceDescriptorGui(mVideoSourceDescriptor);
}

void CallCore::setVideoSourceDescriptor(QSharedPointer<VideoSourceDescriptorCore> core) {
	if (mVideoSourceDescriptor != core) {
		mVideoSourceDescriptor = core;
		emit videoSourceDescriptorChanged();
	}
}

void CallCore::setConferenceVideoLayout(LinphoneEnums::ConferenceLayout layout) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mConferenceVideoLayout != layout) {
		mConferenceVideoLayout = layout;
		emit conferenceVideoLayoutChanged();
	}
}

std::shared_ptr<CallModel> CallCore::getModel() const {
	return mCallModel;
}
