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
#include "utils/Utils.hpp"

#include "LdapListModel.hpp"

// =============================================================================

using namespace std;

LdapListModel::LdapListModel (QObject *parent) : ProxyListModel(parent) {
  initLdap();
}

// -----------------------------------------------------------------------------
void LdapListModel::reset(){
  resetInternalData();
  initLdap();
}


// -----------------------------------------------------------------------------

void LdapListModel::initLdap () {
	CoreManager *coreManager = CoreManager::getInstance();
	auto ldapList = coreManager->getCore()->getLdapList();
	for(auto ldap : ldapList){
		ProxyListModel::add(QSharedPointer<LdapModel>::create(ldap));
	}
}

// Save if valid
void LdapListModel::enable(int id, bool status){
	auto item = getAt<LdapModel>(id);
	if( item->isValid()){
		QVariantMap config = item->getConfig();
		config["enable"] = status;
		item->setConfig(config);
		item->save();
	}
	emit dataChanged(index(id, 0), index(id, 0));
}

// Create a new LdapModel and put it in the list
void LdapListModel::add(){
	auto ldap= QSharedPointer<LdapModel>::create(nullptr);
	connect(ldap.get(), &LdapModel::indexChanged, this, &LdapListModel::indexChanged);
	ldap->init();
	ProxyListModel::add(ldap);
	emit layoutChanged();
}

void LdapListModel::remove (LdapModel *ldap) {
	int index;
	auto item = get(ldap, &index);
	if(item){
		item.objectCast<LdapModel>()->unsave();
		removeRow(index);
	}
}
