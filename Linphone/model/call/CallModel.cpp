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

#include "CallModel.hpp"

#include <QDebug>

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(CallModel)

CallModel::CallModel(const std::shared_ptr<linphone::Call> &call, QObject *parent)
    : ::Listener<linphone::Call, linphone::CallListener>(call, parent) {
	lDebug() << "[CallModel] new" << this << " / SDKModel=" << call.get();
	mustBeInLinphoneThread(getClassName());
	mDurationTimer.setInterval(1000);
	mDurationTimer.setSingleShot(false);
	connect(&mDurationTimer, &QTimer::timeout, this, [this]() { this->durationChanged(mMonitor->getDuration()); });
	connect(&mDurationTimer, &QTimer::timeout, this, [this]() { this->qualityUpdated(mMonitor->getCurrentQuality()); });

	mMicroVolumeTimer.setInterval(50);
	mMicroVolumeTimer.setSingleShot(false);
	connect(&mMicroVolumeTimer, &QTimer::timeout, this,
	        [this]() { this->microphoneVolumeChanged(Utils::computeVu(mMonitor->getRecordVolume())); });
	mMicroVolumeTimer.start();
}

CallModel::~CallModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void CallModel::accept(bool withVideo) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	auto params = core->createCallParams(mMonitor);
	params->setRecordFile(
	    Paths::getCapturesDirPath()
	        .append(Utils::generateSavedFilename(QString::fromStdString(mMonitor->getToAddress()->getUsername()), ""))
	        .append(".smff")
	        .toStdString());
	// Answer with local call address.
	auto localAddress = mMonitor->getCallLog()->getLocalAddress();
	for (auto account : core->getAccountList()) {
		if (account->getParams()->getIdentityAddress()->weakEqual(localAddress)) {
			params->setAccount(account);
			break;
		}
	}
	activateLocalVideo(params, withVideo);
	mMonitor->acceptWithParams(params);
	emit localVideoEnabledChanged(withVideo);
}

void CallModel::decline() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto errorInfo = linphone::Factory::get()->createErrorInfo();
	errorInfo->set("SIP", linphone::Reason::Declined, 603, "Decline", "");
	mMonitor->terminateWithErrorInfo(errorInfo);
}

void CallModel::terminate() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->terminate();
}

void CallModel::setPaused(bool paused) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (paused) {
		if (mMonitor->getConference()) mMonitor->getConference()->leave();
		mMonitor->pause();
	} else {
		if (mMonitor->getConference()) mMonitor->getConference()->enter();
		mMonitor->resume();
	}
}

void CallModel::transferTo(const std::shared_ptr<linphone::Address> &address) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mMonitor->transferTo(address) == -1)
		qWarning() << log()
		                  .arg(QStringLiteral("Unable to transfer: `%1`."))
		                  .arg(Utils::coreStringToAppString(address->asStringUriOnly()));
}

void CallModel::transferToAnother(const std::shared_ptr<linphone::Call> &call) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mMonitor->transferToAnother(call) == -1)
		qWarning() << log()
		                  .arg(QStringLiteral("Unable to transfer: `%1`."))
		                  .arg(Utils::coreStringToAppString(call->getRemoteAddress()->asStringUriOnly()));
}

void CallModel::terminateAllCalls() {
	auto status = mMonitor->getCore()->terminateAllCalls();
}

void CallModel::setMicrophoneMuted(bool isMuted) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setMicrophoneMuted(isMuted);
	emit microphoneMutedChanged(isMuted);
}

void CallModel::setSpeakerMuted(bool isMuted) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setSpeakerMuted(isMuted);
	emit speakerMutedChanged(isMuted);
}

void CallModel::activateLocalVideo(std::shared_ptr<linphone::CallParams> &params, bool enable) {
	lInfo() << sLog()
	               .arg("Updating call with video enabled and media direction set to %1")
	               .arg((int)params->getVideoDirection());
	if (enable) params->enableVideo(SettingsModel::getInstance()->getVideoEnabled());
	auto videoDirection = enable ? linphone::MediaDirection::SendRecv : linphone::MediaDirection::RecvOnly;
	params->setVideoDirection(videoDirection);
}

void CallModel::setLocalVideoEnabled(bool enabled) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = CoreModel::getInstance()->getCore()->createCallParams(mMonitor);
	activateLocalVideo(params, enabled);
	mMonitor->update(params);
}

void CallModel::startRecording() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->startRecording();
	emit recordingChanged(mMonitor, mMonitor->getParams()->isRecording());
}

void CallModel::stopRecording() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->stopRecording();
	emit recordingChanged(mMonitor, mMonitor->getParams()->isRecording());
}

void CallModel::setRecordFile(const std::string &path) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	auto params = core->createCallParams(mMonitor);
	params->setRecordFile(path);
	mMonitor->update(params);
}

float CallModel::getMicrophoneVolume() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto volume = mMonitor->getRecordVolume();
	return volume;
}

void CallModel::setInputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setInputAudioDevice(device);
	std::string deviceName;
	if (device) deviceName = device->getDeviceName();
	emit inputAudioDeviceChanged(deviceName);
}

std::shared_ptr<const linphone::AudioDevice> CallModel::getInputAudioDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getInputAudioDevice();
}

void CallModel::setOutputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setOutputAudioDevice(device);
	std::string deviceName;
	if (device) deviceName = device->getDeviceName();
	emit outputAudioDeviceChanged(deviceName);
}

std::shared_ptr<const linphone::AudioDevice> CallModel::getOutputAudioDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getOutputAudioDevice();
}

std::string CallModel::getRecordFile() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getParams()->getRecordFile();
}

std::shared_ptr<const linphone::Address> CallModel::getRemoteAddress() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getRemoteAddress();
}

bool CallModel::getAuthenticationTokenVerified() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getAuthenticationTokenVerified();
}

void CallModel::checkAuthenticationToken(const QString &token) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->checkAuthenticationTokenSelected(Utils::appStringToCoreString(token));
}

void CallModel::skipZrtpAuthentication() {
	mMonitor->skipZrtpAuthentication();
}

std::string CallModel::getLocalAtuhenticationToken() const {
	return mMonitor->getLocalAuthenticationToken();
}

QStringList CallModel::getRemoteAtuhenticationTokens() const {
	QStringList ret;
	for (auto &token : mMonitor->getRemoteAuthenticationTokens())
		ret.append(Utils::coreStringToAppString(token));
	return ret;
}

bool CallModel::getZrtpCaseMismatch() const {
	return mMonitor->getZrtpCacheMismatchFlag();
}

std::shared_ptr<linphone::Conference> CallModel::getConference() const {
	return mMonitor->getConference();
}

void CallModel::setConference(const std::shared_ptr<linphone::Conference> &conference) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mConference != conference) {
		mConference = conference;
		emit conferenceChanged();
	}
}

std::shared_ptr<linphone::CallStats> CallModel::getAudioStats() const {
	return mMonitor->getAudioStats();
}

std::shared_ptr<linphone::CallStats> CallModel::getVideoStats() const {
	return mMonitor->getVideoStats();
}

std::shared_ptr<linphone::CallStats> CallModel::getTextStats() const {
	return mMonitor->getTextStats();
}

LinphoneEnums::ConferenceLayout CallModel::getConferenceVideoLayout() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return LinphoneEnums::fromLinphone(mMonitor->getParams()->getConferenceVideoLayout());
}

void CallModel::changeConferenceVideoLayout(LinphoneEnums::ConferenceLayout layout) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto coreManager = CoreModel::getInstance();

	// TODO : change layout for grid/active speaker in settings
	//	if (layout == LinphoneEnums::ConferenceLayout::Grid)
	//		coreManager->getSettingsModel()->setCameraMode(coreManager->getSettingsModel()->getGridCameraMode());
	//	else
	// coreManager->getSettingsModel()->setCameraMode(coreManager->getSettingsModel()->getActiveSpeakerCameraMode());
	auto params = coreManager->getCore()->createCallParams(mMonitor);
	params->setConferenceVideoLayout(LinphoneEnums::toLinphone(layout));
	params->enableVideo(layout != LinphoneEnums::ConferenceLayout::AudioOnly);
	if (!params->videoEnabled() && params->screenSharingEnabled()) {
		params->enableScreenSharing(false); // Deactivate screensharing if going to audio only.
	}
	mMonitor->update(params);
}

void CallModel::updateConferenceVideoLayout() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto callParams = mMonitor->getParams();
	//	auto settings = CoreManager::getInstance()->getSettingsModel();
	auto newLayout = LinphoneEnums::fromLinphone(callParams->getConferenceVideoLayout());
	if (!SettingsModel::getInstance()->getVideoEnabled()) newLayout = LinphoneEnums::ConferenceLayout::AudioOnly;
	if (!mConference) newLayout = LinphoneEnums::ConferenceLayout::ActiveSpeaker;
	if (mConferenceVideoLayout != newLayout) { // && !getPausedByUser()) { // Only update if not in pause.
		                                       //		if (mMonitor->getConference()) {
		//			if (callParams->getConferenceVideoLayout() == linphone::Conference::Layout::Grid)
		//				settings->setCameraMode(settings->getGridCameraMode());
		//			else settings->setCameraMode(settings->getActiveSpeakerCameraMode());
		//		} else settings->setCameraMode(settings->getCallCameraMode());

		// TODO : change layout for grid/active speaker in settings
		lDebug() << "Changing layout from " << mConferenceVideoLayout << " into " << newLayout;
		mConferenceVideoLayout = newLayout;
		emit conferenceVideoLayoutChanged(mConferenceVideoLayout);
	}
}

void CallModel::setVideoSource(std::shared_ptr<linphone::VideoSourceDescriptor> videoDesc) {
	mMonitor->setVideoSource(videoDesc);

	emit videoDescriptorChanged();
}

LinphoneEnums::VideoSourceScreenSharingType CallModel::getVideoSourceType() const {
	auto videoSource = mMonitor->getVideoSource();
	return LinphoneEnums::fromLinphone(videoSource ? videoSource->getScreenSharingType()
	                                               : linphone::VideoSourceScreenSharingType::Display);
}
int CallModel::getScreenSharingIndex() const {
	auto videoSource = mMonitor->getVideoSource();
	if (videoSource && videoSource->getScreenSharingType() == linphone::VideoSourceScreenSharingType::Display) {
		void *t = videoSource->getScreenSharing();
		return *(int *)(&t);
	} else return -1;
}

void CallModel::setVideoSourceDescriptorModel(std::shared_ptr<VideoSourceDescriptorModel> model) {
	if (model) setVideoSource(model->mDesc);
	else {
		setVideoSource(nullptr);
	}
}

void CallModel::sendDtmf(const QString &dtmf) {
	const char key = dtmf.constData()[0].toLatin1();
	qInfo() << QStringLiteral("Send dtmf: `%1`.").arg(key);
	if (mMonitor) mMonitor->sendDtmf(key);
	CoreModel::getInstance()->getCore()->playDtmf(key, gDtmfSoundDelay);
}

void CallModel::updateCallErrorFromReason(linphone::Reason reason) {
	QString error;
	switch (reason) {
		case linphone::Reason::Declined:
			//: "Le correspondant a décliné l'appel"
			error = tr("call_error_user_declined_toast");
			break;
		case linphone::Reason::NotFound:
			//: "Le correspondant n'a pas été trouvé"
			error = tr("call_error_user_not_found_toast");
			break;
		case linphone::Reason::Busy:
			//: "Le correspondant est occupé"
			error = tr("call_error_user_busy_toast");
			break;
		case linphone::Reason::NotAcceptable:
			//: "Le correspondant ne peut accepter votre appel."
			error = tr("call_error_incompatible_media_params_toast");
			break;
		case linphone::Reason::IOError:
			//: "Service indisponible ou erreur réseau"
			error = tr("call_error_io_error_toast");
			break;
		case linphone::Reason::TemporarilyUnavailable:
			//: "Temporairement indisponible"
			error = tr("call_error_temporarily_unavailable_toast");
			break;
		case linphone::Reason::ServerTimeout:
			//: "Délai d'attente du serveur dépassé"
			error = tr("call_error_server_timeout_toast");
			break;
		default:
			break;
	}

	if (!error.isEmpty()) qInfo() << QStringLiteral("Call terminated with error (%1):").arg(error) << this;
	emit errorMessageChanged(error);
}

void CallModel::onDtmfReceived(const std::shared_ptr<linphone::Call> &call, int dtmf) {
	CoreModel::getInstance()->getCore()->playDtmf(dtmf, gDtmfSoundDelay);
	emit dtmfReceived(call, dtmf);
}

void CallModel::onGoclearAckSent(const std::shared_ptr<linphone::Call> &call) {
	emit goclearAckSent(call);
}

void CallModel::onEncryptionChanged(const std::shared_ptr<linphone::Call> &call,
                                    bool on,
                                    const std::string &authenticationToken) {
	emit encryptionChanged(call, on, authenticationToken);
}

void CallModel::onSendMasterKeyChanged(const std::shared_ptr<linphone::Call> &call, const std::string &sendMasterKey) {
	emit sendMasterKeyChanged(call, sendMasterKey);
}

void CallModel::onReceiveMasterKeyChanged(const std::shared_ptr<linphone::Call> &call,
                                          const std::string &receiveMasterKey) {
	emit receiveMasterKeyChanged(call, receiveMasterKey);
}

void CallModel::onInfoMessageReceived(const std::shared_ptr<linphone::Call> &call,
                                      const std::shared_ptr<const linphone::InfoMessage> &message) {
	emit infoMessageReceived(call, message);
}

void CallModel::onStateChanged(const std::shared_ptr<linphone::Call> &call,
                               linphone::Call::State state,
                               const std::string &message) {
	lDebug() << "CallModel::onStateChanged" << (int)state;
	if (state == linphone::Call::State::StreamsRunning) {
		setConference(call->getConference());
		mDurationTimer.start();
		// After UpdatedByRemote, video direction could be changed.
		auto videoDirection = call->getParams()->getVideoDirection();
		auto remoteVideoDirection = call->getRemoteParams()->getVideoDirection();
		emit localVideoEnabledChanged(videoDirection == linphone::MediaDirection::SendOnly ||
		                              videoDirection == linphone::MediaDirection::SendRecv);
		emit remoteVideoEnabledChanged(remoteVideoDirection == linphone::MediaDirection::SendOnly ||
		                               remoteVideoDirection == linphone::MediaDirection::SendRecv);
		updateConferenceVideoLayout();
	} else if (state == linphone::Call::State::End || state == linphone::Call::State::Error) {
		mDurationTimer.stop();
		updateCallErrorFromReason(call->getReason());
	}
	emit stateChanged(call, state, message);
}

void CallModel::onStatusChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::Status status) {
	lDebug() << "CallModel::onStatusChanged" << (int)status;
	emit statusChanged(status);
}

void CallModel::onDirChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::Dir dir) {
	emit dirChanged(dir);
}

void CallModel::onStatsUpdated(const std::shared_ptr<linphone::Call> &call,
                               const std::shared_ptr<const linphone::CallStats> &stats) {
	emit statsUpdated(call, stats);
}

void CallModel::onTransferStateChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::State state) {
	emit transferStateChanged(call, state);
}

void CallModel::onAckProcessing(const std::shared_ptr<linphone::Call> &call,
                                const std::shared_ptr<linphone::Headers> &ack,
                                bool isReceived) {
	emit ackProcessing(call, ack, isReceived);
}

void CallModel::onTmmbrReceived(const std::shared_ptr<linphone::Call> &call, int streamIndex, int tmmbr) {
	emit tmmbrReceived(call, streamIndex, tmmbr);
}

void CallModel::onSnapshotTaken(const std::shared_ptr<linphone::Call> &call, const std::string &filePath) {
	emit snapshotTaken(call, filePath);
}

void CallModel::onNextVideoFrameDecoded(const std::shared_ptr<linphone::Call> &call) {
	emit nextVideoFrameDecoded(call);
}

void CallModel::onCameraNotWorking(const std::shared_ptr<linphone::Call> &call, const std::string &cameraName) {
	emit cameraNotWorking(call, cameraName);
}

void CallModel::onVideoDisplayErrorOccurred(const std::shared_ptr<linphone::Call> &call, int errorCode) {
	emit videoDisplayErrorOccurred(call, errorCode);
}

void CallModel::onAudioDeviceChanged(const std::shared_ptr<linphone::Call> &call,
                                     const std::shared_ptr<linphone::AudioDevice> &audioDevice) {
	emit audioDeviceChanged(call, audioDevice);
}

void CallModel::onRemoteRecording(const std::shared_ptr<linphone::Call> &call, bool recording) {
	emit remoteRecording(call, recording);
}

void CallModel::onAuthenticationTokenVerified(const std::shared_ptr<linphone::Call> &call, bool verified) {
	emit authenticationTokenVerified(call, verified);
}
