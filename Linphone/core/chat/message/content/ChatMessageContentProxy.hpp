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

#ifndef CHAT_MESSAGE_CONENT_PROXY_H_
#define CHAT_MESSAGE_CONENT_PROXY_H_

#include "ChatMessageContentList.hpp"
#include "core/proxy/LimitProxy.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class ChatMessageGui;
class ChatMessageContentGui;

class ChatMessageContentProxy : public LimitProxy, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(ChatMessageGui *chatMessageGui READ getChatMessageGui WRITE setChatMessageGui NOTIFY chatChanged)

public:
	enum class FilterContentType { Unknown = 0, File = 1, Text = 2, Voice = 3, Conference = 4, All = 5 };
	Q_ENUM(FilterContentType)

	DECLARE_SORTFILTER_CLASS(ChatMessageContentProxy *mHideListProxy = nullptr;)
	ChatMessageContentProxy(QObject *parent = Q_NULLPTR);
	~ChatMessageContentProxy();

	ChatMessageGui *getChatMessageGui();
	void setChatMessageGui(ChatMessageGui *chat);

	void setSourceModel(QAbstractItemModel *sourceModel) override;

	Q_INVOKABLE void addFiles(const QStringList &paths);
	Q_INVOKABLE void removeContent(ChatMessageContentGui *contentGui);
	Q_INVOKABLE void clear();

signals:
	void chatChanged();
	void filterChanged();
	void messageInserted(int index, ChatMessageGui *message);

protected:
	QSharedPointer<ChatMessageContentList> mList;
	ChatMessageGui *mChatMessageGui = nullptr;

	DECLARE_ABSTRACT_OBJECT
};

#endif
