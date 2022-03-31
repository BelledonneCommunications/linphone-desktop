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

ParticipantDeviceListModel::ParticipantDeviceListModel (std::shared_ptr<linphone::Participant> participant, QObject *parent) : QAbstractListModel(parent) {
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = participant->getDevices() ;
	for(auto device : devices){
		auto deviceModel = std::make_shared<ParticipantDeviceModel>(device, false);
		connect(this, &ParticipantDeviceListModel::securityLevelChanged, deviceModel.get(), &ParticipantDeviceModel::onSecurityLevelChanged);
		connect(this, &ParticipantDeviceListModel::participantDeviceMediaAvailabilityChanged, deviceModel.get(), &ParticipantDeviceModel::videoEnabledChanged);
		mList << deviceModel;
	}
}

ParticipantDeviceListModel::ParticipantDeviceListModel (CallModel * callModel, QObject *parent) : QAbstractListModel(parent) {
	if(callModel && callModel->isConference()) {
		mCallModel = callModel;
		auto conferenceModel = callModel->getConferenceModel();
		/*
		mList << std::make_shared<ParticipantDeviceModel>(callModel, true);// Add Me in device list
		qWarning() << "Me devices : " << conferenceModel->getConference()->getMe()->getDevices().size();
//		auto meDevices = conferenceModel->getConference()->getMe()->getDevices();
	//	if(meDevices.size() > 0) 

		std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = conferenceModel->getConference()->getParticipantDeviceList();
		updateDevices(devices);
		qWarning() << "Instanciate Participant Device list model with " << mList.size() << " devices";
		*/
		connect(conferenceModel.get(), &ConferenceModel::participantDeviceAdded, this, &ParticipantDeviceListModel::onParticipantDeviceAdded);
		connect(conferenceModel.get(), &ConferenceModel::participantDeviceRemoved, this, &ParticipantDeviceListModel::onParticipantDeviceRemoved);
		connect(conferenceModel.get(), &ConferenceModel::participantDeviceMediaAvailabilityChanged, this, &ParticipantDeviceListModel::onParticipantDeviceMediaAvailabilityChanged);
		connect(conferenceModel.get(), &ConferenceModel::conferenceStateChanged, this, &ParticipantDeviceListModel::onConferenceStateChanged);
	}
}

int ParticipantDeviceListModel::rowCount (const QModelIndex &index) const{
	qWarning() << "rowCount: " << mList.count();
	return mList.count();
}

int ParticipantDeviceListModel::count(){
	qWarning() << "count: " << mList.count();
	return mList.count();
}

void ParticipantDeviceListModel::updateDevices(std::shared_ptr<linphone::Participant> participant){
	std::list<std::shared_ptr<linphone::ParticipantDevice>> devices = participant->getDevices() ;
	beginResetModel();
	qWarning() << "Update devices from participant";
	mList.clear();
	for(auto device : devices){
		auto deviceModel = std::make_shared<ParticipantDeviceModel>(device, false);
		connect(this, &ParticipantDeviceListModel::securityLevelChanged, deviceModel.get(), &ParticipantDeviceModel::onSecurityLevelChanged);
		connect(this, &ParticipantDeviceListModel::participantDeviceMediaAvailabilityChanged, deviceModel.get(), &ParticipantDeviceModel::videoEnabledChanged);
		mList << deviceModel;
	}
	endResetModel();
	emit countChanged();
	emit layoutChanged();
}

void ParticipantDeviceListModel::updateDevices(const std::list<std::shared_ptr<linphone::ParticipantDevice>>& devices, const bool& isMe){
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
				auto deviceModel = std::make_shared<ParticipantDeviceModel>(device, isMe);
				connect(this, &ParticipantDeviceListModel::securityLevelChanged, deviceModel.get(), &ParticipantDeviceModel::onSecurityLevelChanged);
				connect(this, &ParticipantDeviceListModel::participantDeviceMediaAvailabilityChanged, deviceModel.get(), &ParticipantDeviceModel::videoEnabledChanged);
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
}

QHash<int, QByteArray> ParticipantDeviceListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$participantDevice";
	return roles;
}

QVariant ParticipantDeviceListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(mList[row].get());
	
	return QVariant();
}

bool ParticipantDeviceListModel::removeRow (int row, const QModelIndex &parent){
	return removeRows(row, 1, parent);
}

bool ParticipantDeviceListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mList.takeAt(row);
	
	endRemoveRows();
	
	return true;
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
			int row = mList.count();
			beginInsertRows(QModelIndex(), row, row);
			auto deviceModel = std::make_shared<ParticipantDeviceModel>(realParticipantDevice, false);
			connect(this, &ParticipantDeviceListModel::securityLevelChanged, deviceModel.get(), &ParticipantDeviceModel::onSecurityLevelChanged);
			connect(this, &ParticipantDeviceListModel::participantDeviceMediaAvailabilityChanged, deviceModel.get(), &ParticipantDeviceModel::videoEnabledChanged);
			mList << deviceModel;
			endInsertRows();
			emit countChanged();
			//emit layoutChanged();
			return;
		}
	}
	qWarning() << "No participant device found from const linphone::ParticipantDevice at onParticipantDeviceAdded";
}

void ParticipantDeviceListModel::onParticipantDeviceRemoved(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice){
	qWarning() << "Removing participant";
	int row = 0;
	for(auto device : mList){
		if( device->getDevice() == participantDevice){
			removeRow(row);
			emit countChanged();
			//emit layoutChanged();
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

void ParticipantDeviceListModel::onParticipantDeviceMediaAvailabilityChanged(const std::shared_ptr<const linphone::ParticipantDevice> & participantDevice) {
	emit participantDeviceMediaAvailabilityChanged();
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
				mList.push_front(std::make_shared<ParticipantDeviceModel>(mCallModel, true));// Add Me in device list
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