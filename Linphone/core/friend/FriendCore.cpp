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

#include "FriendCore.hpp"
#include "core/App.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(FriendCore)

QSharedPointer<FriendCore> FriendCore::create(const std::shared_ptr<linphone::Friend> &contact) {
	auto sharedPointer = QSharedPointer<FriendCore>(new FriendCore(contact), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

FriendCore::FriendCore(const std::shared_ptr<linphone::Friend> &contact) : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	if (contact) {
		mustBeInLinphoneThread(getClassName());
		mFriendModel = Utils::makeQObject_ptr<FriendModel>(contact);
		mFriendModel->setSelf(mFriendModel);
		mConsolidatedPresence = LinphoneEnums::fromLinphone(contact->getConsolidatedPresence());
		mPresenceTimestamp = mFriendModel->getPresenceTimestamp();
		mPictureUri = Utils::coreStringToAppString(contact->getPhoto());
		auto address = contact->getAddress();
		mAddress = address ? Utils::coreStringToAppString(contact->getAddress()->asString()) : "NoAddress";
		mIsSaved = true;
	} else mIsSaved = false;
}

FriendCore::FriendCore(const FriendCore &friendCore) {
	// Only copy friend values without models for lambda using and avoid concurrencies.
	mAddress = friendCore.mAddress;
	mIsSaved = friendCore.mIsSaved;
}

FriendCore::~FriendCore() {
}

void FriendCore::setSelf(SafeSharedPointer<FriendCore> me) {
	setSelf(me.mQDataWeak.lock());
}
void FriendCore::setSelf(QSharedPointer<FriendCore> me) {
	if (me) {
		if (mFriendModel) {
			mCoreModelConnection = nullptr; // No more needed
			mFriendModelConnection = QSharedPointer<SafeConnection<FriendCore, FriendModel>>(
			    new SafeConnection<FriendCore, FriendModel>(me, mFriendModel), &QObject::deleteLater);
			mFriendModelConnection->makeConnectToModel(
			    &FriendModel::presenceReceived,
			    [this](LinphoneEnums::ConsolidatedPresence consolidatedPresence, QDateTime presenceTimestamp) {
				    mFriendModelConnection->invokeToCore([this, consolidatedPresence, presenceTimestamp]() {
					    setConsolidatedPresence(consolidatedPresence);
					    setPresenceTimestamp(presenceTimestamp);
				    });
			    });
			mFriendModelConnection->makeConnectToModel(&FriendModel::pictureUriChanged, [this](QString uri) {
				mFriendModelConnection->invokeToCore([this, uri]() { this->onPictureUriChanged(uri); });
			});

			// From GUI
			mFriendModelConnection->makeConnectToCore(&FriendCore::lSetPictureUri, [this](QString uri) {
				mFriendModelConnection->invokeToModel([this, uri]() { mFriendModel->setPictureUri(uri); });
			});

		} else { // Create
			mCoreModelConnection = QSharedPointer<SafeConnection<FriendCore, CoreModel>>(
			    new SafeConnection<FriendCore, CoreModel>(me, CoreModel::getInstance()), &QObject::deleteLater);
		}
	}
}

void FriendCore::reset(const FriendCore &contact) {
	setAddress(contact.getAddress());
	setName(contact.getName());
	setIsSaved(mFriendModel != nullptr);
}

QString FriendCore::getName() const {
	return mName;
}

void FriendCore::setName(QString data) {
	if (mName != data) {
		mName = data;
		emit addressChanged(mName);
		setIsSaved(false);
	}
}

QString FriendCore::getAddress() const {
	return mAddress;
}

void FriendCore::setAddress(QString address) {
	if (mAddress != address) {
		mAddress = address;
		emit addressChanged(mAddress);
		setIsSaved(false);
	}
}

LinphoneEnums::ConsolidatedPresence FriendCore::getConsolidatedPresence() const {
	return mConsolidatedPresence;
}

void FriendCore::setConsolidatedPresence(LinphoneEnums::ConsolidatedPresence presence) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mConsolidatedPresence != presence) {
		mConsolidatedPresence = presence;
		emit consolidatedPresenceChanged(mConsolidatedPresence);
	}
}

QDateTime FriendCore::getPresenceTimestamp() const {
	return mPresenceTimestamp;
}

void FriendCore::setPresenceTimestamp(QDateTime presenceTimestamp) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mPresenceTimestamp != presenceTimestamp) {
		mPresenceTimestamp = presenceTimestamp;
		emit presenceTimestampChanged(mPresenceTimestamp);
	}
}

QString FriendCore::getPictureUri() const {
	return mPictureUri;
}

void FriendCore::onPictureUriChanged(QString uri) {
	mPictureUri = uri;
	emit pictureUriChanged();
}

bool FriendCore::getIsSaved() const {
	return mIsSaved;
}
void FriendCore::setIsSaved(bool data) {
	if (mIsSaved != data) {
		mIsSaved = data;
		emit isSavedChanged(mIsSaved);
	}
}

void FriendCore::writeInto(std::shared_ptr<linphone::Friend> contact) const {
	mustBeInLinphoneThread(QString("[") + gClassName + "] " + Q_FUNC_INFO);
	auto core = CoreModel::getInstance()->getCore();
	auto newAddress = core->createAddress(Utils::appStringToCoreString(mAddress));
	contact->edit();
	if (newAddress) contact->setAddress(newAddress);
	else qDebug() << "Bad address : " << mAddress;
	contact->done();
}

void FriendCore::writeFrom(const std::shared_ptr<linphone::Friend> &contact) {
	mustBeInLinphoneThread(QString("[") + gClassName + "] " + Q_FUNC_INFO);
	auto address = contact->getAddress();
	mAddress = (address ? Utils::coreStringToAppString(address->asString()) : "");
	mName = Utils::coreStringToAppString(contact->getName());
}

void FriendCore::remove() {
	if (mFriendModel) { // Update
		mFriendModelConnection->invokeToModel([this]() {
			auto contact = mFriendModel->getFriend();
			contact->remove();
			emit CoreModel::getInstance()->friendRemoved();
			mFriendModelConnection->invokeToCore([this]() { removed(this); });
		});
	}
}

void FriendCore::save() {                                          // Save Values to model
	FriendCore *thisCopy = new FriendCore(*this);                  // Pointer to avoid multiple copies in lambdas
	if (mFriendModel) {                                            // Update
		mFriendModelConnection->invokeToModel([this, thisCopy]() { // Copy values to avoid concurrency
			auto core = CoreModel::getInstance()->getCore();
			auto contact = mFriendModel->getFriend();
			thisCopy->writeInto(contact);
			thisCopy->deleteLater();
			mFriendModelConnection->invokeToCore([this]() { saved(); });
		});
	} else { // Creation
		mCoreModelConnection->invokeToModel([this, thisCopy]() {
			auto core = CoreModel::getInstance()->getCore();
			auto contact = core->createFriend();
			thisCopy->writeInto(contact);
			thisCopy->deleteLater();
			bool created = (core->getDefaultFriendList()->addFriend(contact) == linphone::FriendList::Status::OK);
			if (created) {
				mFriendModel = Utils::makeQObject_ptr<FriendModel>(contact);
				mFriendModel->setSelf(mFriendModel);
				core->getDefaultFriendList()->updateSubscriptions();
			}
			emit CoreModel::getInstance()->friendAdded();
			mCoreModelConnection->invokeToCore([this, created]() {
				if (created) setSelf(mCoreModelConnection->mCore);
				setIsSaved(created);
			});
		});
	}
}

void FriendCore::undo() { // Retrieve values from model
	if (mFriendModel) {
		mFriendModelConnection->invokeToModel([this]() {
			FriendCore *contact = new FriendCore(*this);
			contact->writeFrom(mFriendModel->getFriend());
			mFriendModelConnection->invokeToCore([this, contact]() {
				this->reset(*contact);
				contact->deleteLater();
			});
		});
	}
}
