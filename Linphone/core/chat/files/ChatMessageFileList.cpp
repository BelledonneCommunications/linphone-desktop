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

#include "ChatMessageFileList.hpp"
#include "core/App.hpp"
#include "core/chat/message/content/ChatMessageContentCore.hpp"

#include <QSharedPointer>

#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ChatMessageFileList)

QSharedPointer<ChatMessageFileList> ChatMessageFileList::create() {
	auto model = QSharedPointer<ChatMessageFileList>(new ChatMessageFileList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	return model;
}

ChatMessageFileList::ChatMessageFileList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ChatMessageFileList::~ChatMessageFileList() {
	mustBeInMainThread("~" + getClassName());
	mList.clear();
}

QSharedPointer<ChatCore> ChatMessageFileList::getChatCore() const {
	return mChat;
}

void ChatMessageFileList::setChatCore(QSharedPointer<ChatCore> chatCore) {
	if (mChat != chatCore) {
		if (mChat) disconnect(mChat.get());
		mChat = chatCore;
		auto lUpdate = [this] {
			auto fileList = mChat->getFileList();
			resetData<ChatMessageContentCore>(fileList);
		};
		if (mChat) connect(mChat.get(), &ChatCore::fileListChanged, this, lUpdate);
		lUpdate();
		emit chatChanged();
	}
}

QVariant ChatMessageFileList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(new ChatMessageContentGui(mList[row].objectCast<ChatMessageContentCore>()));
	return QVariant();
}