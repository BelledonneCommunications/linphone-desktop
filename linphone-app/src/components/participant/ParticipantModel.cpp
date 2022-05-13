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

#include "app/App.hpp"

#include "ParticipantModel.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"

// =============================================================================

using namespace std;

ParticipantModel::ParticipantModel (shared_ptr<linphone::Participant> linphoneParticipant, QObject *parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mParticipant = linphoneParticipant;
	mAdminStatus = false;
	if(mParticipant){
		mAdminStatus = mParticipant->isAdmin();
		mParticipantDevices = QSharedPointer<ParticipantDeviceListModel>::create(mParticipant);
		connect(this, &ParticipantModel::deviceSecurityLevelChanged, mParticipantDevices.get(), &ParticipantDeviceListModel::securityLevelChanged);
	}
}

// -----------------------------------------------------------------------------

ContactModel *ParticipantModel::getContactModel() const{
	return CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(getSipAddress()).get();
}

int ParticipantModel::getSecurityLevel() const{
	return (mParticipant ? (int)mParticipant->getSecurityLevel() : 0);
}

int ParticipantModel::getDeviceCount(){
	int count = (mParticipant ? mParticipant->getDevices().size() : 0);
	if(mParticipant && count != mParticipantDevices->getCount()){
		mParticipantDevices->updateDevices(mParticipant);
	}
	return count;
}

bool ParticipantModel::getInviting() const{
	return !mParticipant;
}

bool ParticipantModel::isMe() const{
	return Utils::isMe(getSipAddress());
}

QString ParticipantModel::getSipAddress() const{
    return (mParticipant ? Utils::coreStringToAppString(mParticipant->getAddress()->asString()) : mSipAddress);
}

QDateTime ParticipantModel::getCreationTime() const{
    return (mParticipant ? QDateTime::fromSecsSinceEpoch(mParticipant->getCreationTime()) : QDateTime::currentDateTime());
}

bool ParticipantModel::getAdminStatus() const{
    return (mParticipant ? mParticipant->isAdmin() : mAdminStatus);
}

bool ParticipantModel::isFocus() const{
    return (mParticipant ? mParticipant->isFocus() : false);
}

//------------------------------------------------------------------------

void ParticipantModel::setSipAddress(const QString& address){
	if(mSipAddress != address){
		mSipAddress = address;
		emit sipAddressChanged();
	}
}

void ParticipantModel::setAdminStatus(const bool& status){	
	if(status != mAdminStatus || mParticipant && status != mParticipant->isAdmin()){
		mAdminStatus = status;
		if(mParticipant)
			emit updateAdminStatus(mParticipant, mAdminStatus);
		else
			emit adminStatusChanged();
	}
}

void ParticipantModel::setParticipant(std::shared_ptr<linphone::Participant> participant){
	mParticipant = participant;
	if(mParticipant){
		mAdminStatus = mParticipant->isAdmin();
		mParticipantDevices = QSharedPointer<ParticipantDeviceListModel>::create(mParticipant);
		connect(this, &ParticipantModel::deviceSecurityLevelChanged, mParticipantDevices.get(), &ParticipantDeviceListModel::securityLevelChanged);
	}
	emit invitingChanged();
}
//------------------------------------------------------------------------

void ParticipantModel::onSecurityLevelChanged(){
	emit securityLevelChanged();
}
void ParticipantModel::onDeviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device){
	emit deviceSecurityLevelChanged(device);
}

std::shared_ptr<linphone::Participant>  ParticipantModel::getParticipant(){
	return mParticipant;
}

ParticipantDeviceProxyModel * ParticipantModel::getProxyDevices(){
	ParticipantDeviceProxyModel * devices = new ParticipantDeviceProxyModel();
	devices->setParticipant(this);
	return devices;
}

QSharedPointer<ParticipantDeviceListModel> ParticipantModel::getParticipantDevices(){
	return mParticipantDevices;
}

void ParticipantModel::startInvitation(const int& secs){
	QTimer::singleShot(secs * 1000, this, &ParticipantModel::onEndOfInvitation);
}

void ParticipantModel::onEndOfInvitation(){
	if( getInviting())
		emit invitationTimeout(this);
}

