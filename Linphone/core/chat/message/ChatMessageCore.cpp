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

#include "ChatMessageCore.hpp"
#include "core/App.hpp"
#include "model/tool/ToolModel.hpp"

DEFINE_ABSTRACT_OBJECT(ChatMessageCore)

QSharedPointer<ChatMessageCore> ChatMessageCore::create(const std::shared_ptr<linphone::ChatMessage> &chatmessage) {
	auto sharedPointer = QSharedPointer<ChatMessageCore>(new ChatMessageCore(chatmessage), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

ChatMessageCore::ChatMessageCore(const std::shared_ptr<linphone::ChatMessage> &chatmessage) {
	// lDebug() << "[ChatMessageCore] new" << this;
	mustBeInLinphoneThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mChatMessageModel = Utils::makeQObject_ptr<ChatMessageModel>(chatmessage);
	mChatMessageModel->setSelf(mChatMessageModel);
	mText = mChatMessageModel->getText();
	mTimestamp = QDateTime::fromSecsSinceEpoch(chatmessage->getTime());
	auto from = chatmessage->getFromAddress();
	auto to = chatmessage->getLocalAddress();
	mIsRemoteMessage = !from->weakEqual(to);
	mPeerAddress = Utils::coreStringToAppString(chatmessage->getPeerAddress()->asStringUriOnly());
	mPeerName = ToolModel::getDisplayName(chatmessage->getPeerAddress()->clone());
}

ChatMessageCore::~ChatMessageCore() {
}

void ChatMessageCore::setSelf(QSharedPointer<ChatMessageCore> me) {
	mChatMessageModelConnection = SafeConnection<ChatMessageCore, ChatMessageModel>::create(me, mChatMessageModel);
}

QDateTime ChatMessageCore::getTimestamp() const {
	return mTimestamp;
}

void ChatMessageCore::setTimestamp(QDateTime timestamp) {
	if (mTimestamp != timestamp) {
		mTimestamp = timestamp;
		emit timestampChanged(timestamp);
	}
}

QString ChatMessageCore::getText() const {
	return mText;
}

void ChatMessageCore::setText(QString text) {
	if (mText != text) {
		mText = text;
		emit textChanged(text);
	}
}

QString ChatMessageCore::getPeerAddress() const {
	return mPeerAddress;
}

QString ChatMessageCore::getPeerName() const {
	return mPeerName;
}

bool ChatMessageCore::isRemoteMessage() const {
	return mIsRemoteMessage;
}

void ChatMessageCore::setIsRemoteMessage(bool isRemote) {
	if (mIsRemoteMessage != isRemote) {
		mIsRemoteMessage = isRemote;
		emit isRemoteMessageChanged(isRemote);
	}
}
