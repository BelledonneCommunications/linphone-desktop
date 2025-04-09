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

#include "CallHistoryCore.hpp"
#include "core/App.hpp"
#include "core/conference/ConferenceInfoCore.hpp"
#include "core/friend/FriendGui.hpp"
#include "model/call-history/CallHistoryModel.hpp"
#include "model/object/VariantObject.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

#include <QDateTime>

DEFINE_ABSTRACT_OBJECT(CallHistoryCore)

QSharedPointer<CallHistoryCore> CallHistoryCore::create(const std::shared_ptr<linphone::CallLog> &callLog) {
	auto sharedPointer = QSharedPointer<CallHistoryCore>(new CallHistoryCore(callLog), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

CallHistoryCore::CallHistoryCore(const std::shared_ptr<linphone::CallLog> &callLog) : QObject(nullptr) {
	// lDebug()<< "[CallHistoryCore] new" << this;
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	// Should be call from model Thread
	mustBeInLinphoneThread(getClassName());
	mCallHistoryModel = std::make_shared<CallHistoryModel>(callLog);

	auto addr = callLog->getRemoteAddress()->clone();
	addr->clean();
	mStatus = LinphoneEnums::fromLinphone(callLog->getStatus());
	mDate = QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
	mIsOutgoing = callLog->getDir() == linphone::Call::Dir::Outgoing;
	mDuration = QString::number(callLog->getDuration());
	mIsConference = callLog->wasConference();
	mCallId = Utils::coreStringToAppString(callLog->getCallId());
	if (mIsConference) {
		auto confinfo = callLog->getConferenceInfo();
		mConferenceInfo = ConferenceInfoCore::create(confinfo);
		mRemoteAddress = Utils::coreStringToAppString(confinfo->getUri()->asStringUriOnly());
		mDisplayName = Utils::coreStringToAppString(confinfo->getSubject());
	} else {
		mRemoteAddress = Utils::coreStringToAppString(addr->asStringUriOnly());
		auto linphoneFriend = ToolModel::findFriendByAddress(addr);
		if (linphoneFriend) {
			mFriendModel = Utils::makeQObject_ptr<FriendModel>(linphoneFriend);
			mDisplayName = mFriendModel->getFullName();
		} else {
			mDisplayName = ToolModel::getDisplayName(addr);
		}
	}
}

CallHistoryCore::~CallHistoryCore() {
	// lDebug()<< "[CallHistoryCore] delete" << this;
	mustBeInMainThread("~" + getClassName());
}

void CallHistoryCore::setSelf(QSharedPointer<CallHistoryCore> me) {
	mHistoryModelConnection = SafeConnection<CallHistoryCore, CallHistoryModel>::create(me, mCallHistoryModel);
	mCoreModelConnection = SafeConnection<CallHistoryCore, CoreModel>::create(me, CoreModel::getInstance());
	if (mFriendModel) {
		mFriendModelConnection = SafeConnection<CallHistoryCore, FriendModel>::create(me, mFriendModel);
		mFriendModelConnection->makeConnectToModel(&FriendModel::fullNameChanged, [this]() {
			auto fullName = mFriendModel->getFullName();
			mCoreModelConnection->invokeToCore([this, fullName]() {
				if (fullName != mDisplayName) {
					mDisplayName = fullName;
					emit displayNameChanged();
				}
			});
		});
	}
	auto update = [this, remoteAddress = mRemoteAddress](const std::shared_ptr<linphone::Friend> &updatedFriend) {
		auto friendModel = Utils::makeQObject_ptr<FriendModel>(updatedFriend);
		auto displayName = friendModel->getFullName();
		auto fAddress = ToolModel::interpretUrl(remoteAddress);
		bool isThisFriend = false;
		for (auto f : friendModel->getAddresses()) {
			if (f->weakEqual(fAddress)) {
				isThisFriend = true;
				break;
			}
		}
		if (isThisFriend)
			mCoreModelConnection->invokeToCore([this, friendModel, displayName]() {
				mFriendModel = friendModel;
				auto me = mCoreModelConnection->mCore.mQData; // Locked from previous call.
				mFriendModelConnection = SafeConnection<CallHistoryCore, FriendModel>::create(me, mFriendModel);
				mFriendModelConnection->makeConnectToModel(&FriendModel::fullNameChanged, [this]() {
					auto fullName = mFriendModel->getFullName();
					mCoreModelConnection->invokeToCore([this, fullName]() {
						if (fullName != mDisplayName) {
							mDisplayName = fullName;
							emit displayNameChanged();
						}
					});
				});
				if (displayName != mDisplayName) {
					mDisplayName = displayName;
					emit displayNameChanged();
				}
				emit friendUpdated();
			});
	};
	if (!ToolModel::findFriendByAddress(mRemoteAddress))
		mCoreModelConnection->makeConnectToModel(&CoreModel::friendCreated, update);
	mCoreModelConnection->makeConnectToModel(&CoreModel::friendUpdated, update);
	mCoreModelConnection->makeConnectToModel(&CoreModel::friendRemoved, &CallHistoryCore::onRemoved);
	// Update display name when display name has been requested from magic search cause not found in linphone friends
	// (required to get the right display name if ldap friends cleared)
	mCoreModelConnection->makeConnectToModel(&CoreModel::magicSearchResultReceived, [this, remoteAddress = mRemoteAddress] {
		auto displayName = ToolModel::getDisplayName(remoteAddress);
					mCoreModelConnection->invokeToCore([this, displayName]() {
			mDisplayName = displayName;
			emit displayNameChanged();
		});
	});

}

ConferenceInfoGui *CallHistoryCore::getConferenceInfoGui() const {
	return mConferenceInfo ? new ConferenceInfoGui(mConferenceInfo) : nullptr;
}

QString CallHistoryCore::getDuration() const {
	return mDuration;
}

void CallHistoryCore::setDuration(const QString &duration) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mDuration != duration) {
		mDuration = duration;
		emit durationChanged(mDuration);
	}
}

void CallHistoryCore::remove() {
	mHistoryModelConnection->invokeToModel([this]() {
		mCallHistoryModel->removeCallHistory();
		emit removed();
	});
}

void CallHistoryCore::onRemoved(const std::shared_ptr<linphone::Friend> &updatedFriend) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto fAddress = ToolModel::interpretUrl(mRemoteAddress);
	bool isThisFriend = mFriendModel && updatedFriend == mFriendModel->getFriend();
	if (!isThisFriend)
		for (auto f : updatedFriend->getAddresses()) {
			if (f->weakEqual(fAddress)) {
				isThisFriend = true;
				break;
			}
		}
	if (isThisFriend) {
		mFriendModel = nullptr;
		mFriendModelConnection = nullptr;
		mDisplayName = ToolModel::getDisplayName(fAddress);
		emit displayNameChanged();
		emit friendUpdated();
	}
};
