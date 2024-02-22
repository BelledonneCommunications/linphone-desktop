/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#include "ParticipantDeviceList.hpp"
#include "core/App.hpp"
#include "core/participant/ParticipantCore.hpp"

#include <QQmlApplicationEngine>
#include <algorithm>

DEFINE_ABSTRACT_OBJECT(ParticipantDeviceList)

QSharedPointer<ParticipantDeviceList>
ParticipantDeviceList::create(const std::shared_ptr<linphone::Participant> &participant) {
	auto model = QSharedPointer<ParticipantDeviceList>(new ParticipantDeviceList(participant), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

QSharedPointer<ParticipantDeviceList> ParticipantDeviceList::create() {
	auto model = QSharedPointer<ParticipantDeviceList>(new ParticipantDeviceList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

ParticipantDeviceList::ParticipantDeviceList(const std::shared_ptr<linphone::Participant> &participant, QObject *parent)
    : ListProxy(parent) {
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = participant->getDevices();
	for (auto device : devices) {
		auto deviceModel = ParticipantDeviceCore::create(device, isMe(device));
		// connect(this, &ParticipantDeviceList::securityLevelChanged, deviceModel.get(),
		// &ParticipantDeviceCore::onSecurityLevelChanged);
		connect(deviceModel.get(), &ParticipantDeviceCore::isSpeakingChanged, this,
		        &ParticipantDeviceList::onParticipantDeviceSpeaking);
		mList << deviceModel;
	}
	mInitialized = true;
}

ParticipantDeviceList::ParticipantDeviceList(QObject *parent) {
	mustBeInMainThread(getClassName());
}

// ParticipantDeviceList::ParticipantDeviceList(CallModel *callModel, QObject *parent) : ProxyListModel(parent) {
// 	if (callModel && callModel->isConference()) {
// 		mCallModel = callModel;
// 		connect(mCallModel, &CallModel::conferenceModelChanged, this, &ParticipantDeviceList::onConferenceModelChanged);
// 		initConferenceModel();
// 	}
// }

ParticipantDeviceList::~ParticipantDeviceList() {
	mustBeInMainThread(getClassName());
}

void ParticipantDeviceList::setSelf(QSharedPointer<ParticipantDeviceList> me) {
}

void ParticipantDeviceList::initConferenceModel() {
	// if (!mInitialized && mCallModel) {
	// 	auto conferenceModel = mCallModel->getConferenceSharedModel();
	// 	if (conferenceModel) {
	// 		updateDevices(conferenceModel->getConference()->getMe()->getDevices(), true);
	// 		updateDevices(conferenceModel->getConference()->getParticipantDeviceList(), false);

	// 		qDebug() << "Conference have " << mList.size() << " devices";
	// 		connect(conferenceModel.get(), &ConferenceModel::activeSpeakerParticipantDevice, this,
	// 		        &ParticipantDeviceList::onActiveSpeakerParticipantDevice);
	// 		connect(conferenceModel.get(), &ConferenceModel::participantAdded, this,
	// 		        &ParticipantDeviceList::onParticipantAdded);
	// 		connect(conferenceModel.get(), &ConferenceModel::participantRemoved, this,
	// 		        &ParticipantDeviceList::onParticipantRemoved);
	// 		connect(conferenceModel.get(), &ConferenceModel::participantDeviceAdded, this,
	// 		        &ParticipantDeviceList::onParticipantDeviceAdded);
	// 		connect(conferenceModel.get(), &ConferenceModel::participantDeviceRemoved, this,
	// 		        &ParticipantDeviceList::onParticipantDeviceRemoved);
	// 		connect(conferenceModel.get(), &ConferenceModel::conferenceStateChanged, this,
	// 		        &ParticipantDeviceList::onConferenceStateChanged);
	// 		connect(conferenceModel.get(), &ConferenceModel::participantDeviceMediaCapabilityChanged, this,
	// 		        &ParticipantDeviceList::onParticipantDeviceMediaCapabilityChanged);
	// 		connect(conferenceModel.get(), &ConferenceModel::participantDeviceMediaAvailabilityChanged, this,
	// 		        &ParticipantDeviceList::onParticipantDeviceMediaAvailabilityChanged);
	// 		connect(conferenceModel.get(), &ConferenceModel::participantDeviceIsSpeakingChanged, this,
	// 		        &ParticipantDeviceList::onParticipantDeviceIsSpeakingChanged);
	// 		mActiveSpeaker = get(conferenceModel->getConference()->getActiveSpeakerParticipantDevice());
	// 		mInitialized = true;
	// 	}
	// }
}

void ParticipantDeviceList::updateDevices(std::shared_ptr<linphone::Participant> participant) {
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = participant->getDevices();
	bool meAdded = false;
	beginResetModel();
	qDebug() << "Update devices from participant";
	mList.clear();
	for (auto device : devices) {
		bool addMe = isMe(device);
		auto deviceModel = ParticipantDeviceCore::create(device, addMe);
		// connect(this, &ParticipantDeviceList::securityLevelChanged, deviceModel.get(),
		// &ParticipantDeviceCore::onSecurityLevelChanged);
		connect(deviceModel.get(), &ParticipantDeviceCore::isSpeakingChanged, this,
		        &ParticipantDeviceList::onParticipantDeviceSpeaking);
		mList << deviceModel;
		if (addMe) meAdded = true;
	}
	endResetModel();
	if (meAdded) emit meChanged();
}

void ParticipantDeviceList::updateDevices(const std::list<QSharedPointer<ParticipantDeviceCore>> &devices,
                                          const bool &isMe) {
	for (auto device : devices) {
		add(device);
	}
}

bool ParticipantDeviceList::add(const QSharedPointer<ParticipantDeviceCore> &deviceToAdd) {
	auto deviceToAddAddr = deviceToAdd->getAddress();
	int row = 0;
	qDebug() << "Adding device " << deviceToAdd->getAddress();
	for (auto item : mList) {
		auto deviceCore = item.objectCast<ParticipantDeviceCore>();
		if (deviceCore == deviceToAdd) {
			qDebug() << "Device already exist. Send video update event";
			// deviceCore->updateVideoEnabled();
			return false;
		} else if (deviceToAddAddr == deviceCore->getAddress()) { // Address is the same (same device) but the model
			                                                      // is using another linphone object. Replace it.
			qDebug() << "Replacing device : Device exists but the model is using another linphone object.";
			// deviceCore->updateVideoEnabled();
			removeRow(row);
			break;
		}
		++row;
	}
	bool addMe = isMe(deviceToAdd);
	auto deviceModel = ParticipantDeviceCore::create(deviceToAdd, addMe);
	// connect(this, &ParticipantDeviceList::securityLevelChanged, deviceModel.get(),
	// &ParticipantDeviceCore::onSecurityLevelChanged);
	connect(deviceModel.get(), &ParticipantDeviceCore::isSpeakingChanged, this,
	        &ParticipantDeviceList::onParticipantDeviceSpeaking);
	ListProxy::add<ParticipantDeviceCore>(deviceModel);
	qDebug() << "Device added. Count=" << mList.count();
	QStringList debugDevices;
	for (auto i : mList) {
		auto item = i.objectCast<ParticipantDeviceCore>();
		debugDevices.push_back(item->getAddress());
	}
	qDebug() << debugDevices.join("\n");
	if (addMe) {
		qDebug() << "Added a me device";
		emit meChanged();
	} else if (mList.size() == 1 ||
	           (mList.size() == 2 && isMe(mList.front().objectCast<ParticipantDeviceCore>()->getDevice()))) {
		mActiveSpeaker = mList.back().objectCast<ParticipantDeviceCore>();
		emit activeSpeakerChanged();
	}
	return true;
}

bool ParticipantDeviceList::remove(std::shared_ptr<const linphone::ParticipantDevice> deviceToRemove) {
	int row = 0;
	for (auto item : mList) {
		auto device = item.objectCast<ParticipantDeviceCore>();
		if (device->getDevice() == deviceToRemove) {
			// device->updateVideoEnabled();
			removeRow(row);
			return true;
		} else ++row;
	}
	return false;
}

QSharedPointer<ParticipantDeviceCore>
ParticipantDeviceList::get(std::shared_ptr<const linphone::ParticipantDevice> deviceToGet, int *index) {
	int row = 0;
	for (auto item : mList) {
		auto device = item.objectCast<ParticipantDeviceCore>();
		if (device->getDevice() == deviceToGet) {
			if (index) *index = row;
			return device;
		} else ++row;
	}
	return nullptr;
}

QSharedPointer<ParticipantDeviceCore> ParticipantDeviceList::getMe(int *index) const {
	int row = 0;
	for (auto item : mList) {
		auto device = item.objectCast<ParticipantDeviceCore>();
		if (device->isMe() && device->isLocal()) {
			if (index) *index = row;
			return device;
		} else ++row;
	}
	return nullptr;
}

ParticipantDeviceCore *ParticipantDeviceList::getActiveSpeakerModel() const {
	return mActiveSpeaker.get();
}

bool ParticipantDeviceList::isMe(std::shared_ptr<linphone::ParticipantDevice> deviceToCheck) const {
	// if (mCallModel) {
	// auto devices = mCallModel->getConferenceSharedModel()->getConference()->getMe()->getDevices();
	// auto deviceToCheckAddress = deviceToCheck->getAddress();
	// for (auto device : devices) {
	// if (deviceToCheckAddress == device->getAddress()) return true;
	// }
	// }
	return false;
}

bool ParticipantDeviceList::isMeAlone() const {
	for (auto item : mList) {
		auto device = item.objectCast<ParticipantDeviceCore>();
		if (!isMe(device->getDevice())) return false;
	}
	return true;
}

void ParticipantDeviceList::onConferenceModelChanged() {
	if (!mInitialized) {
		initConferenceModel();
	}
}

void ParticipantDeviceList::onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device) {
	emit securityLevelChanged(device);
}

//----------------------------------------------------------------------------------------------------------
void ParticipantDeviceList::onParticipantAdded(const std::shared_ptr<const linphone::Participant> &participant) {
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = participant->getDevices();
	if (devices.size() == 0)
		qDebug() << "Participant has no device. It will not be added : "
		         << participant->getAddress()->asString().c_str();
	else
		for (auto device : devices)
			add(device);
}

void ParticipantDeviceList::onParticipantRemoved(const std::shared_ptr<const linphone::Participant> &participant) {
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = participant->getDevices();
	for (auto device : devices)
		remove(device);
}

void ParticipantDeviceList::onParticipantDeviceAdded(
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	qDebug() << "Adding new device : " << mList.count();
	// auto conferenceModel = mCallModel->getConferenceSharedModel();
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices;
	for (int i = 0; i < 2; ++i) {
		// if (i == 0) devices = conferenceModel->getConference()->getParticipantDeviceList(); // Active devices.
		// else devices = conferenceModel->getConference()->getMe()->getDevices();
		for (auto realParticipantDevice : devices) {
			if (realParticipantDevice == participantDevice) {
				add(realParticipantDevice);
				return;
			}
		}
	}

	qDebug() << "No participant device found from linphone::ParticipantDevice at onParticipantDeviceAdded";
}

void ParticipantDeviceList::onParticipantDeviceRemoved(
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	qDebug() << "Removing participant device : " << mList.count();
	if (!remove(participantDevice))
		qDebug() << "No participant device found from linphone::ParticipantDevice at onParticipantDeviceRemoved";
}

void ParticipantDeviceList::onConferenceStateChanged(linphone::Conference::State newState) {
	// if (newState == linphone::Conference::State::Created) {
	// 	if (mCallModel && mCallModel->isConference()) {
	// 		auto conferenceModel = mCallModel->getConferenceSharedModel();
	// 		updateDevices(conferenceModel->getConference()->getMe()->getDevices(), true);
	// 		updateDevices(conferenceModel->getConference()->getParticipantDeviceList(), false);
	// 	}
	// 	emit conferenceCreated();
	// }
}

void ParticipantDeviceList::onParticipantDeviceMediaCapabilityChanged(
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	// auto device = get(participantDevice);
	// if (device) device->updateVideoEnabled();
	// else onParticipantDeviceAdded(participantDevice);

	// device = get(participantDevice);
	// if (device && device->isMe()) { // Capability change for me. Update all videos.
	// 	for (auto item : mList) {
	// 		auto device = item.objectCast<ParticipantDeviceCore>();
	// 		device->updateVideoEnabled();
	// 	}
	// }
}

void ParticipantDeviceList::onParticipantDeviceMediaAvailabilityChanged(
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	// auto device = get(participantDevice);
	// if (device) device->updateVideoEnabled();
	// else onParticipantDeviceAdded(participantDevice);
}
void ParticipantDeviceList::onActiveSpeakerParticipantDevice(
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
	// auto device = get(participantDevice);
	// if (device) {
	// 	mActiveSpeaker = device;
	// 	emit activeSpeakerChanged();
	// }
}

void ParticipantDeviceList::onParticipantDeviceIsSpeakingChanged(
    const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice, bool isSpeaking) {
	auto device = get(participantDevice);
	if (device) emit participantSpeaking(device.get());
}

void ParticipantDeviceList::onParticipantDeviceSpeaking() {
}
