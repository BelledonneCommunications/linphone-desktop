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
	// mRemoteAddress->clean();
	mStatus = LinphoneEnums::fromLinphone(callLog->getStatus());
	mDate = QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
	mIsOutgoing = callLog->getDir() == linphone::Call::Dir::Outgoing;
	mDuration = QString::number(callLog->getDuration());
	mIsConference = callLog->wasConference();
	if (mIsConference) {
		auto confinfo = callLog->getConferenceInfo();
		mConferenceInfo = ConferenceInfoCore::create(confinfo);
		mRemoteAddress = Utils::coreStringToAppString(confinfo->getUri()->asStringUriOnly());
		mDisplayName = Utils::coreStringToAppString(confinfo->getSubject());
	} else {
		mRemoteAddress = Utils::coreStringToAppString(addr->asStringUriOnly());
		mDisplayName = ToolModel::getDisplayName(Utils::coreStringToAppString(addr->asStringUriOnly()));
		auto inFriend = Utils::findFriendByAddress(mRemoteAddress);
		if (inFriend) {
			auto friendGui = inFriend->getValue().value<FriendGui *>();
			if (friendGui) mDisplayName = friendGui->getCore()->getDisplayName();
		}
	}
}

CallHistoryCore::~CallHistoryCore() {
	// lDebug()<< "[CallHistoryCore] delete" << this;
	mustBeInMainThread("~" + getClassName());
}

void CallHistoryCore::setSelf(QSharedPointer<CallHistoryCore> me) {
	mHistoryModelConnection = QSharedPointer<SafeConnection<CallHistoryCore, CallHistoryModel>>(
	    new SafeConnection<CallHistoryCore, CallHistoryModel>(me, mCallHistoryModel), &QObject::deleteLater);
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
	mHistoryModelConnection->invokeToModel([this]() { mCallHistoryModel->removeCallHistory(); });
}