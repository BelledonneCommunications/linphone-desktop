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

#include <QDateTime>
#include <QElapsedTimer>
#include <QUrl>
#include <QtDebug>

#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/LinphoneUtils.hpp"
#include "utils/Utils.hpp"

#include "LdapListModel.hpp"

// =============================================================================

using namespace std;

LdapListModel::LdapListModel (QObject *parent) : QAbstractListModel(parent) {
  initLdap();
}

// -----------------------------------------------------------------------------
void LdapListModel::reset(){
  resetInternalData();
  initLdap();
}
int LdapListModel::rowCount (const QModelIndex &) const {
  return mServers.count();
}

QHash<int, QByteArray> LdapListModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$ldapServer";
  return roles;
}

QVariant LdapListModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mServers.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(mServers[row]);

  return QVariant();
}

// -----------------------------------------------------------------------------



// -----------------------------------------------------------------------------

bool LdapListModel::removeRow (int row, const QModelIndex &parent) {
  return removeRows(row, 1, parent);
}

bool LdapListModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= mServers.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i)
    delete mServers.takeAt(row);

  endRemoveRows();

  return true;
}


// -----------------------------------------------------------------------------

void LdapListModel::initLdap () {
	CoreManager *coreManager = CoreManager::getInstance();
	auto lConfig = coreManager->getCore()->getConfig();
	auto bcSections = lConfig->getSectionsNamesList();
	// Loop on all sections and load configuration. If this is not a LDAP configuration, the model is discarded.
	for(auto itSections = bcSections.begin(); itSections != bcSections.end(); ++itSections) {
		LdapModel * ldap = new LdapModel();
		if(ldap->load(*itSections)){
			mServers.append(ldap);
		}else
			delete ldap;
	}
}

// Save if valid
void LdapListModel::enable(int id, bool status){
	if( mServers[id]->isValid()){
		QVariantMap config = mServers[id]->getConfig();
		config["enable"] = status;
		mServers[id]->setConfig(config);
		mServers[id]->save();
	}
	emit dataChanged(index(id, 0), index(id, 0));
}

// Create a new LdapModel and put it in the list
void LdapListModel::add(){
	int row = mServers.count();
	beginInsertRows(QModelIndex(), row, row);
	auto ldap= new LdapModel(row);
	ldap->init();
	mServers << ldap;
	endInsertRows();
	resetInternalData();
}

void LdapListModel::remove (LdapModel *ldap) {
	int index = mServers.indexOf(ldap);
	if (index >=0){
		ldap->unsave();
		removeRow(index);
	}
}
