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
#include <linphoneapp/contacts/ContactsImporterPlugin.hpp>
#include <linphoneapp/contacts/ContactsImporterNetworkAPI.hpp>
#include <linphoneapp/contacts/ContactsImporterDataAPI.hpp>
#include "utils/Utils.hpp"
#include "app/paths/Paths.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"


#include <QDir>
#include <QPluginLoader>
#include <QDebug>
#include <QJsonDocument>
#include <QFileDialog>
#include <QMessageBox>


// =============================================================================

const QString ContactsImporterPluginsManager::ContactsSection("contacts_importer");
QMap<QString, QString> ContactsImporterPluginsManager::gPluginsMap;

ContactsImporterPluginsManager::ContactsImporterPluginsManager(QObject * parent) : QObject(parent){
}
ContactsImporterPlugin * ContactsImporterPluginsManager::getPlugin(const QString &pluginTitle){
	ContactsImporterPlugin * plugin = nullptr;
	QStringList pluginPaths = Paths::getPluginsContactsFolders();
	for(int i = 0 ; i < pluginPaths.size() ; ++i) {
		QString pluginPath = pluginPaths[i] +gPluginsMap[pluginTitle];
		QPluginLoader loader(pluginPath);
		if( auto instance = loader.instance()) {
			plugin = qobject_cast< ContactsImporterPlugin* >(instance);
			return plugin;
		}
	}
	return plugin;
}
void ContactsImporterPluginsManager::openNewPlugin(){
	QString fileName = QFileDialog::getOpenFileName(nullptr, "Import Address Book Connector");
	int doCopy = QMessageBox::Yes;
	if(fileName != ""){
		QFileInfo fileInfo(fileName);
		QString path = Utils::coreStringToAppString(Paths::getPluginsContactsDirPath())+fileInfo.fileName();
		if( QFile::exists(path)){
			doCopy = QMessageBox::question(nullptr, "Importing Address Book Connector", "The plugin already exists. Do you want to overwrite it?", QMessageBox::Yes, QMessageBox::No);
			if( doCopy == QMessageBox::Yes)
				QFile::remove(path);
		}
		if(doCopy != QMessageBox::Yes || !QFile::copy(fileName, path))
			qWarning() << "Cannot copy plugin";
	}
}
QVariantList ContactsImporterPluginsManager::getContactsImporterPlugins() {
	QVariantList plugins;
	QStringList pluginPaths = Paths::getPluginsContactsFolders();
	gPluginsMap.clear();
	for(int i = 0 ; i < pluginPaths.size() ; ++i) {
		QString pluginPath = pluginPaths[i];
		QDir dir(pluginPath);
		QStringList pluginFiles = dir.entryList(QDir::Files);
		for(int i = 0 ; i < pluginFiles.size() ; ++i) {
			QPluginLoader loader(pluginPath+pluginFiles[i]);
			if (auto instance = loader.instance()) {
				if (auto plugin = qobject_cast< ContactsImporterPlugin* >(instance)){
					QJsonDocument doc = QJsonDocument::fromJson(plugin->descriptionToJson().toUtf8());
					QVariantMap desc;
					desc["title"] = doc["title"];
					if(!doc["title"].toString().isEmpty()){
						gPluginsMap[doc["title"].toString()] = pluginFiles[i];
						plugins.push_back(desc);
					}
					
				} else {
					qWarning()<< "qobject_cast<> returned nullptr";
				}
			} else {
				qWarning()<< loader.errorString();
			}
		}
		std::sort(plugins.begin(), plugins.end());
	}
	return plugins;
}

QVariantMap ContactsImporterPluginsManager::getContactsImporterPluginDescription(const QString& pluginTitle) {
	ContactsImporterPlugin * plugin = getPlugin(pluginTitle);
	QVariantMap description;
	if( plugin ){
		QJsonDocument doc = QJsonDocument::fromJson(plugin->descriptionToJson().toUtf8());
		description = doc.toVariant().toMap();
	}
	return description;
}
void ContactsImporterPluginsManager::importContacts(ContactsImporterModel * model) {
	model->importContacts();
}

void ContactsImporterPluginsManager::importContacts(const QVector<QMultiMap<QString, QString> >& pContacts ){
	for(int i = 0 ; i < pContacts.size() ; ++i){
		VcardModel  * card = CoreManager::getInstance()->createDetachedVcardModel();
		SipAddressesModel * sipConvertion = CoreManager::getInstance()->getSipAddressesModel();
		QString domain = pContacts[i].values("sipDomain").at(0);

		//if(pContacts[i].contains("phoneNumber"))
		//	card->addSipAddress(sipConvertion->interpretSipAddress(pContacts[i].values("phoneNumber").at(0)+"@"+domain, false));
		if(pContacts[i].contains("displayName"))
			card->setUsername(pContacts[i].values("displayName").at(0));
		if(pContacts[i].contains("sipUsername")){
			QString sipUsername = pContacts[i].values("sipUsername").at(0);
			QString convertedUsername = sipConvertion->interpretSipAddress(sipUsername, domain);
			if(!convertedUsername.contains(domain)){
				convertedUsername = convertedUsername.replace('@',"%40")+"@"+domain;
			}
			card->addSipAddress(convertedUsername);
			if( sipUsername.contains('@'))
				card->addEmail(sipUsername);
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

QVariantMap ContactsImporterPluginsManager::getDefaultValues(const QString& pluginTitle){
	QVariantMap defaultValues;
	QVariantMap description = getContactsImporterPluginDescription(pluginTitle);
	for(auto field : description["fields"].toList()){
		auto details = field.toMap();
		if( details.contains("fieldId") && details.contains("defaultData")){
			defaultValues[details["fieldId"].toString()] = details["defaultData"].toString();
		}
	}
	return defaultValues;
}
