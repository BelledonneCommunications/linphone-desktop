
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

#include "ChatMessageFileProxy.hpp"
#include "core/App.hpp"
#include "core/chat/ChatGui.hpp"

DEFINE_ABSTRACT_OBJECT(ChatMessageFileProxy)

ChatMessageFileProxy::ChatMessageFileProxy(QObject *parent) : LimitProxy(parent) {
	mList = ChatMessageFileList::create();
	connect(mList.get(), &ChatMessageFileList::chatChanged, this, &ChatMessageFileProxy::chatGuiChanged);
	connect(this, &ChatMessageFileProxy::filterTypeChanged, this, [this] { invalidate(); });
	setSourceModels(new SortFilterList(mList.get()));
}

ChatMessageFileProxy::~ChatMessageFileProxy() {
}

ChatGui *ChatMessageFileProxy::getChatGui() const {
	return mList && mList->getChatCore() ? new ChatGui(mList->getChatCore()) : nullptr;
}

void ChatMessageFileProxy::setChatGui(ChatGui *chat) const {
	if (mList) mList->setChatCore(chat ? chat->mCore : nullptr);
}

bool ChatMessageFileProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	if (getFilterType() == (int)FilterContentType::All) return true;
	else {
		auto contentCore = getItemAtSource<ChatMessageFileList, ChatMessageContentCore>(sourceRow);
		if (!contentCore) return false;
		bool isMedia = Utils::isVideo(contentCore->getFilePath()) || Utils::isImage(contentCore->getFilePath()) ||
		               Utils::isAnimatedImage(contentCore->getFilePath());
		if (getFilterType() == (int)FilterContentType::Medias) {
			return isMedia;
		} else {
			return !isMedia;
		}
		return false;
	}
}

bool ChatMessageFileProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft,
                                                    const QModelIndex &sourceRight) const {
	return true;
}
