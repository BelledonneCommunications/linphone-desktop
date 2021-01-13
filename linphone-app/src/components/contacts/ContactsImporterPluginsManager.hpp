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

#ifndef CONTACTS_IMPORTER_PLUGINS_MANAGER_MODEL_H_
#define CONTACTS_IMPORTER_PLUGINS_MANAGER_MODEL_H_

#include <QObject>
#include <QVariantList>

// =============================================================================
#include "utils/plugins/PluginsManager.hpp"

class ContactsImporterModel;
class PluginContactsDataAPI;

class QPluginLoader;

class ContactsImporterPluginsManager : public PluginsManager{
Q_OBJECT
public:
	ContactsImporterPluginsManager (QObject *parent = Q_NULLPTR);

	Q_INVOKABLE static void openNewPlugin();	// Open a File Dialog. Test if the file can be load and have a matched version. Replace old plugins from custom paths and with the same plugin title.
	Q_INVOKABLE static QVariantList getPlugins();	// Get a list of all available plugins
	Q_INVOKABLE static QVariantMap getContactsImporterPluginDescription(const QString& pluginID);	// Get the description of the plugin. It is used for GUI to create dynamically items
	Q_INVOKABLE static void importContacts(ContactsImporterModel * model);	// Request the import of the model
	static void importContacts(const QVector<QMultiMap<QString, QString> >& contacts );	// Merge these data into contacts

};


#endif // CONTACTS_IMPORTER_PLUGINS_MANAGER_MODEL_H_
