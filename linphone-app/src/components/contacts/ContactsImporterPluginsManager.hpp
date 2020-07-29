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

class ContactsImporterModel;
class ContactsImporterPlugin;

class ContactsImporterPluginsManager : public QObject{
Q_OBJECT
public:
	ContactsImporterPluginsManager (QObject *parent = Q_NULLPTR);
	
	static ContactsImporterPlugin * getPlugin(const QString &pluginTitle);
	Q_INVOKABLE static void openNewPlugin();
	Q_INVOKABLE static QVariantList getContactsImporterPlugins();
	Q_INVOKABLE static QVariantMap getContactsImporterPluginDescription(const QString& pluginTitle);
	Q_INVOKABLE static void importContacts(ContactsImporterModel * model);
	static void importContacts(const QVector<QMultiMap<QString, QString> >& contacts );
	
	static QVariantMap getDefaultValues(const QString& pluginTitle);
	
	static const QString ContactsSection;
	static QMap<QString, QString> gPluginsMap;
};


#endif // CONTACTS_IMPORTER_PLUGINS_MANAGER_MODEL_H_
