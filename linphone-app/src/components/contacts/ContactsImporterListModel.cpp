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

#include <QQmlApplicationEngine>

#include "app/App.hpp"
#include "ContactsImporterModel.hpp"
#include "ContactsImporterListModel.hpp"
#include "ContactsImporterPluginsManager.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"

// =============================================================================

using namespace std;

ContactsImporterListModel::ContactsImporterListModel (QObject *parent) : QAbstractListModel(parent) {
  // Init contacts with linphone friends list.
	mMaxContactsImporterId = -1;
	QQmlEngine *engine = App::getInstance()->getEngine();
	auto config = CoreManager::getInstance()->getCore()->getConfig();
	PluginsManager::getPlugins();// Initialize list
// Read configuration file
	std::list<std::string> sections = config->getSectionsNamesList();
	for(auto section : sections){
		QString qtSection = Utils::coreStringToAppString(section);
		QStringList parse = qtSection.split("_");// PluginsManager::gPluginsConfigSection_id_capability
		if( parse.size() > 2){
			QVariantMap importData;
			if( parse[2].toInt() == PluginDataAPI::CONTACTS){// We only care about Contacts
				int id = parse[1].toInt();
				mMaxContactsImporterId = qMax(id, mMaxContactsImporterId);
				std::list<std::string> keys = config->getKeysNamesList(section);
				auto keyName = std::find(keys.begin(), keys.end(), "pluginID");
				if( keyName != keys.end()){
					QString pluginID =  Utils::coreStringToAppString(config->getString(section, *keyName, ""));
					PluginDataAPI* data = static_cast<PluginDataAPI*>(PluginsManager::createInstance(pluginID));
					if(data) {
						ContactsImporterModel * model = new ContactsImporterModel(data, this);
	// See: http://doc.qt.io/qt-5/qtqml-cppintegration-data.html#data-ownership
	// The returned value must have a explicit parent or a QQmlEngine::CppOwnership.
						engine->setObjectOwnership(model, QQmlEngine::CppOwnership);
						model->setIdentity(id);
						model->loadConfiguration();// Read the configuration contacts inside the plugin
						addContactsImporter(model);
					}
				}
			}
		}
		
	}
}

// GUI methods

int ContactsImporterListModel::rowCount (const QModelIndex &) const {
	return mList.count();
}

QHash<int, QByteArray> ContactsImporterListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$contactsImporter";
	return roles;
}

QVariant ContactsImporterListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();

	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();

	if (role == Qt::DisplayRole)
		return QVariant::fromValue(mList[row]);

	return QVariant();
}

bool ContactsImporterListModel::removeRow (int row, const QModelIndex &parent) {
	return removeRows(row, 1, parent);
}

bool ContactsImporterListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;

	if (row < 0 || count < 0 || limit >= mList.count())
		return false;

	beginRemoveRows(parent, row, limit);

	for (int i = 0; i < count; ++i) {
		ContactsImporterModel *contactsImporter = dynamic_cast<ContactsImporterModel*>(mList.takeAt(row));
		emit contactsImporterRemoved(contactsImporter);
		contactsImporter->deleteLater();
	}

	endRemoveRows();

	return true;
}

// -----------------------------------------------------------------------------

ContactsImporterModel *ContactsImporterListModel::findContactsImporterModelFromId (const int &id) const {
	auto it = find_if(mList.begin(), mList.end(), [id](PluginsModel *contactsImporterModel) {
		return contactsImporterModel->getIdentity() == id;
	});
	return it != mList.end() ? dynamic_cast<ContactsImporterModel*>(*it) : nullptr;
}

QList<PluginsModel*> ContactsImporterListModel::getList(){
	return mList;
}

// -----------------------------------------------------------------------------

ContactsImporterModel *ContactsImporterListModel::createContactsImporter(QVariantMap data){
	ContactsImporterModel *contactsImporter = nullptr;
	if( data.contains("pluginID")){
		PluginDataAPI * dataInstance = static_cast<PluginDataAPI*>(PluginsManager::createInstance(data["pluginID"].toString()));
		if(dataInstance) {
// get default values
			contactsImporter = new ContactsImporterModel(dataInstance, this);
			App::getInstance()->getEngine()->setObjectOwnership(contactsImporter, QQmlEngine::CppOwnership);
			QVariantMap newData = ContactsImporterPluginsManager::getDefaultValues(data["pluginID"].toString());// Start with defaults from plugin
			QVariantMap InstanceFields = contactsImporter->getFields();
			for(auto field = InstanceFields.begin() ; field != InstanceFields.end() ; ++field)// Insert or Update with the defaults of an instance
				newData[field.key()] = field.value();
			for(auto field = data.begin() ; field != data.end() ; ++field)// Insert or Update with Application data
				newData[field.key()] = field.value();
			contactsImporter->setIdentity(++mMaxContactsImporterId);
			contactsImporter->setFields(newData);
		
			int row = mList.count();
		
			beginInsertRows(QModelIndex(), row, row);
			addContactsImporter(contactsImporter);
			endInsertRows();
		
			emit contactsImporterAdded(contactsImporter);
		}
	}
	
	return contactsImporter;

}
ContactsImporterModel *ContactsImporterListModel::addContactsImporter (QVariantMap data, int pId) {
	ContactsImporterModel *contactsImporter = findContactsImporterModelFromId(pId);
	if (contactsImporter) {
		contactsImporter->setFields(data);
		return contactsImporter;
	}else
		return createContactsImporter(data);
}

void ContactsImporterListModel::removeContactsImporter (ContactsImporterModel *contactsImporter) {
	int index = mList.indexOf(contactsImporter);
	if (index >=0){
		if( contactsImporter->getIdentity() >=0 ){// Remove from configuration
			int id = contactsImporter->getIdentity();
			string section = Utils::appStringToCoreString(PluginsManager::gPluginsConfigSection+"_"+QString::number(id)+"_"+QString::number(PluginDataAPI::CONTACTS));
			CoreManager::getInstance()->getCore()->getConfig()->cleanSection(section);
			if( id == mMaxContactsImporterId)// Decrease mMaxContactsImporterId in a safe way
				--mMaxContactsImporterId;
		}
		removeRow(index);
	}
}

void ContactsImporterListModel::importContacts(const int &pId){
	if( pId >=0) {
		ContactsImporterModel *contactsImporter = findContactsImporterModelFromId(pId);
		if( contactsImporter)
			contactsImporter->importContacts();
	}else	// Import from all current connectors
		for(auto importer : mList)
			dynamic_cast<ContactsImporterModel*>(importer)->importContacts();
}

// -----------------------------------------------------------------------------

void ContactsImporterListModel::addContactsImporter (ContactsImporterModel *contactsImporter) {
	// Connect all update signals
	QObject::connect(contactsImporter, &ContactsImporterModel::fieldsChanged, this, [this, contactsImporter]() {
		emit contactsImporterUpdated(contactsImporter);
	});
	QObject::connect(contactsImporter, &ContactsImporterModel::identityChanged, this, [this, contactsImporter]() {
		emit contactsImporterUpdated(contactsImporter);
	});
	mList << contactsImporter;
}
//-----------------------------------------------------------------------------------

