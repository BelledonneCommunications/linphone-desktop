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

#include "AccountDeviceCore.hpp"
#include "core/App.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(AccountDeviceCore)

AccountDeviceCore::AccountDeviceCore(QString name, QString userAgent, QDateTime last) : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mustBeInLinphoneThread(getClassName());

	mDeviceName = name;
	mUserAgent = userAgent;
	mLastUpdateTimestamp = last;
}

QSharedPointer<AccountDeviceCore> AccountDeviceCore::createDummy(QString name, QString userAgent, QDateTime last) {
	auto core = QSharedPointer<AccountDeviceCore>(new AccountDeviceCore(name, userAgent, last));
	core->moveToThread(App::getInstance()->thread());
	return core;
}

QSharedPointer<AccountDeviceCore> AccountDeviceCore::create(const std::shared_ptr<linphone::AccountDevice> &device) {
	mustBeInLinphoneThread(Q_FUNC_INFO);
	auto core = QSharedPointer<AccountDeviceCore>(new AccountDeviceCore(device));
	core->moveToThread(App::getInstance()->thread());
	return core;
}

AccountDeviceCore::AccountDeviceCore(const std::shared_ptr<linphone::AccountDevice> &device) : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mustBeInLinphoneThread(getClassName());
	mAccountDeviceModel = Utils::makeQObject_ptr<AccountDeviceModel>(device);
	mDeviceName = Utils::coreStringToAppString(device->getName());
	mUserAgent = Utils::coreStringToAppString(device->getUserAgent());
	mLastUpdateTimestamp = QDateTime::fromSecsSinceEpoch(device->getLastUpdateTimestamp());
}

AccountDeviceCore::~AccountDeviceCore() {
	mustBeInMainThread("~" + getClassName());
}

const std::shared_ptr<AccountDeviceModel> &AccountDeviceCore::getModel() const {
	return mAccountDeviceModel;
}