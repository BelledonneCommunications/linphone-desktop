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

#include <linphoneapp/contacts/ContactsImporterDataAPI.hpp>

#include <QPluginLoader>
#include <QDebug>

// =============================================================================

using namespace std;


ContactsImporterModel::ContactsImporterModel (ContactsImporterDataAPI * data, QObject *parent) : QObject(parent) {
	mIdentity = -1;
	mData = nullptr;
	setDataAPI(data);
}

// -----------------------------------------------------------------------------

void ContactsImporterModel::setDataAPI(ContactsImporterDataAPI *data){
	if(mData){
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
		connect(mData, &ContactsImporterDataAPI::inputFieldsChanged, this, &ContactsImporterModel::fieldsChanged);
		connect(mData, SIGNAL(errorMessage(const QString &)), this, SIGNAL(errorMessage(const QString &)));
		connect(mData, SIGNAL(statusMessage(const QString &)), this, SIGNAL(statusMessage(const QString &)));
		connect(mData, SIGNAL(contactsReceived(QVector<QMultiMap<QString,QString> > )), this, SLOT(parsedContacts(QVector<QMultiMap<QString, QString> > )));
	}
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
	return (isUsable()?mData->getInputFields() :QVariantMap());
}
void ContactsImporterModel::setFields(const QVariantMap &pFields){
	if( isUsable())
		mData->setInputFields(pFields);
}

int ContactsImporterModel::getIdentity()const{
	return mIdentity;
}

void ContactsImporterModel::setIdentity(const int &pIdentity){
	if( mIdentity != pIdentity){
		mIdentity = pIdentity;
		if(mData && mData->getPluginLoader()->isLoaded())
			mData->setSectionConfiguration(Utils::appStringToCoreString(ContactsImporterPluginsManager::ContactsSection+"_"+QString::number(mIdentity)));
		emit identityChanged(mIdentity);
	}
}

void ContactsImporterModel::loadConfiguration(){
	if(isUsable())
		mData->loadConfiguration();
}
void ContactsImporterModel::importContacts(){
	if(isUsable()){
		qInfo() << "Importing contacts with " << mData->getInputFields()["pluginTitle"];
		QPluginLoader * loader = mData->getPluginLoader();
		if( !loader)
			qWarning() << "Loader is NULL";
		else{
			qWarning() << "Plugin loaded Status : " << loader->isLoaded() << " for " << loader->fileName();
		}
		mData->importContacts();
	}else
		qWarning() << "Cannot import contacts, mData is NULL or plugin cannot be loaded ";
}
void ContactsImporterModel::parsedContacts(QVector<QMultiMap<QString, QString> > contacts){
	ContactsImporterPluginsManager::importContacts(contacts);
}
void ContactsImporterModel::updateInputs(const QVariantMap &inputs){
	setFields(inputs);
}
