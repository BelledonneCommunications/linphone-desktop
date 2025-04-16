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

#include "FriendsManager.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"
#include <QDebug>
#include <QUrl>

DEFINE_ABSTRACT_OBJECT(FriendsManager)

std::shared_ptr<FriendsManager> FriendsManager::gFriendsManager;
FriendsManager::FriendsManager(QObject *parent) : QObject(parent) {
	moveToThread(CoreModel::getInstance()->thread());

	connect(CoreModel::getInstance().get(), &CoreModel::friendRemoved, this, [this] (const std::shared_ptr<linphone::Friend> &f) {
		auto key = mKnownFriends.key(QVariant::fromValue(f), nullptr);
		if (key != nullptr) {
			mKnownFriends.remove(key);
		}
		auto unknown = mUnknownFriends.key(QVariant::fromValue(f), nullptr);
		if (unknown != nullptr) {
			mUnknownFriends.remove(unknown);
		}
		auto address = QString::fromStdString(f->getAddress()->asStringUriOnly());
		mOtherAddresses.removeAll(address);
	});
	connect(CoreModel::getInstance().get(), &CoreModel::friendCreated, this, [this] (const std::shared_ptr<linphone::Friend> &f) {
		auto unknown = mUnknownFriends.key(QVariant::fromValue(f), nullptr);
		if (unknown != nullptr) {
			mUnknownFriends.remove(unknown);
		}
		auto address = QString::fromStdString(f->getAddress()->asStringUriOnly());
		mOtherAddresses.removeAll(address);
	});
	connect(CoreModel::getInstance().get(), &CoreModel::friendUpdated, this, [this] (const std::shared_ptr<linphone::Friend> &f) {
		auto key = mKnownFriends.key(QVariant::fromValue(f), nullptr);
		if (key != nullptr) {
			mKnownFriends.remove(key);
		}
		auto unknown = mUnknownFriends.key(QVariant::fromValue(f), nullptr);
		if (unknown != nullptr) {
			mUnknownFriends.remove(unknown);
		}
		auto address = QString::fromStdString(f->getAddress()->asStringUriOnly());
		mOtherAddresses.removeAll(address);
	});
}

FriendsManager::~FriendsManager() {
}

std::shared_ptr<FriendsManager> FriendsManager::create(QObject *parent) {
	auto model = std::make_shared<FriendsManager>(parent);
	return model;
}

std::shared_ptr<FriendsManager> FriendsManager::getInstance() {
	if (!gFriendsManager) gFriendsManager = FriendsManager::create(nullptr);
	return gFriendsManager;
}

QVariantMap FriendsManager::getKnownFriends() const {
	return mKnownFriends;
}

QVariantMap FriendsManager::getUnknownFriends() const {
	return mUnknownFriends;
}

QStringList FriendsManager::getOtherAddresses() const {
	return mOtherAddresses;
}

std::shared_ptr<linphone::Friend> FriendsManager::getKnownFriendAtKey(const QString& key) {
	if (isInKnownFriends(key)) {
		return mKnownFriends.value(key).value<std::shared_ptr<linphone::Friend>>();
	} else return nullptr;
}

std::shared_ptr<linphone::Friend> FriendsManager::getUnknownFriendAtKey(const QString& key) {
	if (isInUnknownFriends(key)) {
		return mUnknownFriends.value(key).value<std::shared_ptr<linphone::Friend>>();
	} else return nullptr;
}

bool FriendsManager::isInKnownFriends(const QString& key) {
	return mKnownFriends.contains(key);
}

bool FriendsManager::isInUnknownFriends(const QString& key) {
	return mUnknownFriends.contains(key);
}

bool FriendsManager::isInOtherAddresses(const QString& key) {
	return mOtherAddresses.contains(key);
}

void FriendsManager::appendKnownFriend(std::shared_ptr<linphone::Address> address, std::shared_ptr<linphone::Friend> f) {
	auto key = Utils::coreStringToAppString(address->asStringUriOnly());
	if (mKnownFriends.contains(key)) {
		qDebug() << "friend is already in konwn list, return";
		return;
	}
	mKnownFriends.insert(key, QVariant::fromValue(f));
}


void FriendsManager::appendUnknownFriend(std::shared_ptr<linphone::Address> address, std::shared_ptr<linphone::Friend> f) {
	auto key = Utils::coreStringToAppString(address->asStringUriOnly());
	if (mUnknownFriends.contains(key)) {
		qDebug() << "friend is already in unkonwn list, return";
		return;
	}
	mUnknownFriends.insert(key, QVariant::fromValue(f));
}


void FriendsManager::appendOtherAddress(QString address) {
	if (mOtherAddresses.contains(address)) {
		qDebug() << "friend is already in other addresses, return";
		return;
	}
	mOtherAddresses.append(address);
}

void FriendsManager::removeUnknownFriend(const QString& key) {
	mUnknownFriends.remove(key);
}

void FriendsManager::removeOtherAddress(const QString& key) {
	mOtherAddresses.removeAll(key);
}
