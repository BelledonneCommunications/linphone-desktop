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

#include <QQmlApplicationEngine>
#include <algorithm>

#include "app/App.hpp"

#include "ParticipantDeviceListModel.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"

// =============================================================================

ParticipantDeviceListModel::ParticipantDeviceListModel (std::shared_ptr<linphone::Participant> participant, QObject *parent) : ProxyListModel(parent) {
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = participant->getDevices() ;
	auto previewModel = ParticipantDeviceModel::create(nullptr, true);
	mList << previewModel;
	for(auto device : devices){
		auto deviceModel = ParticipantDeviceModel::create(device, false);
		connect(this, &ParticipantDeviceListModel::securityLevelChanged, deviceModel.get(), &ParticipantDeviceModel::onSecurityLevelChanged);
		mList << deviceModel;
	}
}

ParticipantDeviceListModel::ParticipantDeviceListModel (CallModel * callModel, QObject *parent) : ProxyListModel(parent) {
	if(callModel && callModel->isConference()) {
		mCallModel = callModel;
		auto conferenceModel = callModel->getConferenceModel();
		auto previewModel = ParticipantDeviceModel::create(nullptr, true);
		mList << previewModel;
		std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = conferenceModel->getConference()->getParticipantDeviceList();
		for(auto device : devices){
			auto deviceModel = ParticipantDeviceModel::create(device, false);
			connect(this, &ParticipantDeviceListModel::securityLevelChanged, deviceModel.get(), &ParticipantDeviceModel::onSecurityLevelChanged);
			mList << deviceModel;
		}
		/*
		mList << ParticipantDeviceModel::create(callModel, true);// Add Me in device list
		qWarning() << "Me devices : " << conferenceModel->getConference()->getMe()->getDevices().size();
//		auto meDevices = conferenceModel->getConference()->getMe()->getDevices();
	//	if(meDevices.size() > 0) 

		std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = conferenceModel->getConference()->getParticipantDeviceList();
		updateDevices(devices);
		qWarning() << "Instanciate Participant Device list model with " << mList.size() << " devices";
		*/
		connect(conferenceModel.get(), &ConferenceModel::participantDeviceAdded, this, &ParticipantDeviceListModel::onParticipantDeviceAdded);
		connect(conferenceModel.get(), &ConferenceModel::participantDeviceRemoved, this, &ParticipantDeviceListModel::onParticipantDeviceRemoved);
		connect(conferenceModel.get(), &ConferenceModel::conferenceStateChanged, this, &ParticipantDeviceListModel::onConferenceStateChanged);
	}
}

void ParticipantDeviceListModel::updateDevices(std::shared_ptr<linphone::Participant> participant){
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = participant->getDevices() ;
	auto previewModel = ParticipantDeviceModel::create(nullptr, true);
	beginResetModel();
	qWarning() << "Update devices from participant";
	mList.clear();
	mList << previewModel;
	for(auto device : devices){
		auto deviceModel = ParticipantDeviceModel::create(device, false);
		connect(this, &ParticipantDeviceListModel::securityLevelChanged, deviceModel.get(), &ParticipantDeviceModel::onSecurityLevelChanged);
		mList << deviceModel;
	}
	endResetModel();
	emit countChanged();
	emit layoutChanged();
}

void ParticipantDeviceListModel::updateDevices(const std::list<std::shared_ptr<linphone::ParticipantDevice>>& devices, const bool& isMe){
/*
	QList<std::shared_ptr<ParticipantDeviceModel>> devicesToAdd;
	//auto meDevices = mCallModel->getConferenceModel()->getConference()->getMe()->getDevices();
	for(auto device : devices){
		auto deviceAddress = device->getAddress();
		//bool isMe = false;
		//for(auto meDevice : meDevices)
			//isMe |= meDevice->getAddress() == deviceAddress;
		//if( !isMe) {
			auto exist = std::find_if(mList.begin(), mList.end(), [deviceAddress](const std::shared_ptr<ParticipantDeviceModel>& activeDevice){
				return deviceAddress == activeDevice->getDevice()->getAddress();
			});
			if(exist == mList.end()){
				auto deviceModel = ParticipantDeviceModel::create(device, isMe);
				connect(this, &ParticipantDeviceListModel::securityLevelChanged, deviceModel.get(), &ParticipantDeviceModel::onSecurityLevelChanged);
				devicesToAdd << deviceModel;
			}
		//}
	}
	qWarning() << "Update devices from devices : " << devicesToAdd.size();
	if(devicesToAdd.size() > 0){
		int row = mList.count();
		beginInsertRows(QModelIndex(), row, row+devicesToAdd.size()-1);
		mList << devicesToAdd;
		endInsertRows();
		emit countChanged();
	}
	*/
}

void ParticipantDeviceListModel::onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device){
	emit securityLevelChanged(device);
}


//----------------------------------------------------------------------------------------------------------

void ParticipantDeviceListModel::onParticipantDeviceAdded(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	auto conferenceModel = mCallModel->getConferenceModel();
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = conferenceModel->getConference()->getParticipantDeviceList();
	for(auto realParticipantDevice : devices){
		if( realParticipantDevice == participantDevice){
			auto deviceModel = ParticipantDeviceModel::create(realParticipantDevice, false);
			connect(this, &ParticipantDeviceListModel::securityLevelChanged, deviceModel.get(), &ParticipantDeviceModel::onSecurityLevelChanged);
			add(deviceModel);
			return;
		}
	}
	qWarning() << "No participant device found from const linphone::ParticipantDevice at onParticipantDeviceAdded";
}

void ParticipantDeviceListModel::onParticipantDeviceRemoved(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "Removing participant";
	int row = 0;
	for(auto device : mList){
		if( device.objectCast<ParticipantDeviceModel>()->getDevice() == participantDevice){
			removeRow(row);
			return;
		}
		++row;
	}
	qWarning() << "No participant device found from const linphone::ParticipantDevice at onParticipantDeviceRemoved";
}

void ParticipantDeviceListModel::onParticipantDeviceJoined(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "onParticipantDeviceJoined is not yet implemented. Current participants count: " << mList.size();
}

void ParticipantDeviceListModel::onParticipantDeviceLeft(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "onParticipantDeviceLeft is not yet implemented. Current participants count: " << mList.size();
}

void ParticipantDeviceListModel::onConferenceStateChanged(linphone::Conference::State newState){
	if(newState == linphone::Conference::State::Created){
		if(mCallModel && mCallModel->isConference()) {
			auto conferenceModel = mCallModel->getConferenceModel();
			updateDevices(mCallModel->getConferenceModel()->getConference()->getMe()->getDevices(), true);
			updateDevices(conferenceModel->getConference()->getParticipantDeviceList(), false);
		}
		
		/* 
			auto devices = mCallModel->getConferenceModel()->getConference()->getMe()->getDevices();
			if(devices.size() > 0 && mList.size() == 1){
				//qWarning() << "Adding Me in list. Count=" << mList.size();
				beginInsertRows(QModelIndex(), 0, 0);
				mList.push_front(ParticipantDeviceModel::create(mCallModel, true));// Add Me in device list
				endInsertRows();
				emit countChanged();
				emit layoutChanged();
				qWarning() << "M added in list. Count=" << mList.size() << ".\n\tConfVideo is enabled:" << mCallModel->getConferenceModel()->getConference()->getCurrentParams()->videoEnabled()
					<< "\n\tCallVideo is enabled: " << mCallModel->getVideoEnabled();
			}else
				qWarning() << "Me cannot be add : no Me device.";
		}else {
			if(!mCallModel)			
				qWarning() << "Cannot add me : no call.";
			else
				qWarning() << "Cannot add me : No in conf.";
		}
		*/
	}
}