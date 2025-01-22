/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#include "LdapList.hpp"
#include "LdapGui.hpp"
#include "core/App.hpp"
#include "model/object/VariantObject.hpp"
#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(LdapList)

QSharedPointer<LdapList> LdapList::create() {
	auto model = QSharedPointer<LdapList>(new LdapList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

QSharedPointer<LdapCore> LdapList::createLdapCore(const std::shared_ptr<linphone::RemoteContactDirectory> &ldap) {
	auto LdapCore = LdapCore::create(ldap);
	return LdapCore;
}

LdapList::LdapList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

LdapList::~LdapList() {
	mustBeInMainThread("~" + getClassName());
	mModelConnection = nullptr;
}

void LdapList::setSelf(QSharedPointer<LdapList> me) {
	mModelConnection = SafeConnection<LdapList, CoreModel>::create(me, CoreModel::getInstance());
	mModelConnection->makeConnectToCore(&LdapList::lUpdate, [this]() {
		mModelConnection->invokeToModel([this]() {
			QList<QSharedPointer<LdapCore>> *ldaps = new QList<QSharedPointer<LdapCore>>();
			mustBeInLinphoneThread(getClassName());
			for (auto server : CoreModel::getInstance()->getCore()->getRemoteContactDirectories()) {
				if (server->getType() == linphone::RemoteContactDirectory::Type::Ldap) {
					auto model = createLdapCore(server);
					ldaps->push_back(model);
				}
			}
			mModelConnection->invokeToCore([this, ldaps]() {
				mustBeInMainThread(getClassName());
				resetData<LdapCore>(*ldaps);
				delete ldaps;
			});
		});
	});
	emit lUpdate();
}

void LdapList::removeAllEntries() {
	beginResetModel();
	for (auto it = mList.rbegin(); it != mList.rend(); ++it) {
		auto ldap = it->objectCast<LdapCore>();
		ldap->remove();
	}
	mList.clear();
	endResetModel();
}

void LdapList::remove(const int &row) {
	beginRemoveRows(QModelIndex(), row, row);
	mList.takeAt(row).objectCast<LdapCore>()->remove();
	endRemoveRows();
}

QVariant LdapList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		return QVariant::fromValue(new LdapGui(mList[row].objectCast<LdapCore>()));
	}
	return QVariant();
}
