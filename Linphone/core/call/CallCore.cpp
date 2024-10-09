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
#include "core/setting/SettingsCore.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(CallCore)

/***********************************************************************/

ZrtpStats ZrtpStats::operator=(ZrtpStats s) {
	mCipherAlgorithm = s.mCipherAlgorithm;
	mKeyAgreementAlgorithm = s.mKeyAgreementAlgorithm;
	mHashAlgorithm = s.mHashAlgorithm;
	mAuthenticationAlgorithm = s.mAuthenticationAlgorithm;
	mSasAlgorithm = s.mSasAlgorithm;
	mIsPostQuantum = s.mIsPostQuantum;
	return *this;
}

bool ZrtpStats::operator==(ZrtpStats s) {
	return s.mCipherAlgorithm == mCipherAlgorithm && s.mKeyAgreementAlgorithm == mKeyAgreementAlgorithm &&
	       s.mHashAlgorithm == mHashAlgorithm && s.mAuthenticationAlgorithm == mAuthenticationAlgorithm &&
	       s.mSasAlgorithm == mSasAlgorithm && s.mIsPostQuantum == mIsPostQuantum;
}
bool ZrtpStats::operator!=(ZrtpStats s) {
	return s.mCipherAlgorithm != mCipherAlgorithm || s.mKeyAgreementAlgorithm != mKeyAgreementAlgorithm ||
	       s.mHashAlgorithm != mHashAlgorithm || s.mAuthenticationAlgorithm != mAuthenticationAlgorithm ||
	       s.mSasAlgorithm != mSasAlgorithm || s.mIsPostQuantum != mIsPostQuantum;
}

AudioStats AudioStats::operator=(AudioStats s) {
	mCodec = s.mCodec;
	mBandwidth = s.mBandwidth;
	mJitterBufferSize = s.mJitterBufferSize;
	mLossRate = s.mLossRate;
	return *this;
}

bool AudioStats::operator==(AudioStats s) {
	return s.mCodec == mCodec && s.mBandwidth == mBandwidth && s.mLossRate == mLossRate &&
	       s.mJitterBufferSize == mJitterBufferSize;
}
bool AudioStats::operator!=(AudioStats s) {
	return s.mCodec != mCodec || s.mBandwidth != mBandwidth || s.mLossRate != mLossRate ||
	       s.mJitterBufferSize != mJitterBufferSize;
}

VideoStats VideoStats::operator=(VideoStats s) {
	mCodec = s.mCodec;
	mBandwidth = s.mBandwidth;
	mResolution = s.mResolution;
	mFps = s.mFps;
	mLossRate = s.mLossRate;
	return *this;
}

bool VideoStats::operator==(VideoStats s) {
	return s.mCodec == mCodec && s.mBandwidth == mBandwidth && s.mResolution == mResolution && s.mFps == mFps &&
	       s.mLossRate == mLossRate;
}
bool VideoStats::operator!=(VideoStats s) {
	return s.mCodec != mCodec || s.mBandwidth != mBandwidth || s.mResolution != mResolution || s.mFps != mFps ||
	       s.mLossRate != mLossRate;
}

/***********************************************************************/

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
	mLocalToken = Utils::coreStringToAppString(mCallModel->getLocalAtuhenticationToken());
	mRemoteTokens = mCallModel->getRemoteAtuhenticationTokens();
	mEncryption = LinphoneEnums::fromLinphone(call->getParams()->getMediaEncryption());
	auto tokenVerified = call->getAuthenticationTokenVerified();
	mIsSecured = (mEncryption == LinphoneEnums::MediaEncryption::Zrtp && tokenVerified) ||
	             mEncryption == LinphoneEnums::MediaEncryption::Srtp ||
	             mEncryption == LinphoneEnums::MediaEncryption::Dtls;
	if (mEncryption == LinphoneEnums::MediaEncryption::Zrtp) {
		auto stats = call->getStats(linphone::StreamType::Audio);
		if (stats) {
			mZrtpStats.mCipherAlgorithm = Utils::coreStringToAppString(stats->getZrtpCipherAlgo());
			mZrtpStats.mKeyAgreementAlgorithm = Utils::coreStringToAppString(stats->getZrtpKeyAgreementAlgo());
			mZrtpStats.mHashAlgorithm = Utils::coreStringToAppString(stats->getZrtpHashAlgo());
			mZrtpStats.mAuthenticationAlgorithm = Utils::coreStringToAppString(stats->getZrtpAuthTagAlgo());
			mZrtpStats.mSasAlgorithm = Utils::coreStringToAppString(stats->getZrtpSasAlgo());
		}
	}
	auto conference = call->getConference();
	mIsConference = conference != nullptr;
	if (mIsConference) {
		mConference = ConferenceCore::create(conference);
	}
	mPaused = mState == LinphoneEnums::CallState::Pausing || mState == LinphoneEnums::CallState::Paused ||
	          mState == LinphoneEnums::CallState::PausedByRemote;

	mRecording = call->getParams() && call->getParams()->isRecording();
	mRemoteRecording = call->getRemoteParams() && call->getRemoteParams()->isRecording();
	auto settingsModel = SettingsModel::getInstance();
	mSpeakerVolumeGain = mCallModel->getSpeakerVolumeGain();
	if (mSpeakerVolumeGain < 0) {
		mSpeakerVolumeGain = settingsModel->getPlaybackGain();
	}
	mMicrophoneVolumeGain = call->getMicrophoneVolumeGain();
	if (mMicrophoneVolumeGain < 0) {
		mMicrophoneVolumeGain = settingsModel->getCaptureGain();
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
	mCallModelConnection->makeConnectToModel(
	    &CallModel::recordingChanged, [this](const std::shared_ptr<linphone::Call> &call, bool recording) {
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
	mCallModelConnection->makeConnectToCore(&CallCore::lCheckAuthenticationTokenSelected, [this](const QString &token) {
		mCallModelConnection->invokeToModel([this, token]() { mCallModel->checkAuthenticationToken(token); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lSkipZrtpAuthentication, [this]() {
		mCallModelConnection->invokeToModel([this]() { mCallModel->skipZrtpAuthentication(); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::authenticationTokenVerified,
	                                         [this](const std::shared_ptr<linphone::Call> &call, bool verified) {
		                                         auto isMismatch = mCallModel->getZrtpCaseMismatch();
		                                         mCallModelConnection->invokeToCore([this, verified, isMismatch]() {
			                                         setTokenVerified(verified);
			                                         emit tokenVerified();
		                                         });
	                                         });
	mCallModelConnection->makeConnectToModel(&CallModel::remoteRecording,
	                                         [this](const std::shared_ptr<linphone::Call> &call, bool recording) {
		                                         bool confRecording = false;
		                                         if (call->getConference()) {
			                                         confRecording = call->getConference()->isRecording();
		                                         }
		                                         mCallModelConnection->invokeToCore([this, recording, confRecording]() {
			                                         if (mConference) mConference->setRecording(confRecording);
			                                         setRemoteRecording(recording);
		                                         });
	                                         });
	mCallModelConnection->makeConnectToModel(&CallModel::localVideoEnabledChanged, [this](bool enabled) {
		mCallModelConnection->invokeToCore([this, enabled]() { setLocalVideoEnabled(enabled); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::durationChanged, [this](int duration) {
		mCallModelConnection->invokeToCore([this, duration]() { setDuration(duration); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::qualityUpdated, [this](float quality) {
		mCallModelConnection->invokeToCore([this, quality]() { setCurrentQuality(quality); });
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
	    &CallModel::errorMessageChanged, [this](const QString &errorMessage) { setLastErrorMessage(errorMessage); });
	mCallModelConnection->makeConnectToModel(&CallModel::stateChanged, [this](std::shared_ptr<linphone::Call> call,
	                                                                          linphone::Call::State state,
	                                                                          const std::string &message) {
		double speakerVolume = mSpeakerVolumeGain;
		double micVolumeGain = mMicrophoneVolumeGain;
		if (state == linphone::Call::State::StreamsRunning) {
			speakerVolume = mCallModel->getSpeakerVolumeGain();
			if (speakerVolume < 0) {
				speakerVolume = CoreModel::getInstance()->getCore()->getPlaybackGainDb();
			}
			micVolumeGain = mCallModel->getMicrophoneVolumeGain();
			if (micVolumeGain < 0) {
				micVolumeGain = CoreModel::getInstance()->getCore()->getMicGainDb();
			}
		}
		auto subject = call->getConference() ? Utils::coreStringToAppString(call->getConference()->getSubject()) : "";
		mCallModelConnection->invokeToCore([this, state, speakerVolume, micVolumeGain, subject]() {
			setSpeakerVolumeGain(speakerVolume);
			setMicrophoneVolumeGain(micVolumeGain);
			setRecordable(state == linphone::Call::State::StreamsRunning);
			setPaused(state == linphone::Call::State::Paused || state == linphone::Call::State::PausedByRemote);
			if (mConference) mConference->setSubject(subject);
		});
		mCallModelConnection->invokeToCore([this, state, message]() { setState(LinphoneEnums::fromLinphone(state)); });
	});
	mCallModelConnection->makeConnectToModel(&CallModel::statusChanged, [this](linphone::Call::Status status) {
		mCallModelConnection->invokeToCore([this, status]() { setStatus(LinphoneEnums::fromLinphone(status)); });
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lSetPaused, [this](bool paused) {
		mCallModelConnection->invokeToModel([this, paused]() { mCallModel->setPaused(paused); });
	});

	mCallModelConnection->makeConnectToCore(&CallCore::lTransferCall, [this](QString address) {
		mCallModelConnection->invokeToModel([this, address]() {
			auto linAddr = ToolModel::interpretUrl(address);
			if (linAddr) mCallModel->transferTo(linAddr);
		});
	});
	mCallModelConnection->makeConnectToModel(
	    &CallModel::transferStateChanged,
	    [this](const std::shared_ptr<linphone::Call> &call, linphone::Call::State state) {
		    mCallModelConnection->invokeToCore(
		        [this, state]() { setTransferState(LinphoneEnums::fromLinphone(state)); });
	    });
	mCallModelConnection->makeConnectToModel(
	    &CallModel::encryptionChanged,
	    [this](const std::shared_ptr<linphone::Call> &call, bool on, const std::string &authenticationToken) {
		    auto encryption = LinphoneEnums::fromLinphone(call->getCurrentParams()->getMediaEncryption());
		    auto tokenVerified = mCallModel->getAuthenticationTokenVerified();
		    auto isCaseMismatch = mCallModel->getZrtpCaseMismatch();
		    auto localToken = Utils::coreStringToAppString(mCallModel->getLocalAtuhenticationToken());
		    QStringList remoteTokens = mCallModel->getRemoteAtuhenticationTokens();
		    mCallModelConnection->invokeToCore(
		        [this, call, encryption, tokenVerified, localToken, remoteTokens, isCaseMismatch]() {
			        setLocalToken(localToken);
			        setRemoteTokens(remoteTokens);
			        setEncryption(encryption);
			        setIsMismatch(isCaseMismatch);
			        setTokenVerified(tokenVerified);
		        });
		    auto mediaEncryption = call->getParams()->getMediaEncryption();
		    if (mediaEncryption == linphone::MediaEncryption::ZRTP) {
			    auto stats = call->getAudioStats();
			    ZrtpStats zrtpStats;
			    zrtpStats.mCipherAlgorithm = Utils::coreStringToAppString(stats->getZrtpCipherAlgo());
			    zrtpStats.mKeyAgreementAlgorithm = Utils::coreStringToAppString(stats->getZrtpKeyAgreementAlgo());
			    zrtpStats.mHashAlgorithm = Utils::coreStringToAppString(stats->getZrtpHashAlgo());
			    zrtpStats.mAuthenticationAlgorithm = Utils::coreStringToAppString(stats->getZrtpAuthTagAlgo());
			    zrtpStats.mSasAlgorithm = Utils::coreStringToAppString(stats->getZrtpSasAlgo());
			    mCallModelConnection->invokeToCore([this, zrtpStats]() { setZrtpStats(zrtpStats); });
		    }
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
	mCallModelConnection->makeConnectToCore(&CallCore::lSendDtmf, [this](QString dtmf) {
		mCallModelConnection->invokeToModel([this, dtmf]() { mCallModel->sendDtmf(dtmf); });
	});

	mCallModelConnection->makeConnectToModel(&CallModel::videoDescriptorChanged, [this]() {
		auto videoSource = mCallModel->getMonitor()->getVideoSource();
		auto core = VideoSourceDescriptorCore::create(videoSource ? videoSource->clone() : nullptr);
		mCallModelConnection->invokeToCore([this, core]() { setVideoSourceDescriptor(core); });
	});
	mCallModelConnection->makeConnectToModel(
	    &CallModel::statsUpdated,
	    [this](const std::shared_ptr<linphone::Call> &call, const std::shared_ptr<const linphone::CallStats> &stats) {
		    if (stats->getType() == linphone::StreamType::Audio) {
			    AudioStats audioStats;
			    auto playloadType = call->getCurrentParams()->getUsedAudioPayloadType();
			    auto codecType = playloadType ? playloadType->getMimeType() : "";
			    auto codecRate = playloadType ? playloadType->getClockRate() / 1000 : 0;
			    audioStats.mCodec =
			        tr("Codec: %1 / %2 kHz").arg(Utils::coreStringToAppString(codecType)).arg(codecRate);
			    auto linAudioStats = call->getAudioStats();
			    if (linAudioStats) {
				    audioStats.mBandwidth = tr("Bande passante : %1 %2 %3 %4")
				                                .arg("↑")
				                                .arg(linAudioStats->getUploadBandwidth())
				                                .arg("↓")
				                                .arg(linAudioStats->getDownloadBandwidth());
				    audioStats.mLossRate = tr("Taux de perte: %1 \% %2 \%")
				                               .arg(linAudioStats->getSenderLossRate())
				                               .arg(linAudioStats->getReceiverLossRate());
				    audioStats.mJitterBufferSize =
				        tr("Tampon de gigue: %1 ms").arg(linAudioStats->getJitterBufferSizeMs());
			    }
			    setAudioStats(audioStats);
		    } else if (stats->getType() == linphone::StreamType::Video) {
			    VideoStats videoStats;
			    auto params = call->getCurrentParams();
			    auto playloadType = params->getUsedVideoPayloadType();
			    auto codecType = playloadType ? playloadType->getMimeType() : "";
			    auto codecRate = playloadType ? playloadType->getClockRate() / 1000 : 0;
			    videoStats.mCodec =
			        tr("Codec: %1 / %2 kHz").arg(Utils::coreStringToAppString(codecType)).arg(codecRate);
			    auto linVideoStats = call->getVideoStats();
			    if (stats) {
				    videoStats.mBandwidth = tr("Bande passante : %1 %2 %3 %4")
				                                .arg("↑")
				                                .arg(linVideoStats->getUploadBandwidth())
				                                .arg("↓")
				                                .arg(linVideoStats->getDownloadBandwidth());
				    videoStats.mLossRate = tr("Taux de perte: %1 \% %2 \%")
				                               .arg(linVideoStats->getSenderLossRate())
				                               .arg(linVideoStats->getReceiverLossRate());
			    }
			    auto sentResolution =
			        params->getSentVideoDefinition() ? params->getSentVideoDefinition()->getName() : "";
			    auto receivedResolution =
			        params->getReceivedVideoDefinition() ? params->getReceivedVideoDefinition()->getName() : "";
			    videoStats.mResolution = tr("Définition vidéo : %1 %2 %3 %4")
			                                 .arg("↑", Utils::coreStringToAppString(sentResolution), "↓",
			                                      Utils::coreStringToAppString(receivedResolution));
			    auto sentFps = params->getSentFramerate();
			    auto receivedFps = params->getReceivedFramerate();
			    videoStats.mFps = tr("FPS : %1 %2 %3 %4").arg("↑").arg(sentFps).arg("↓").arg(receivedFps);
			    setVideoStats(videoStats);
		    }
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

void CallCore::setState(LinphoneEnums::CallState state) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mState != state) {
		mState = state;
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

int CallCore::getDuration() const {
	return mDuration;
}

void CallCore::setDuration(int duration) {
	if (mDuration != duration) {
		mDuration = duration;
		emit durationChanged(mDuration);
	}
}

float CallCore::getCurrentQuality() const {
	return mQuality;
}

void CallCore::setCurrentQuality(float quality) {
	if (mQuality != quality) {
		mQuality = quality;
		emit qualityChanged(mQuality);
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

bool CallCore::getTokenVerified() const {
	return mTokenVerified;
}

void CallCore::setTokenVerified(bool verified) {
	if (mTokenVerified != verified) {
		mTokenVerified = verified;
		emit securityUpdated();
	}
}

bool CallCore::isMismatch() const {
	return mIsMismatch;
}

void CallCore::setIsMismatch(bool mismatch) {
	if (mIsMismatch != mismatch) {
		mIsMismatch = mismatch;
		emit securityUpdated();
	}
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

bool CallCore::isConference() const {
	return mIsConference;
}

QString CallCore::getLocalToken() {
	return mLocalToken;
}

QStringList CallCore::getRemoteTokens() {
	return mRemoteTokens;
}

void CallCore::setLocalToken(const QString &Token) {
	if (mLocalToken != Token) {
		mLocalToken = Token;
		emit localTokenChanged();
	}
}

void CallCore::setRemoteTokens(const QStringList &token) {
	if (mRemoteTokens != token) {
		mRemoteTokens = token;
		emit remoteTokensChanged();
	}
}

LinphoneEnums::MediaEncryption CallCore::getEncryption() const {
	return mEncryption;
}

QString CallCore::getEncryptionString() const {
	return LinphoneEnums::toString(mEncryption);
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

void CallCore::setTransferState(LinphoneEnums::CallState state) {
	if (mTransferState != state) {
		mTransferState = state;
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

ZrtpStats CallCore::getZrtpStats() const {
	return mZrtpStats;
}

void CallCore::setZrtpStats(ZrtpStats stats) {
	if (stats != mZrtpStats) {
		mZrtpStats = stats;
		emit zrtpStatsChanged();
	}
}

AudioStats CallCore::getAudioStats() const {
	return mAudioStats;
}

void CallCore::setAudioStats(AudioStats stats) {
	if (stats != mAudioStats) {
		mAudioStats = stats;
		emit audioStatsChanged();
	}
}

VideoStats CallCore::getVideoStats() const {
	return mVideoStats;
}

void CallCore::setVideoStats(VideoStats stats) {
	if (stats != mVideoStats) {
		mVideoStats = stats;
		emit videoStatsChanged();
	}
}
