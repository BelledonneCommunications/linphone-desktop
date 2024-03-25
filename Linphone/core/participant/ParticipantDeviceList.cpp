/*
 * Copyright (c) 2024 Belledonne Communications SARL.
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
#include "core/participant/ParticipantDeviceCore.hpp"
#include "core/participant/ParticipantDeviceGui.hpp"

#include <QQmlApplicationEngine>
#include <algorithm>

DEFINE_ABSTRACT_OBJECT(ParticipantDeviceList)

QSharedPointer<ParticipantDeviceList> ParticipantDeviceList::create() {
	auto model = QSharedPointer<ParticipantDeviceList>(new ParticipantDeviceList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

QSharedPointer<ParticipantDeviceList>
ParticipantDeviceList::create(const std::shared_ptr<ConferenceModel> &conferenceModel) {
	auto model = create();
	model->setConferenceModel(conferenceModel);
	return model;
}

ParticipantDeviceList::ParticipantDeviceList() {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ParticipantDeviceList::~ParticipantDeviceList() {
}

QList<QSharedPointer<ParticipantDeviceCore>>
ParticipantDeviceList::buildDevices(const std::shared_ptr<ConferenceModel> &conferenceModel) const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	QList<QSharedPointer<ParticipantDeviceCore>> devices;
	auto lDevices = conferenceModel->getMonitor()->getParticipantDeviceList();
	bool haveMe = false;
	for (auto device : lDevices) {
		auto deviceCore = ParticipantDeviceCore::create(device);
		devices << deviceCore;
		if (deviceCore->isMe()) haveMe = true;
	}
	if (!haveMe) {
	}
	return devices;
}

QSharedPointer<ParticipantDeviceCore> ParticipantDeviceList::getMe() const {
	if (mList.size() > 0) {
		return mList[0].objectCast<ParticipantDeviceCore>();
	} else return nullptr;
}

void ParticipantDeviceList::setDevices(QList<QSharedPointer<ParticipantDeviceCore>> devices) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	add(devices);
	qDebug() << "[ParticipantDeviceList] : add " << devices.size() << " devices";
}

void ParticipantDeviceList::setConferenceModel(const std::shared_ptr<ConferenceModel> &conferenceModel) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	mConferenceModel = conferenceModel;
	qDebug() << "[ParticipantDeviceList] : set Conference " << mConferenceModel.get();
	if (mConferenceModelConnection->mCore.lock()) {          // Unsure to get myself
		auto oldConnect = mConferenceModelConnection->mCore; // Setself rebuild safepointer
		setSelf(mConferenceModelConnection->mCore.mQData);   // reset connections
		oldConnect.unlock();
	}
	beginResetModel();
	mList.clear();
	endResetModel();
	if (mConferenceModel) {
		qDebug() << "[ParticipantDeviceList] : request devices";
		mConferenceModelConnection->invokeToModel([this]() {
			qDebug() << "[ParticipantDeviceList] : build devices";
			auto devices = buildDevices(mConferenceModel);
			mConferenceModelConnection->invokeToCore([this, devices]() {
				qDebug() << "[ParticipantDeviceList] : set devices";
				setDevices(devices);
			});
		});
	}
}

void ParticipantDeviceList::setSelf(QSharedPointer<ParticipantDeviceList> me) {
	if (mConferenceModelConnection) mConferenceModelConnection->disconnect();
	mConferenceModelConnection = QSharedPointer<SafeConnection<ParticipantDeviceList, ConferenceModel>>(
	    new SafeConnection<ParticipantDeviceList, ConferenceModel>(me, mConferenceModel), &QObject::deleteLater);
	if (mConferenceModel) {
		mConferenceModelConnection->makeConnectToModel(
		    &ConferenceModel::participantDeviceAdded,
		    [this](const std::shared_ptr<linphone::ParticipantDevice> &device) {
			    auto deviceCore = ParticipantDeviceCore::create(device);
			    mConferenceModelConnection->invokeToCore([this, deviceCore]() {
				    qDebug() << "[ParticipantDeviceList] : add a device";
				    this->add(deviceCore);
			    });
		    });
		mConferenceModelConnection->makeConnectToModel(
		    &ConferenceModel::conferenceStateChanged, [this](linphone::Conference::State state) {
			    qDebug() << "[ParticipantDeviceList] new state = " << (int)state;
			    if (state == linphone::Conference::State::Created) {
				    qDebug() << "[ParticipantDeviceList] : build devices";
				    auto devices = buildDevices(mConferenceModel);
				    mConferenceModelConnection->invokeToCore([this, devices]() {
					    qDebug() << "[ParticipantDeviceList] : set devices" << devices.size();
					    setDevices(devices);
				    });
			    }
		    });
		mConferenceModelConnection->makeConnectToCore(
		    &ParticipantDeviceList::lSetConferenceModel,
		    [this](const std::shared_ptr<ConferenceModel> &conferenceModel) {
			    mConferenceModelConnection->invokeToCore(
			        [this, conferenceModel]() { setConferenceModel(conferenceModel); });
		    });
	}
}

QVariant ParticipantDeviceList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(new ParticipantDeviceGui(mList[row].objectCast<ParticipantDeviceCore>()));
	return QVariant();
}
