/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include "ContactsImporterModel.hpp"
#include "ContactsImporterPluginsManager.hpp"
#include "../../utils/Utils.hpp"

//#include <linphoneapp/contacts/ContactsImporterDataAPI.hpp>
#include "include/LinphoneApp/PluginDataAPI.hpp"

#include <QPluginLoader>
#include <QDebug>

// =============================================================================

using namespace std;


ContactsImporterModel::ContactsImporterModel (PluginDataAPI * data, QObject *parent) : PluginsModel(parent) {
	mIdentity = -1;
	mData = nullptr;
	setDataAPI(data);
}

// -----------------------------------------------------------------------------

void ContactsImporterModel::setDataAPI(PluginDataAPI *data){
	if(mData){// Unload the current plugin loader and delete it from memory
		QPluginLoader * loader = mData->getPluginLoader();
		delete mData;
		if(loader){
			loader->unload();
			delete loader;
		}
		mData = data;
	}else
		mData = data;
	if( mData){
		connect(mData, &PluginDataAPI::inputFieldsChanged, this, &ContactsImporterModel::fieldsChanged);
		connect(mData, &PluginDataAPI::message, this, &ContactsImporterModel::messageReceived);
		connect(mData, &PluginDataAPI::dataReceived, this, &ContactsImporterModel::parsedContacts);
	}
}
PluginDataAPI *ContactsImporterModel::getDataAPI(){
	return mData;
}
bool ContactsImporterModel::isUsable(){
	if( mData){
		if( !mData->getPluginLoader()->isLoaded())
			mData->getPluginLoader()->load();
		return mData->getPluginLoader()->isLoaded();
	}else
		return false;
}

QVariantMap ContactsImporterModel::getFields(){
	return (isUsable()?mData->getInputFields(PluginDataAPI::CONTACTS)[PluginDataAPI::CONTACTS] :QVariantMap());
}

void ContactsImporterModel::setFields(const QVariantMap &pFields){
	if( isUsable())
		mData->setInputFields(PluginDataAPI::CONTACTS, pFields);
}

int ContactsImporterModel::getIdentity()const{
	return mIdentity;
}

void ContactsImporterModel::setIdentity(const int &pIdentity){
	if( mIdentity != pIdentity){
		mIdentity = pIdentity;
		if(mData && mData->getPluginLoader()->isLoaded())
			mData->setSectionConfiguration(PluginsManager::gPluginsConfigSection+"_"+QString::number(mIdentity));
		emit identityChanged(mIdentity);
	}
}

void ContactsImporterModel::loadConfiguration(){
	if(isUsable())
		mData->loadConfiguration(PluginDataAPI::CONTACTS);
}

void ContactsImporterModel::importContacts(){
	if(isUsable()){
		qInfo() << "Importing contacts with " << mData->getInputFields(PluginDataAPI::CONTACTS)[PluginDataAPI::CONTACTS]["pluginTitle"];
		QPluginLoader * loader = mData->getPluginLoader();
		if( !loader)
			qWarning() << "Loader is NULL";
		else{
			qWarning() << "Plugin loaded Status : " << loader->isLoaded() << " for " << loader->fileName();
		}
		mData->run(PluginDataAPI::CONTACTS);
	}else
		qWarning() << "Cannot import contacts, mData is NULL or plugin cannot be loaded ";
}

void ContactsImporterModel::parsedContacts(const PluginDataAPI::PluginCapability& actionType,  QVector<QMultiMap<QString, QString> > contacts){
	if(actionType == PluginDataAPI::CONTACTS)
		ContactsImporterPluginsManager::importContacts(contacts);
}

void ContactsImporterModel::updateInputs(const PluginDataAPI::PluginCapability& capability, const QVariantMap &inputs){
	if(capability == PluginDataAPI::CONTACTS)
		setFields(inputs);
}

void ContactsImporterModel::messageReceived(const QtMsgType& type, const QString &message){
	if( type == QtMsgType::QtInfoMsg)
		emit statusMessage(message);
	else
		emit errorMessage(message);
}
