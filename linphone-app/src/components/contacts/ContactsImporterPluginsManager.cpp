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

const QString ContactsImporterPluginsManager::ContactsSection("contacts_importer");
QMap<QString, QString> ContactsImporterPluginsManager::gPluginsMap;

ContactsImporterPluginsManager::ContactsImporterPluginsManager(QObject * parent) : QObject(parent){
}
QPluginLoader * ContactsImporterPluginsManager::getPlugin(const QString &pluginTitle){
	QStringList pluginPaths = Paths::getPluginsContactsFolders();
	if( gPluginsMap.contains(pluginTitle)){
		for(int i = 0 ; i < pluginPaths.size() ; ++i) {
			QString pluginPath = pluginPaths[i] +gPluginsMap[pluginTitle];
			QPluginLoader * loader = new QPluginLoader(pluginPath);
			loader->setLoadHints(0);
			if( auto instance = loader->instance()) {
				auto plugin = qobject_cast< ContactsImporterPlugin* >(instance);
				if (plugin)
					return loader;
				else
					loader->unload();
			}
			delete loader;
		}
	}
	return nullptr;
}
ContactsImporterDataAPI * ContactsImporterPluginsManager::createInstance(const QString &pluginTitle){
	ContactsImporterDataAPI * dataInstance = nullptr;
	ContactsImporterPlugin * plugin = nullptr;
	if( gPluginsMap.contains(pluginTitle)){
		QStringList pluginPaths = Paths::getPluginsContactsFolders();
		for(int i = 0 ; i < pluginPaths.size() ; ++i) {
			QString pluginPath = pluginPaths[i] +gPluginsMap[pluginTitle];
			QPluginLoader * loader = new QPluginLoader(pluginPath);
			loader->setLoadHints(0);
			if( auto instance = loader->instance()) {
				plugin = qobject_cast< ContactsImporterPlugin* >(instance);
				if (plugin) {
					 dataInstance = plugin->createInstance(CoreManager::getInstance()->getCore(), loader);
					 return dataInstance;
				}else
					loader->unload();
			}
			delete loader;
		}
	}
	return dataInstance;
}
QJsonDocument ContactsImporterPluginsManager::getJson(const QString &pluginTitle){
	QJsonDocument doc;
	QPluginLoader * pluginLoader = getPlugin(pluginTitle);
	if( pluginLoader ){
		auto instance = pluginLoader->instance();
		if( instance ){
			ContactsImporterPlugin * plugin = qobject_cast< ContactsImporterPlugin* >(instance);
			if( plugin ){
				doc = QJsonDocument::fromJson(plugin->descriptionToJson().toUtf8());
			}
		}
		pluginLoader->unload();
		delete pluginLoader;
	}
	return doc;
}
void ContactsImporterPluginsManager::openNewPlugin(){
	QString fileName = QFileDialog::getOpenFileName(nullptr, "Import Address Book Connector");
	QString pluginTitle;
	QList<ContactsImporterModel*> importersToReset;
	int doCopy = QMessageBox::Yes;
	bool cannotRemovePlugin = false;
	if(fileName != ""){
		QFileInfo fileInfo(fileName);
		QString path = Utils::coreStringToAppString(Paths::getPluginsContactsDirPath());
		QPluginLoader loader(fileName);
		loader.setLoadHints(0);
		auto instance = loader.instance();
		if( instance ){
			ContactsImporterPlugin * plugin = qobject_cast< ContactsImporterPlugin* >(instance);
			if(plugin){// This plugin is good. Get the title
				QJsonDocument doc = QJsonDocument::fromJson(plugin->descriptionToJson().toUtf8());
				QVariantMap desc;
				pluginTitle = doc["pluginTitle"].toString();
			}
			loader.unload();
		}
		if(!pluginTitle.isEmpty()){// Check all plugins that have this title
			if( gPluginsMap.contains(pluginTitle)){
				doCopy = QMessageBox::question(nullptr, "Importing Address Book Connector", "The plugin already exists. Do you want to overwrite it?\nPlugin:\n"+gPluginsMap[pluginTitle], QMessageBox::Yes, QMessageBox::No);
				if( doCopy == QMessageBox::Yes){
					auto importers = CoreManager::getInstance()->getContactsImporterListModel()->getList();
					for(auto importer : importers){
						QVariantMap fields = importer->getFields();
						if(fields["pluginTitle"] == pluginTitle){
							importer->setDataAPI(nullptr);
							importersToReset.append(importer);
						}
					}
					QStringList pluginPaths = Paths::getPluginsContactsFolders();
					for(int i = 0 ; !cannotRemovePlugin && i < pluginPaths.size()-1 ; ++i) {// Ignore the last path as it is the app folder
						QString pluginPath = pluginPaths[i];
						if(QFile::exists(pluginPath+gPluginsMap[pluginTitle])){
							if(!QFile::remove(pluginPath+gPluginsMap[pluginTitle]))
								cannotRemovePlugin = true;
						}
					}
					if(!cannotRemovePlugin)
						gPluginsMap[pluginTitle] = "";
				}
			}
		}
		if(doCopy == QMessageBox::Yes ){
			if( cannotRemovePlugin)// Qt will not unload library from memory so files cannot be removed. See https://bugreports.qt.io/browse/QTBUG-68880
				QMessageBox::information(nullptr, "Importing Address Book Connector", "The plugin cannot be replaced. You have to exit the application and delete manually the plugin file in\n"+path);
			else if( !QFile::copy(fileName, path+fileInfo.fileName()))
				QMessageBox::information(nullptr, "Importing Address Book Connector", "The plugin cannot be copied. You have to copy manually the plugin file to\n"+path);
			else {
				gPluginsMap[pluginTitle] = fileInfo.fileName();
				for(auto importer : importersToReset)
					importer->setDataAPI(createInstance(pluginTitle));
			}
		}
	}
}
QVariantList ContactsImporterPluginsManager::getContactsImporterPlugins() {
	QVariantList plugins;
	QStringList pluginPaths = Paths::getPluginsContactsFolders();
	gPluginsMap.clear();
	for(int pathIndex = pluginPaths.size()-1 ; pathIndex >= 0 ; --pathIndex) {// Start from app package. This sort ensure the priority on user plugins
		QString pluginPath = pluginPaths[pathIndex];
		QDir dir(pluginPath);
		QStringList pluginFiles = dir.entryList(QDir::Files);
		for(int i = 0 ; i < pluginFiles.size() ; ++i) {
			QPluginLoader loader(pluginPath+pluginFiles[i]);
			loader.setLoadHints(0);
			if (auto instance = loader.instance()) {
				if (auto plugin = qobject_cast< ContactsImporterPlugin* >(instance)){
					QJsonDocument doc = QJsonDocument::fromJson(plugin->descriptionToJson().toUtf8());
					QVariantMap desc;
					desc["pluginTitle"] = doc["pluginTitle"];
					if(!doc["pluginTitle"].toString().isEmpty()){
						gPluginsMap[doc["pluginTitle"].toString()] = pluginFiles[i];
						plugins.push_back(desc);
					}
				} else {
					qWarning()<< "This plugin is not updated and cannot be used : " << pluginFiles[i] ;
				}
				loader.unload();
			} else {
				qWarning()<< loader.errorString();
			}
		}
		std::sort(plugins.begin(), plugins.end());
	}
	return plugins;
}

QVariantMap ContactsImporterPluginsManager::getContactsImporterPluginDescription(const QString& pluginTitle) {
	QVariantMap description;
	QJsonDocument doc = getJson(pluginTitle);
	description = doc.toVariant().toMap();
	return description;
}
void ContactsImporterPluginsManager::importContacts(ContactsImporterModel * model) {
	qWarning() << "Importing contacts";
	if(model){
		QString pluginTitle = model->getFields()["pluginTitle"].toString();
		if(!pluginTitle.isEmpty()){
			if( !gPluginsMap.contains(pluginTitle))
				qWarning() << "Unknown " << pluginTitle;
			qWarning() << "Importing contacts from " << gPluginsMap[pluginTitle] << " for " << pluginTitle;
			model->importContacts();
		}else
			qWarning() << "pluginTitle is empty";
	}
}

void ContactsImporterPluginsManager::importContacts(const QVector<QMultiMap<QString, QString> >& pContacts ){
	qWarning() << "Change contacts into VCard : "<< pContacts.size() ;
	for(int i = 0 ; i < pContacts.size() ; ++i){
		qWarning() << "Create VCard";
		VcardModel  * card = CoreManager::getInstance()->createDetachedVcardModel();
		qWarning() << "Getting SipAddressModel";
		SipAddressesModel * sipConvertion = CoreManager::getInstance()->getSipAddressesModel();
		if( sipConvertion == NULL)
			qWarning() << "SipAddressModel is NULL";
		qWarning() << "Get Domain";
		QString domain = pContacts[i].values("sipDomain").at(0);

		//if(pContacts[i].contains("phoneNumber"))
		//	card->addSipAddress(sipConvertion->interpretSipAddress(pContacts[i].values("phoneNumber").at(0)+"@"+domain, false));
		qWarning() << "Check for displayName";
		if(pContacts[i].contains("displayName")  && pContacts[i].values("displayName").size() > 0)
			card->setUsername(pContacts[i].values("displayName").at(0));
		qWarning() << "Check for sipUsername";
		if(pContacts[i].contains("sipUsername") && pContacts[i].values("sipUsername").size() > 0){
			QString sipUsername = pContacts[i].values("sipUsername").at(0);
			qWarning() << "Interpret SipAddress with : " << sipUsername << " and " << domain;
			QString convertedUsername = sipConvertion->interpretSipAddress(sipUsername, domain);
			if(!convertedUsername.contains(domain)){
				qWarning() << "convertedUsername doesn't have domain, replace @ : " << convertedUsername;
				convertedUsername = convertedUsername.replace('@',"%40")+"@"+domain;
			}else
				qWarning() << "convertedUsername have domain : " << convertedUsername;
			qWarning() << "Adding sip address";
			card->addSipAddress(convertedUsername);
			if( sipUsername.contains('@')){
				qWarning() << "sipUsername have @, add Email";
				card->addEmail(sipUsername);
			}
		}
		qWarning() << "Check for email";
		if(pContacts[i].contains("email"))
			for(auto email : pContacts[i].values("email"))
				card->addEmail(email);
		qWarning() << "Check for organization";
		if(pContacts[i].contains("organization"))
			for(auto company : pContacts[i].values("organization"))
				card->addCompany(company);
		if( card->getSipAddresses().size()>0){
			qWarning() << "Add Contact";
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
