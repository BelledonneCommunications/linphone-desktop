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

#include "model/core/CoreModel.hpp"

DEFINE_ABSTRACT_OBJECT(CallModel)

CallModel::CallModel(const std::shared_ptr<linphone::Call> &call, QObject *parent)
    : ::Listener<linphone::Call, linphone::CallListener>(call, parent) {
	mustBeInLinphoneThread(getClassName());
}

CallModel::~CallModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void CallModel::accept(bool withVideo) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));

	auto core = CoreModel::getInstance()->getCore();
	auto params = core->createCallParams(mMonitor);
	params->enableVideo(withVideo);
	// Answer with local call address.
	auto localAddress = mMonitor->getCallLog()->getLocalAddress();
	for (auto account : core->getAccountList()) {
		if (account->getParams()->getIdentityAddress()->weakEqual(localAddress)) {
			params->setAccount(account);
			break;
		}
	}

	mMonitor->acceptWithParams(params);
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

void CallModel::onDtmfReceived(const std::shared_ptr<linphone::Call> &call, int dtmf) {
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
	emit stateChanged(state, message);
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
