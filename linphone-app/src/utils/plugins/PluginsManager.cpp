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

#include "PluginsManager.hpp"
//#include "ContactsImporterModel.hpp"
#include "../../../include/LinphoneApp/LinphonePlugin.hpp"
#include "../../../include/LinphoneApp/PluginDataAPI.hpp"
#include "../../../include/LinphoneApp/PluginNetworkHelper.hpp"

#include "utils/Utils.hpp"
#include "app/paths/Paths.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/contacts/ContactsImporterListModel.hpp"
#include "components/contacts/ContactsImporterModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"


#include <QDir>
#include <QPluginLoader>
#include <QDebug>
#include <QJsonDocument>
#include <QFileDialog>
#include <QMessageBox>


// =============================================================================

QMap<QString, QString> PluginsManager::gPluginsMap;
QString PluginsManager::gPluginsConfigSection = "AppPlugin";

PluginsManager::PluginsManager(QObject * parent) : QObject(parent){
}

QPluginLoader * PluginsManager::getPlugin(const QString &pluginIdentity){
	QStringList pluginPaths = Paths::getPluginsAppFolders();// Get all paths
	if( gPluginsMap.contains(pluginIdentity)){
		for(int i = 0 ; i < pluginPaths.size() ; ++i) {
			QString pluginPath = pluginPaths[i] +gPluginsMap[pluginIdentity];
			QPluginLoader * loader = new QPluginLoader(pluginPath);
			loader->setLoadHints(0);	// this force Qt to unload the plugin from memory when we request it. Be carefull by not having a plugin instance or data created inside the plugin after the unload.
			if( auto instance = loader->instance()) {
				auto plugin = qobject_cast< LinphonePlugin* >(instance);
				if (plugin )
					return loader;
				else{
					qWarning() << loader->errorString();
					loader->unload();
				}
			}
			delete loader;
		}
	}
	return nullptr;
}

void * PluginsManager::createInstance(const QString &pluginIdentity){
	void * dataInstance = nullptr;
	LinphonePlugin * plugin = nullptr;
	if( gPluginsMap.contains(pluginIdentity)){
		QStringList pluginPaths = Paths::getPluginsAppFolders();
		for(int i = 0 ; i < pluginPaths.size() ; ++i) {
			QString pluginPath = pluginPaths[i] +gPluginsMap[pluginIdentity];
			QPluginLoader * loader = new QPluginLoader(pluginPath);
			loader->setLoadHints(0);	// this force Qt to unload the plugin from memory when we request it. Be carefull by not having a plugin instance or data created inside the plugin after the unload.
			if( auto instance = loader->instance()) {
				plugin = qobject_cast< LinphonePlugin* >(instance);
				if (plugin) {
					try{
						dataInstance = plugin->createInstance(CoreManager::getInstance()->getCore().get(), loader);
						return dataInstance;
					}catch(...){
						loader->unload();
					}
				}else
					loader->unload();
			}
			delete loader;
		}
	}
	return dataInstance;
}

QJsonDocument PluginsManager::getJson(const QString &pluginIdentity){
	QJsonDocument doc;
	QPluginLoader * pluginLoader = getPlugin(pluginIdentity);
	if( pluginLoader ){
		auto instance = pluginLoader->instance();
		if( instance ){
			LinphonePlugin * plugin = qobject_cast< LinphonePlugin* >(instance);
			if( plugin ){
				doc = QJsonDocument::fromJson(plugin->getGUIDescriptionToJson().toUtf8());
			}
		}
		pluginLoader->unload();
		delete pluginLoader;
	}
	return doc;
}
QList<PluginsModel*> PluginsManager::getImporterModels(const QStringList &capabilities){
	QList<PluginsModel*> models;
	for(int i = 0 ; i < capabilities.size() ; ++i){
		if( capabilities[i] == "CONTACTS")
			models += CoreManager::getInstance()->getContactsImporterListModel()->getList();
	}
	return models;
}
void PluginsManager::openNewPlugin(const QString &pTitle){

	QString fileName = QFileDialog::getOpenFileName(nullptr, pTitle);
	QString pluginIdentity;
	QStringList capabilities;
	QList<PluginsModel*> modelsToReset;
	int doCopy = QMessageBox::Yes;
	bool cannotRemovePlugin = false;
	//QVersionNumber pluginVersion, apiVersion = LinphonePlugin::gPluginVersion;
	if(fileName != ""){
		QFileInfo fileInfo(fileName);
		QString path = Utils::coreStringToAppString(Paths::getPluginsAppDirPath());
		if( !QLibrary::isLibrary(fileName)){
			QMessageBox::information(nullptr, pTitle, "The file is not a plugin");
		}else{
			QPluginLoader loader(fileName);
			loader.setLoadHints(0);
			QJsonObject metaData = loader.metaData()["MetaData"].toObject();
			if( metaData.contains("ID") && metaData.contains("Capabilities")){
				capabilities = metaData["Capabilities"].toString().toUpper().remove(' ').split(",");
				pluginIdentity =  metaData["ID"].toString();
			}
			if(!pluginIdentity.isEmpty()){// Check all plugins that have this title
				QStringList oldPlugins;
				if( gPluginsMap.contains(pluginIdentity))
					oldPlugins << gPluginsMap[pluginIdentity];
				if( QFile::exists(path+fileInfo.fileName()))
					oldPlugins << path+fileInfo.fileName();
				if(oldPlugins.size() > 0){
					doCopy = QMessageBox::question(nullptr, pTitle, "The plugin already exists. Do you want to overwrite it?\n"+oldPlugins.join('\n'), QMessageBox::Yes, QMessageBox::No);
					if( doCopy == QMessageBox::Yes){
						if(gPluginsMap.contains(pluginIdentity)){
							auto importers = CoreManager::getInstance()->getContactsImporterListModel()->getList();
							for(auto importer : importers){
								QJsonObject pluginMetaData(importer->getDataAPI()->getPluginLoader()->metaData());
								if( pluginMetaData.contains("ID") && pluginMetaData["ID"].toString() == pluginIdentity){
									importer->setDataAPI(nullptr);
									modelsToReset.append(importer);
								}
							}
							QStringList pluginPaths = Paths::getPluginsAppFolders();
							for(int i = 0 ; !cannotRemovePlugin && i < pluginPaths.size()-1 ; ++i) {// Ignore the last path as it is the app folder
								QString pluginPath = pluginPaths[i];
								if(QFile::exists(pluginPath+gPluginsMap[pluginIdentity])){
									cannotRemovePlugin = !QFile::remove(pluginPath+gPluginsMap[pluginIdentity]);
								}
							}
						}
						if(!cannotRemovePlugin && QFile::exists(path+fileInfo.fileName()))
							cannotRemovePlugin = !QFile::remove(path+fileInfo.fileName());
						if(!cannotRemovePlugin)
							gPluginsMap[pluginIdentity] = "";
					}
				}
			}else
				doCopy = QMessageBox::No;
			if(doCopy == QMessageBox::Yes ){
				
				if( cannotRemovePlugin)// Qt will not unload library from memory so files cannot be removed. See https://bugreports.qt.io/browse/QTBUG-68880
					QMessageBox::information(nullptr, pTitle, "The plugin cannot be replaced. You have to exit the application and delete manually the plugin file in\n"+path);
				else if( !QFile::copy(fileName, path+fileInfo.fileName()))
					QMessageBox::information(nullptr, pTitle, "The plugin cannot be copied. You have to copy manually the plugin file to\n"+path);
				else {
					gPluginsMap[pluginIdentity] = fileInfo.fileName();
					for(auto importer : modelsToReset)
						importer->setDataAPI(static_cast<PluginDataAPI*>(createInstance(pluginIdentity)));
				}
			}
		}
	}
}

QVariantList PluginsManager::getPlugins(const int& capabilities) {
	QVariantList plugins;
	QStringList pluginPaths = Paths::getPluginsAppFolders();
	if(capabilities<0)
		gPluginsMap.clear();
	for(int pathIndex = pluginPaths.size()-1 ; pathIndex >= 0 ; --pathIndex) {// Start from app package. This sort ensure the priority on user plugins
		QString pluginPath = pluginPaths[pathIndex];
		QDir dir(pluginPath);
		QStringList pluginFiles = dir.entryList(QDir::Files);
		for(int i = 0 ; i < pluginFiles.size() ; ++i) {
			if( QLibrary::isLibrary(pluginPath+pluginFiles[i])){
				QPluginLoader loader(pluginPath+pluginFiles[i]);
				loader.setLoadHints(0);	// this force Qt to unload the plugin from memory when we request it. Be carefull by not having a plugin instance or data created inside the plugin after the unload.
				if (auto instance = loader.instance()) {
					LinphonePlugin * plugin = qobject_cast< LinphonePlugin* >(instance);
					if ( plugin){
						QJsonObject metaData = loader.metaData()["MetaData"].toObject();
						if( metaData.contains("ID")){
							bool getIt = false;
							if(capabilities>=0 ){
								if(metaData.contains("Capabilities")){
									QString pluginCapabilities = metaData["Capabilities"].toString().toUpper().remove(' ');
									if( (capabilities & PluginDataAPI::CONTACTS) == PluginDataAPI::CONTACTS && pluginCapabilities.contains("CONTACTS")){
										getIt = true;
									}
								}else
									qWarning()<< "The plugin " << pluginFiles[i] << " must have Capabilities in its metadata";
							}else
								getIt = true;
							if(getIt){
								QJsonDocument doc = QJsonDocument::fromJson(plugin->getGUIDescriptionToJson().toUtf8());
								QVariantMap desc;
								desc["pluginTitle"] = doc["pluginTitle"];
								desc["pluginID"] = metaData["ID"].toString();
								if(!doc["pluginTitle"].toString().isEmpty()){
									gPluginsMap[metaData["ID"].toString()] = pluginFiles[i];
									plugins.push_back(desc);
								}
							}
						}else
							qWarning()<< "The plugin " << pluginFiles[i] << " must have ID in its metadata";
					} else {
						qWarning()<< "The plugin " << pluginFiles[i] << " should be updated to this version of API : " << loader.metaData()["IID"].toString();
					}
					loader.unload();
				} else {
					qWarning()<< "The plugin " << pluginFiles[i] << " cannot be used : " << loader.errorString();
				}
			}
		}
		std::sort(plugins.begin(), plugins.end());
	}
	return plugins;
}
QVariantMap PluginsManager::getPluginDescription(const QString& pluginIdentity) {
	QVariantMap description;
	QJsonDocument doc = getJson(pluginIdentity);
	description = doc.toVariant().toMap();
	return description;
}


QVariantMap PluginsManager::getDefaultValues(const QString& pluginIdentity){
	QVariantMap defaultValues;
	QVariantMap description;
	QJsonDocument doc = getJson(pluginIdentity);
	description = doc.toVariant().toMap();
	for(auto field : description["fields"].toList()){
		auto details = field.toMap();
		if( details.contains("fieldId") && details.contains("defaultData")){
			defaultValues[details["fieldId"].toString()] = details["defaultData"].toString();
		}
	}
	return defaultValues;
}
