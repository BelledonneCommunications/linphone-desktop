
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

#ifndef CHAT_MESSAGE_FILE_PROXY_H_
#define CHAT_MESSAGE_FILE_PROXY_H_

#include "ChatMessageFileList.hpp"
#include "core/chat/message/ChatMessageCore.hpp"
#include "core/proxy/LimitProxy.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class ChatMessageFileProxy : public LimitProxy, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(ChatGui *chat READ getChatGui WRITE setChatGui NOTIFY chatGuiChanged)

public:
	enum class FilterContentType { All = 0, Medias = 1, Documents = 2 };
	Q_ENUM(FilterContentType)

	DECLARE_SORTFILTER_CLASS()
	ChatMessageFileProxy(QObject *parent = Q_NULLPTR);
	~ChatMessageFileProxy();

	ChatGui *getChatGui() const;
	void setChatGui(ChatGui *chat) const;

signals:
	void chatGuiChanged();
	void filterChanged();

protected:
	QSharedPointer<ChatMessageFileList> mList;
	DECLARE_ABSTRACT_OBJECT
};

#endif
