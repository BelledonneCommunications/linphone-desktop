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

#include "CarddavCore.hpp"
#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(CarddavCore)

QSharedPointer<CarddavCore> CarddavCore::create(const std::shared_ptr<linphone::FriendList> &carddavFriendList) {
	auto sharedPointer = QSharedPointer<CarddavCore>(new CarddavCore(carddavFriendList), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

CarddavCore::CarddavCore(const std::shared_ptr<linphone::FriendList> &carddavFriendList) : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mCarddavModel = CarddavModel::create(carddavFriendList);
	if (carddavFriendList) {
		mDisplayName = Utils::coreStringToAppString(carddavFriendList->getDisplayName());
		mUri = Utils::coreStringToAppString(carddavFriendList->getUri());
	}
	mStoreNewFriendsInIt = mCarddavModel->storeNewFriendsInIt();
}

CarddavCore::~CarddavCore() {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
}

void CarddavCore::save() {
	if (!mUri.startsWith("http://") && !mUri.startsWith("https://")) {
		mUri = "https://" + mUri;
		emit uriChanged();
	}

	auto displayName = Utils::appStringToCoreString(mDisplayName);
	auto uri = Utils::appStringToCoreString(mUri);
	auto username = Utils::appStringToCoreString(mUsername);
	auto password = Utils::appStringToCoreString(mPassword);
	auto realm = Utils::appStringToCoreString(mRealm);
	auto storeNewFriendsInIt = mStoreNewFriendsInIt;

	mCarddavModelConnection->invokeToModel([this, displayName, uri, username, password, realm, storeNewFriendsInIt]() {
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		mCarddavModel->save(displayName, uri, username, password, realm, storeNewFriendsInIt);
	});
}

void CarddavCore::remove() {
	mCarddavModelConnection->invokeToModel([this]() {
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		mCarddavModel->remove();
	});
}

void CarddavCore::setSelf(QSharedPointer<CarddavCore> me) {
	mCarddavModelConnection = SafeConnection<CarddavCore, CarddavModel>::create(me, mCarddavModel);
	mCarddavModelConnection->makeConnectToModel(&CarddavModel::saved, [this](bool success) {
		mCarddavModelConnection->invokeToCore([this, success]() { emit saved(success); });
	});
}

bool CarddavCore::isValid() {
	return !mDisplayName.isEmpty() && !mUri.isEmpty(); // Auth info is optional.
}
