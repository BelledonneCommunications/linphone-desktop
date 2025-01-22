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

#include "CarddavList.hpp"
#include "CarddavGui.hpp"
#include "core/App.hpp"
#include "model/object/VariantObject.hpp"
#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(CarddavList)

QSharedPointer<CarddavList> CarddavList::create() {
	auto model = QSharedPointer<CarddavList>(new CarddavList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

QSharedPointer<CarddavCore>
CarddavList::createCarddavCore(const std::shared_ptr<linphone::FriendList> &carddavFriendList) {
	auto CarddavCore = CarddavCore::create(carddavFriendList);
	return CarddavCore;
}

CarddavList::CarddavList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

CarddavList::~CarddavList() {
	mustBeInMainThread("~" + getClassName());
	mModelConnection = nullptr;
}

void CarddavList::setSelf(QSharedPointer<CarddavList> me) {
	mModelConnection = SafeConnection<CarddavList, CoreModel>::create(me, CoreModel::getInstance());
	mModelConnection->makeConnectToCore(&CarddavList::lUpdate, [this]() {
		mModelConnection->invokeToModel([this]() {
			mustBeInLinphoneThread(getClassName());
			QList<QSharedPointer<CarddavCore>> *carddavs = new QList<QSharedPointer<CarddavCore>>();
			for (auto friendList : CoreModel::getInstance()->getCore()->getFriendsLists()) {
				if (friendList->getType() == linphone::FriendList::Type::CardDAV) {
					auto model = createCarddavCore(friendList);
					carddavs->push_back(model);
				}
			}
			mModelConnection->invokeToCore([this, carddavs]() {
				mustBeInMainThread(getClassName());
				resetData<CarddavCore>(*carddavs);
				delete carddavs;
			});
		});
	});

	mModelConnection->makeConnectToModel(
	    &CoreModel::friendListRemoved,
	    [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::FriendList> &friendList) {
		    mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		    emit lUpdate();
	    });

	emit lUpdate();
}

void CarddavList::removeAllEntries() {
	beginResetModel();
	for (auto it = mList.rbegin(); it != mList.rend(); ++it) {
		auto carddavFriendList = it->objectCast<CarddavCore>();
		carddavFriendList->remove();
	}
	mList.clear();
	endResetModel();
}

void CarddavList::remove(const int &row) {
	beginRemoveRows(QModelIndex(), row, row);
	mList.takeAt(row).objectCast<CarddavCore>()->remove();
	endRemoveRows();
}

QVariant CarddavList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		return QVariant::fromValue(new CarddavGui(mList[row].objectCast<CarddavCore>()));
	}
	return QVariant();
}
