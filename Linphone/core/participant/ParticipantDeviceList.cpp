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
#include "tool/Utils.hpp"

#include <QQmlApplicationEngine>
#include <algorithm>

DEFINE_ABSTRACT_OBJECT(ParticipantDeviceList)

QSharedPointer<ParticipantDeviceList> ParticipantDeviceList::create() {
	auto model = QSharedPointer<ParticipantDeviceList>(new ParticipantDeviceList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

ParticipantDeviceList::ParticipantDeviceList() {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ParticipantDeviceList::~ParticipantDeviceList() {
}

QList<QSharedPointer<ParticipantDeviceCore>> *
ParticipantDeviceList::buildDevices(const std::shared_ptr<ConferenceModel> &conferenceModel) const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	QList<QSharedPointer<ParticipantDeviceCore>> *devices = new QList<QSharedPointer<ParticipantDeviceCore>>();
	mustBeInLinphoneThread(getClassName());
	auto lDevices = conferenceModel->getMonitor()->getParticipantDeviceList();
	bool haveMe = false;
	for (auto device : lDevices) {
		auto deviceCore = ParticipantDeviceCore::create(device);
		devices->push_back(deviceCore);
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
	resetData<ParticipantDeviceCore>(devices);
	lDebug() << log().arg("Add %1 devices").arg(devices.size());
}

QSharedPointer<ParticipantDeviceCore> ParticipantDeviceList::findDeviceByUniqueAddress(const QString &address) {
	lDebug() << "address to find" << address;
	auto found = std::find_if(mList.begin(), mList.end(), [address](const QSharedPointer<QObject> &obj) {
		auto device = qobject_cast<QSharedPointer<ParticipantDeviceCore>>(obj);
		lDebug() << "address" << device->getUniqueAddress();
		return device && device->getUniqueAddress() == address;
	});
	if (found != mList.end()) {
		return qobject_cast<QSharedPointer<ParticipantDeviceCore>>(*found);
	} else return nullptr;
}

void ParticipantDeviceList::setCurrentCall(CallGui *call) {
	if (mCurrentCall != call) {
		CallCore *callCore = nullptr;
		if (mCurrentCall) {
			callCore = mCurrentCall->getCore();
			if (call && callCore == call->getCore()) {
				mCurrentCall = call;
				lDebug() << log().arg("Same call core");
				emit currentCallChanged();
				return;
			}
			if (callCore) {
				disconnect(callCore, &CallCore::conferenceChanged, this, nullptr);
				callCore = nullptr;
			}
		}
		mCurrentCall = call;
		if (mCurrentCall) {
			auto newCallCore = mCurrentCall->getCore();
			if (newCallCore) {
				connect(newCallCore, &CallCore::conferenceChanged, this, [this, newCallCore]() {
					if (!newCallCore) lCritical() << log().arg("Call core is null inside its own connect !");
					auto conference = newCallCore->getConferenceCore();
					lDebug() << log().arg("Set conference") << this << " => " << conference;
					setConferenceCore(conference);
				});
				auto conference = newCallCore->getConferenceCore();
				lDebug() << log().arg("Set conference") << this << " => " << conference;
				setConferenceCore(conference);
			}
		}
		emit currentCallChanged();
	}
}

CallGui *ParticipantDeviceList::getCurrentCall() const {
	return mCurrentCall;
}

void ParticipantDeviceList::setConferenceCore(const QSharedPointer<ConferenceCore> &conference) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mConferenceCore != conference) {
		mConferenceCore = conference;
		lDebug() << log().arg("Set Conference %1").arg((quint64)mConferenceCore.get());
		beginResetModel();
		mList.clear();
		endResetModel();
		if (mConferenceCore) {
			auto conferenceModel = mConferenceCore->getModel();
			lDebug() << "[ParticipantDeviceList] : request devices";
			if (conferenceModel)
				mCoreModelConnection->invokeToModel([this, conferenceModel] {
					lDebug() << "[ParticipantDeviceList] : build devices";
					auto devices = buildDevices(conferenceModel);
					mCoreModelConnection->invokeToCore([this, devices]() {
						lDebug() << "[ParticipantDeviceList] : set devices";
						setDevices(*devices);
						delete devices;
					});
				});
			connect(mConferenceCore.get(), &ConferenceCore::participantDeviceAdded, this,
			        [this](const std::shared_ptr<linphone::ParticipantDevice> &device) {
				        QString uniqueAddress = Utils::coreStringToAppString(device->getAddress()->asString().c_str());
				        auto deviceCore = findDeviceByUniqueAddress(uniqueAddress);
				        if (!deviceCore) {
					        mCoreModelConnection->invokeToModel([this, device] {
						        auto deviceCore = ParticipantDeviceCore::create(device);
						        mCoreModelConnection->invokeToCore([this, deviceCore]() {
							        lDebug() << "[ParticipantDeviceList] : add a device";
							        add(deviceCore);
						        });
					        });
				        }
			        });
			connect(mConferenceCore.get(), &ConferenceCore::participantDeviceRemoved, this,
			        [this](const std::shared_ptr<const linphone::ParticipantDevice> &participantDevice) {
				        QString uniqueAddress =
				            Utils::coreStringToAppString(participantDevice->getAddress()->asString().c_str());
				        auto deviceCore = findDeviceByUniqueAddress(uniqueAddress);
				        mCoreModelConnection->invokeToCore([this, deviceCore]() {
					        lDebug() << "[ParticipantDeviceList] : remove a device" << deviceCore;
					        if (!remove(deviceCore))
						        lWarning()
						            << log().arg("Unable to remove") << deviceCore << "as it is not part of the list";
				        });
			        });
			connect(mConferenceCore.get(), &ConferenceCore::conferenceStateChanged, this,
			        [this](linphone::Conference::State state) {
				        lDebug() << "[ParticipantDeviceList] new state = " << (int)state;
				        if (state == linphone::Conference::State::Created) {
					        lDebug() << "[ParticipantDeviceList] : build devices";
					        auto conferenceModel = mConferenceCore->getModel();
					        if (!conferenceModel) return;
					        auto devices = buildDevices(conferenceModel);
					        mCoreModelConnection->invokeToCore([this, devices]() {
						        lDebug() << "[ParticipantDeviceList] : set devices" << devices->size();
						        setDevices(*devices);
						        delete devices;
					        });
				        }
			        });
		}
	}
}

void ParticipantDeviceList::setSelf(QSharedPointer<ParticipantDeviceList> me) {
	if (mCoreModelConnection) mCoreModelConnection->disconnect();
	mCoreModelConnection = SafeConnection<ParticipantDeviceList, CoreModel>::create(me, CoreModel::getInstance());
	auto conferenceModel = mConferenceCore ? mConferenceCore->getModel() : nullptr;
	if (!conferenceModel) return;
	mCoreModelConnection->invokeToModel([this, conferenceModel]() {
		lDebug() << "[ParticipantDeviceList] : build devices";
		auto devices = buildDevices(conferenceModel);
		mCoreModelConnection->invokeToCore([this, devices]() {
			lDebug() << "[ParticipantDeviceList] : set devices";
			setDevices(*devices);
			delete devices;
		});
	});
}

QVariant ParticipantDeviceList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(new ParticipantDeviceGui(mList[row].objectCast<ParticipantDeviceCore>()));
	return QVariant();
}
