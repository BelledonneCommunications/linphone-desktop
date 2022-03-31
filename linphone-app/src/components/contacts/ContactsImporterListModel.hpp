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

#ifndef CONTACTS_IMPORTER_LIST_MODEL_H_
#define CONTACTS_IMPORTER_LIST_MODEL_H_

#include <memory>

#include "app/proxyModel/ProxyListModel.hpp"

// =============================================================================

class ContactsImporterModel;
class PluginsModel;

// Store all connectors

class ContactsImporterListModel : public ProxyListModel {
	Q_OBJECT

public:
	ContactsImporterListModel (QObject *parent = Q_NULLPTR);

	virtual bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

	QSharedPointer<ContactsImporterModel> findContactsImporterModelFromId (const int &id) const;

	Q_INVOKABLE ContactsImporterModel *createContactsImporter(QVariantMap data);
	Q_INVOKABLE ContactsImporterModel *addContactsImporter (QVariantMap data, int id=-1);
	Q_INVOKABLE void removeContactsImporter (ContactsImporterModel *importer);
	Q_INVOKABLE void importContacts(const int &id = -1);						// Import contacts for all enabled importer if -1
//-----------------------------------------------------------------------------------

signals:
	void contactsImporterAdded (QSharedPointer<ContactsImporterModel>);
	void contactsImporterRemoved (QSharedPointer<ContactsImporterModel>);
	void contactsImporterUpdated (QSharedPointer<ContactsImporterModel>);

private:
	void addContactsImporter (QSharedPointer<ContactsImporterModel> contactsImporter);
	
	int mMaxContactsImporterId;	// Used to ensure unicity on ID when creating a connector
};

#endif // CONTACTS_IMPORTER_LIST_MODEL_H_
