/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef LDAP_LIST_MODEL_H_
#define LDAP_LIST_MODEL_H_

#include <QAbstractListModel>
#include <QDateTime>

#include "LdapModel.hpp"
// =============================================================================

class CoreHandlers;

class LdapListModel : public QAbstractListModel {
	Q_OBJECT
	
public:
	
	LdapListModel (QObject *parent = Q_NULLPTR);
	
	void reset();
	
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
	
	QHash<int, QByteArray> roleNames () const override;
	QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
	
// Enable the Server and save it if it is valid
	Q_INVOKABLE void enable(int id, bool status);
// Create a Server
	Q_INVOKABLE void add();
// Remove a Server
	Q_INVOKABLE void remove (LdapModel *importer);
	
private:
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	// ---------------------------------------------------------------------------
	
	void initLdap ();
	
	QList<LdapModel*> mServers;
};

#endif // LDAP_LIST_MODEL_H_
