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

#include "ConferenceCore.hpp"
#include "core/App.hpp"
#include "model/conference/ConferenceModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(ConferenceCore)

QSharedPointer<ConferenceCore> ConferenceCore::create(const std::shared_ptr<linphone::Conference> &conference) {
	auto sharedPointer = QSharedPointer<ConferenceCore>(new ConferenceCore(conference), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}
ConferenceCore::ConferenceCore(const std::shared_ptr<linphone::Conference> &conference) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	// Should be call from model Thread
	mustBeInLinphoneThread(getClassName());
	mConferenceModel = ConferenceModel::create(conference);
	mSubject = Utils::coreStringToAppString(conference->getSubject());
	mParticipantDeviceCount = conference->getParticipantDeviceList().size();
	auto activeSpeaker = conference->getActiveSpeakerParticipantDevice();
	if (activeSpeaker) {
		mActiveSpeakerDevice = ParticipantDeviceCore::create(activeSpeaker);
	}
	mIsLocalScreenSharing = mConferenceModel->isLocalScreenSharing();
	mIsScreenSharingEnabled = mConferenceModel->isScreenSharingEnabled();
	mIsRecording = conference->isRecording();
	auto me = conference->getMe();
	if (me) {
		mMe = ParticipantCore::create(me);
	}
}
ConferenceCore::~ConferenceCore() {
	mustBeInMainThread("~" + getClassName());
	if (mConferenceModel) emit mConferenceModel->removeListener();
}

void ConferenceCore::setSelf(QSharedPointer<ConferenceCore> me) {
	mConferenceModelConnection = SafeConnection<ConferenceCore, ConferenceModel>::create(me, mConferenceModel);
	mConferenceModelConnection->makeConnectToModel(
	    &ConferenceModel::activeSpeakerParticipantDevice,
	    [this](const std::shared_ptr<linphone::Conference> &conference,
	           const std::shared_ptr<linphone::ParticipantDevice> &participantDevice) {
		    auto device = ParticipantDeviceCore::create(participantDevice);
		    mConferenceModelConnection->invokeToCore([this, device]() { setActiveSpeakerDevice(device); });
	    });

	mConferenceModelConnection->makeConnectToModel(
	    &ConferenceModel::conferenceStateChanged,
	    [this](const std::shared_ptr<linphone::Conference> &conference, linphone::Conference::State newState) {
		    int count = mConferenceModel->getParticipantDeviceCount();
		    mConferenceModelConnection->invokeToCore([this, count]() { setParticipantDeviceCount(count); });
		    if (newState == linphone::Conference::State::Created) {
			    if (auto participantDevice = conference->getActiveSpeakerParticipantDevice()) {
				    auto device = ParticipantDeviceCore::create(participantDevice);
				    mConferenceModelConnection->invokeToCore([this, device]() { setActiveSpeakerDevice(device); });
			    } else if (conference->getParticipantDeviceList().size() > 1) {
				    for (auto &device : conference->getParticipantDeviceList()) {
					    if (!ToolModel::isMe(device->getAddress())) {
						    auto activeSpeakerDevice = ParticipantDeviceCore::create(device);
						    auto participant = conference->findParticipant(device->getAddress());
						    mConferenceModelConnection->invokeToCore(
						        [this, activeSpeakerDevice]() { setActiveSpeakerDevice(activeSpeakerDevice); });
						    break;
					    }
				    }
			    }
		    }
	    });

	mConferenceModelConnection->makeConnectToModel(
	    &ConferenceModel::participantDeviceCountChanged,
	    [this](const std::shared_ptr<linphone::Conference> &conference, int count) {
		    if (auto participantDevice = conference->getActiveSpeakerParticipantDevice()) {
			    auto device = ParticipantDeviceCore::create(participantDevice);
			    setActiveSpeakerDevice(device);
			    mConferenceModelConnection->invokeToCore([this, device]() { setActiveSpeakerDevice(device); });
		    } else if (conference->getParticipantDeviceList().size() > 1) {
			    for (auto &device : conference->getParticipantDeviceList()) {
				    if (!ToolModel::isMe(device->getAddress())) {
					    auto activeSpeaker = ParticipantDeviceCore::create(device);
					    mConferenceModelConnection->invokeToCore(
					        [this, activeSpeaker]() { setActiveSpeakerDevice(activeSpeaker); });
					    break;
				    }
			    }
		    }
		    mConferenceModelConnection->invokeToCore([this, count]() { setParticipantDeviceCount(count); });
	    });
	mConferenceModelConnection->makeConnectToModel(&ConferenceModel::isLocalScreenSharingChanged, [this]() {
		auto state = mConferenceModel->isLocalScreenSharing();
		mConferenceModelConnection->invokeToCore([this, state]() { setIsLocalScreenSharing(state); });
	});
	mConferenceModelConnection->makeConnectToModel(&ConferenceModel::isScreenSharingEnabledChanged, [this]() {
		auto state = mConferenceModel->isScreenSharingEnabled();
		mConferenceModelConnection->invokeToCore([this, state]() { setIsScreenSharingEnabled(state); });
	});
	mConferenceModelConnection->makeConnectToCore(&ConferenceCore::lToggleScreenSharing, [this]() {
		mConferenceModelConnection->invokeToModel([this]() { mConferenceModel->toggleScreenSharing(); });
	});
}

bool ConferenceCore::updateLocalParticipant() { // true if changed
	return false;
}

QString ConferenceCore::getSubject() const {
	return mSubject;
}

void ConferenceCore::setSubject(const QString &subject) {
	if (mSubject != subject) {
		mSubject = subject;
		emit subjectChanged();
	}
}

QDateTime ConferenceCore::getStartDate() const {
	return mStartDate;
}

Q_INVOKABLE qint64 ConferenceCore::getElapsedSeconds() const {
	return 0;
}

bool ConferenceCore::isRecording() const {
	return mIsRecording;
}

void ConferenceCore::setRecording(bool recording) {
	if (mIsRecording != recording) {
		mIsRecording = recording;
		emit isRecordingChanged();
	}
}

void ConferenceCore::setParticipantDeviceCount(int count) {
	if (mParticipantDeviceCount != count) {
		mParticipantDeviceCount = count;
		emit participantDeviceCountChanged();
	}
}

/**
 * /!\ mParticipantDeviceCount retrieves all devices but mine
 **/
int ConferenceCore::getParticipantDeviceCount() const {
	return mParticipantDeviceCount;
}

void ConferenceCore::setIsReady(bool state) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mIsReady != state) {
		mIsReady = state;
		emit isReadyChanged();
	}
}

void ConferenceCore::setIsLocalScreenSharing(bool state) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mIsLocalScreenSharing != state) {
		mIsLocalScreenSharing = state;
		emit isLocalScreenSharingChanged();
	}
}

void ConferenceCore::setIsScreenSharingEnabled(bool state) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mIsScreenSharingEnabled != state) {
		mIsScreenSharingEnabled = state;
		emit isScreenSharingEnabledChanged();
	}
}

std::shared_ptr<ConferenceModel> ConferenceCore::getModel() const {
	return mConferenceModel;
}

ParticipantDeviceCore *ConferenceCore::getActiveSpeakerDevice() const {
	return mActiveSpeakerDevice.get();
}

ParticipantDeviceGui *ConferenceCore::getActiveSpeakerDeviceGui() const {
	return mActiveSpeakerDevice ? new ParticipantDeviceGui(mActiveSpeakerDevice) : nullptr;
}

ParticipantGui *ConferenceCore::getMeGui() const {
	return new ParticipantGui(mMe);
}

void ConferenceCore::setActiveSpeakerDevice(const QSharedPointer<ParticipantDeviceCore> &device) {
	if (mActiveSpeakerDevice != device) {
		mActiveSpeakerDevice = device;
		qDebug() << log().arg("Changing active speaker device to %1").arg(device ? device->getAddress() : "None");
		emit activeSpeakerDeviceChanged();
	}
}
