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
#include "core/friend/FriendCore.hpp"
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
	mIsStarted = mDuration > 0;
	mMicrophoneMuted = call->getMicrophoneMuted();
	mSpeakerMuted = call->getSpeakerMuted();
	auto videoDirection = call->getParams()->getVideoDirection();
	mLocalVideoEnabled =
	    videoDirection == linphone::MediaDirection::SendOnly || videoDirection == linphone::MediaDirection::SendRecv;
	auto remoteParams = call->getRemoteParams();
	videoDirection = remoteParams ? remoteParams->getVideoDirection() : linphone::MediaDirection::Inactive;
	mRemoteVideoEnabled =
	    videoDirection == linphone::MediaDirection::SendOnly || videoDirection == linphone::MediaDirection::SendRecv;
	mState = LinphoneEnums::fromLinphone(call->getState());
	auto remoteAddress = call->getCallLog()->getRemoteAddress()->clone();
	remoteAddress->clean();
	mRemoteAddress = Utils::coreStringToAppString(remoteAddress->asStringUriOnly());
	mRemoteUsername = Utils::coreStringToAppString(remoteAddress->getUsername());
	auto linphoneFriend = ToolModel::findFriendByAddress(remoteAddress);
	if (linphoneFriend)
		mRemoteName = Utils::coreStringToAppString(
		    linphoneFriend->getVcard() ? linphoneFriend->getVcard()->getFullName() : linphoneFriend->getName());
	if (mRemoteName.isEmpty()) mRemoteName = ToolModel::getDisplayName(remoteAddress);
	mShouldFindRemoteFriend = !linphoneFriend;
	if (mShouldFindRemoteFriend) {
		mShouldFindRemoteFriend = CoreModel::getInstance()->getCore()->getRemoteContactDirectories().size() > 0;
	}
	mLocalAddress = Utils::coreStringToAppString(call->getCallLog()->getLocalAddress()->asStringUriOnly());
	mStatus = LinphoneEnums::fromLinphone(call->getCallLog()->getStatus());

	mTransferState = LinphoneEnums::fromLinphone(call->getTransferState());
	mLocalToken = Utils::coreStringToAppString(mCallModel->getLocalAtuhenticationToken());
	mRemoteTokens = mCallModel->getRemoteAtuhenticationTokens();
	mEncryption = LinphoneEnums::fromLinphone(call->getParams()->getMediaEncryption());
	auto tokenVerified = call->getAuthenticationTokenVerified();
	mIsMismatch = call->getZrtpCacheMismatchFlag();
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
			mZrtpStats.mIsPostQuantum = stats->isZrtpKeyAgreementAlgoPostQuantum();
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
	mMicrophoneVolume = call->getRecordVolume();
	mRecordable = mState == LinphoneEnums::CallState::StreamsRunning;
	mConferenceVideoLayout = LinphoneEnums::fromLinphone(SettingsModel::getInstance()->getDefaultConferenceLayout());
	auto videoSource = call->getVideoSource();
	mVideoSourceDescriptor = VideoSourceDescriptorCore::create(videoSource ? videoSource->clone() : nullptr);
}

CallCore::~CallCore() {
	lDebug() << "[CallCore] delete" << this;
	mustBeInMainThread("~" + getClassName());
	emit mCallModel->removeListener();
}

void CallCore::setSelf(QSharedPointer<CallCore> me) {
	mCallModelConnection = SafeConnection<CallCore, CallModel>::create(me, mCallModel);
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
					//: "Enregistrement terminé"
					Utils::showInformationPopup(tr("call_record_end_message"),
												//: "L'appel a été enregistré dans le fichier : %1"
												tr("call_record_saved_in_file_message").arg(QString::fromStdString(mCallModel->getRecordFile())),
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
		                                         mCallModelConnection->invokeToCore([this, verified]() {
			                                         setTokenVerified(verified);
			                                         setIsMismatch(!verified);
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
	mCallModelConnection->makeConnectToModel(&CallModel::microphoneVolumeChanged, [this](float volume) {
		mCallModelConnection->invokeToCore([this, volume]() { setMicrophoneVolume(volume); });
	});
	mCallModelConnection->makeConnectToModel(
	    &CallModel::errorMessageChanged, [this](const QString &errorMessage) { setLastErrorMessage(errorMessage); });
	mCallModelConnection->makeConnectToModel(&CallModel::stateChanged, [this](std::shared_ptr<linphone::Call> call,
	                                                                          linphone::Call::State state,
	                                                                          const std::string &message) {
		bool isConf = call && call->getConference() != nullptr;
		auto subject = call->getConference() ? Utils::coreStringToAppString(call->getConference()->getSubject()) : "";
		mCallModelConnection->invokeToCore([this, state, subject, isConf]() {
			setRecordable(state == linphone::Call::State::StreamsRunning);
			setPaused(state == linphone::Call::State::Paused || state == linphone::Call::State::PausedByRemote);
			if (mConference) mConference->setSubject(subject);
			// The conference object is not ready until the StreamRunning status,
			// so it can't be used at this point
			setIsConference(isConf);
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
	mCallModelConnection->makeConnectToCore(&CallCore::lTransferCallToAnother, [this](QString uri) {
		mCallModelConnection->invokeToModel([this, uri]() {
			auto linCall = ToolModel::getCallByRemoteAddress(uri);
			if (linCall) mCallModel->transferToAnother(linCall);
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
					setIsMismatch(isCaseMismatch);
					setTokenVerified(tokenVerified);
			        setEncryption(encryption);
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
				zrtpStats.mIsPostQuantum = stats->isZrtpKeyAgreementAlgoPostQuantum();
			    mCallModelConnection->invokeToCore([this, zrtpStats]() { setZrtpStats(zrtpStats); });
		    }
	    });

	mCallModelConnection->makeConnectToCore(&CallCore::lSetInputAudioDevice, [this](QString id) {
		mCallModelConnection->invokeToModel([this, id]() {
			auto device = ToolModel::findAudioDevice(id, linphone::AudioDevice::Capabilities::CapabilityRecord);
			if (device) mCallModel->setInputAudioDevice(device);
		});
	});
	mCallModelConnection->makeConnectToModel(&CallModel::inputAudioDeviceChanged, [this](const std::string &id) {
		mCallModelConnection->invokeToCore([this, id]() {});
	});
	mCallModelConnection->makeConnectToCore(&CallCore::lSetOutputAudioDevice, [this](QString id) {
		mCallModelConnection->invokeToModel([this, id]() {
			auto device = ToolModel::findAudioDevice(id, linphone::AudioDevice::Capabilities::CapabilityPlay);
			if (device) mCallModel->setOutputAudioDevice(device);
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
					//: "Codec: %1 / %2 kHz"
					tr("call_stats_codec_label").arg(Utils::coreStringToAppString(codecType)).arg(codecRate);
			    auto linAudioStats = call->getAudioStats();
			    if (linAudioStats) {
					//: "Bande passante : %1 %2 kbits/s %3 %4 kbits/s"
					audioStats.mBandwidth = tr("call_stats_bandwidth_label")
				                                .arg("↑")
				                                .arg(round(linAudioStats->getUploadBandwidth()))
				                                .arg("↓")
				                                .arg(round(linAudioStats->getDownloadBandwidth()));
					//: "Taux de perte: %1% %2%"
					audioStats.mLossRate = tr("call_stats_loss_rate_label")
				                               .arg(linAudioStats->getSenderLossRate())
				                               .arg(linAudioStats->getReceiverLossRate());
					//: "Tampon de gigue: %1 ms"
					audioStats.mJitterBufferSize =
						tr("call_stats_jitter_buffer_label").arg(linAudioStats->getJitterBufferSizeMs());
			    }
			    setAudioStats(audioStats);
		    } else if (stats->getType() == linphone::StreamType::Video) {
			    VideoStats videoStats;
			    auto params = call->getCurrentParams();
			    auto playloadType = params->getUsedVideoPayloadType();
			    auto codecType = playloadType ? playloadType->getMimeType() : "";
			    auto codecRate = playloadType ? playloadType->getClockRate() / 1000 : 0;
			    videoStats.mCodec =
					tr("call_stats_codec_label").arg(Utils::coreStringToAppString(codecType)).arg(codecRate);
			    auto linVideoStats = call->getVideoStats();
			    if (stats) {
					videoStats.mBandwidth = tr("call_stats_bandwidth_label")
				                                .arg("↑")
				                                .arg(round(linVideoStats->getUploadBandwidth()))
				                                .arg("↓")
				                                .arg(round(linVideoStats->getDownloadBandwidth()));
					videoStats.mLossRate = tr("call_stats_loss_rate_label")
				                               .arg(linVideoStats->getSenderLossRate())
				                               .arg(linVideoStats->getReceiverLossRate());
			    }
			    auto sentResolution =
			        params->getSentVideoDefinition() ? params->getSentVideoDefinition()->getName() : "";
			    auto receivedResolution =
			        params->getReceivedVideoDefinition() ? params->getReceivedVideoDefinition()->getName() : "";
				//: "Définition vidéo : %1 %2 %3 %4"
				videoStats.mResolution = tr("call_stats_resolution_label")
			                                 .arg("↑", Utils::coreStringToAppString(sentResolution), "↓",
			                                      Utils::coreStringToAppString(receivedResolution));
			    auto sentFps = params->getSentFramerate();
			    auto receivedFps = params->getReceivedFramerate();
				//: "FPS : %1 %2 %3 %4"
				videoStats.mFps = tr("call_stats_fps_label").arg("↑").arg(sentFps).arg("↓").arg(receivedFps);
			    setVideoStats(videoStats);
		    }
	    });
	if (mShouldFindRemoteFriend) findRemoteFriend(me);
}

DEFINE_GET_SET_API(CallCore, bool, isStarted, IsStarted)

QString CallCore::getRemoteAddress() const {
	return mRemoteAddress;
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
		setIsStarted(mDuration > 0);
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
		lDebug() << "[CallCore] Set conference : " << mConference;
		setIsConference(conference != nullptr);
		emit conferenceChanged();
	}
}

void CallCore::setIsConference(bool isConf) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mIsConference != isConf) {
		mIsConference = isConf;
		emit isConferenceChanged();
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
	switch (mEncryption) {
		case LinphoneEnums::MediaEncryption::Dtls:
			//: DTLS
			return tr("media_encryption_dtls");
		case LinphoneEnums::MediaEncryption::None:
			//: None
			return tr("media_encryption_none");
		case LinphoneEnums::MediaEncryption::Srtp:
			//: SRTP
			return tr("media_encryption_srtp");
		case LinphoneEnums::MediaEncryption::Zrtp:
			//: "ZRTP - Post quantique"
			return tr("media_encryption_post_quantum");
		default:
			return QString();
	}
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

float CallCore::getMicrophoneVolume() const {
	return mMicrophoneVolume;
}
void CallCore::setMicrophoneVolume(float vol) {
	if (mMicrophoneVolume != vol) {
		mMicrophoneVolume = vol;
		emit microphoneVolumeChanged();
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

void CallCore::findRemoteFriend(QSharedPointer<CallCore> me) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto linphoneSearch = CoreModel::getInstance()->getCore()->createMagicSearch();
	linphoneSearch->setLimitedSearch(true);

	mRemoteMagicSearchModel = Utils::makeQObject_ptr<MagicSearchModel>(linphoneSearch);
	mRemoteMagicSearchModel->setSelf(mRemoteMagicSearchModel);
	mRemoteMagicSearchModelConnection = SafeConnection<CallCore, MagicSearchModel>::create(me, mRemoteMagicSearchModel);
	mRemoteMagicSearchModelConnection->makeConnectToModel(
	    &MagicSearchModel::searchResultsReceived,
	    [this, remoteAdress = mRemoteAddress](const std::list<std::shared_ptr<linphone::SearchResult>> &results) {
		    mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		    QString name;
		    auto remoteFriend = ToolModel::findFriendByAddress(remoteAdress); // Priorize what is stored.
		    if (!remoteFriend && results.size() > 0) remoteFriend = results.front()->getFriend(); // Then result friend.
		    if (remoteFriend) name = Utils::coreStringToAppString(remoteFriend->getName());
		    else if (results.size() > 0) // Then result address.
			    name = Utils::coreStringToAppString(results.front()->getAddress()->getDisplayName());
		    if (name.isEmpty() && results.size() > 0)
			    name = Utils::coreStringToAppString(results.front()->getAddress()->getUsername());
		    if (!name.isEmpty())
			    mRemoteMagicSearchModelConnection->invokeToCore([this, name]() {
				    mustBeInMainThread(log().arg(Q_FUNC_INFO));
				    if (name != mRemoteName) {
					    mRemoteName = name;
					    emit remoteNameChanged();
				    }
			    });
	    });

	bool ldapSearch = SettingsModel::getInstance()->getUsernameOnlyForLdapLookupsInCalls();
	bool cardDAVSearch = SettingsModel::getInstance()->getUsernameOnlyForCardDAVLookupsInCalls();
	mRemoteMagicSearchModel->search(ldapSearch || cardDAVSearch ? mRemoteUsername : mRemoteAddress,
	                                (ldapSearch ? (int)LinphoneEnums::MagicSearchSource::LdapServers : 0) |
	                                    (cardDAVSearch ? (int)LinphoneEnums::MagicSearchSource::RemoteCardDAV : 0),
	                                LinphoneEnums::MagicSearchAggregation::Friend, -1);
}
