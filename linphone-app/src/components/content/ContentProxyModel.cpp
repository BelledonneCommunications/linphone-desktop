/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "ContentProxyModel.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "ContentListModel.hpp"

// =============================================================================

ContentProxyModel::ContentProxyModel (QObject * parent) : QSortFilterProxyModel(parent){
	
}

void ContentProxyModel::setChatMessageModel(ChatMessageModel * message){
	if(message){
		setSourceModel(message->getContents().get());
		sort(0);
	}
	emit chatMessageModelChanged();
}

bool ContentProxyModel::filterAcceptsRow (
		int sourceRow,
		const QModelIndex &sourceParent
		) const {
	Q_UNUSED(sourceRow)
	Q_UNUSED(sourceParent)
	return true;
}

bool ContentProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	const ContentModel *contentA = sourceModel()->data(left).value<ContentModel *>();
	const ContentModel *contentB = sourceModel()->data(right).value<ContentModel *>();
	bool aIsForward = contentA->getChatMessageModel()->isForward();
	bool aIsReply = contentA->getChatMessageModel()->isReply();
	bool aIsVoiceRecording = contentA->isVoiceRecording();
	bool aIsFile = contentA->isFile() || contentA->isFileEncrypted() || contentA->isFileTransfer();
	bool aIsText = contentA->isText() ;
	bool bIsForward = contentB->getChatMessageModel()->isForward();
	bool bIsReply = contentB->getChatMessageModel()->isReply();
	bool bIsVoiceRecording = contentB->isVoiceRecording();
	bool bIsFile = contentB->isFile() || contentB->isFileEncrypted() || contentB->isFileTransfer();
	bool bIsText = contentB->isText() ;
	
	return !bIsForward && (aIsForward
			|| !bIsReply && (aIsReply
				|| !bIsVoiceRecording && (aIsVoiceRecording
					|| !bIsFile && (aIsFile
						|| aIsText && !bIsText
						)
					)
				)
			);
}
