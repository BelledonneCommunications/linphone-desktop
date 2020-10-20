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

#include "ContactsImporterPluginsManager.hpp"
#include "ContactsImporterModel.hpp"
#include "include/LinphoneApp/PluginNetworkHelper.hpp"

#include "utils/Utils.hpp"
#include "app/paths/Paths.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/contacts/ContactsImporterListModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"


#include <QDir>
#include <QPluginLoader>
#include <QDebug>
#include <QJsonDocument>
#include <QFileDialog>
#include <QMessageBox>


// =============================================================================

ContactsImporterPluginsManager::ContactsImporterPluginsManager(QObject * parent) : PluginsManager(parent){
}

QVariantMap ContactsImporterPluginsManager::getContactsImporterPluginDescription(const QString& pluginID) {
	QVariantMap description;
	QJsonDocument doc = getJson(pluginID);

	description = doc.toVariant().toMap();

	if(description.contains("fields")){
		auto fields = description["fields"].toList();
		auto removedFields = std::remove_if(fields.begin(), fields.end(),
										  [](const QVariant& f){
							auto field = f.toMap();
							return field.contains("capability") && ((field["capability"].toInt() & PluginDataAPI::CONTACTS) != PluginDataAPI::CONTACTS);
		});
		fields.erase(removedFields, fields.end());
		description["fields"] = fields;
	}
	return description;
}

void ContactsImporterPluginsManager::openNewPlugin(){
	PluginsManager::openNewPlugin("Import Address Book Connector");
}

QVariantList ContactsImporterPluginsManager::getPlugins(){
	return PluginsManager::getPlugins(PluginDataAPI::CONTACTS);
}

void ContactsImporterPluginsManager::importContacts(ContactsImporterModel * model) {
	if(model){
		QString pluginID = model->getFields()["pluginID"].toString();
		if(!pluginID.isEmpty()){
			if( !PluginsManager::gPluginsMap.contains(pluginID))
				qInfo() << "Unknown " << pluginID;
			model->importContacts();
		}else
			qWarning() << "Error : Cannot import contacts : pluginID is empty";
	}
}

void ContactsImporterPluginsManager::importContacts(const QVector<QMultiMap<QString, QString> >& pContacts ){
	for(int i = 0 ; i < pContacts.size() ; ++i){
		VcardModel  * card = CoreManager::getInstance()->createDetachedVcardModel();
		SipAddressesModel * sipConvertion = CoreManager::getInstance()->getSipAddressesModel();
		QString domain = pContacts[i].values("sipDomain").at(0);
		//if(pContacts[i].contains("phoneNumber"))
		//	card->addSipAddress(sipConvertion->interpretSipAddress(pContacts[i].values("phoneNumber").at(0)+"@"+domain, false));
		if(pContacts[i].contains("displayName")  && pContacts[i].values("displayName").size() > 0)
			card->setUsername(pContacts[i].values("displayName").at(0));
		if(pContacts[i].contains("sipUsername") && pContacts[i].values("sipUsername").size() > 0){
			QString sipUsername = pContacts[i].values("sipUsername").at(0);
			QString convertedUsername = sipConvertion->interpretSipAddress(sipUsername, domain);
			if(!convertedUsername.contains(domain)){
				convertedUsername = convertedUsername.replace('@',"%40")+"@"+domain;
			}
			card->addSipAddress(convertedUsername);
			if( sipUsername.contains('@')){
				card->addEmail(sipUsername);
			}
		}
		if(pContacts[i].contains("email"))
			for(auto email : pContacts[i].values("email"))
				card->addEmail(email);
		if(pContacts[i].contains("organization"))
			for(auto company : pContacts[i].values("organization"))
				card->addCompany(company);
		if( card->getSipAddresses().size()>0){
			CoreManager::getInstance()->getContactsListModel()->addContact(card);
		}else
			delete card;
	}
}
