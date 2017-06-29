/*
 * ChatProxyModel.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#include "../core/CoreManager.hpp"

#include "ChatProxyModel.hpp"

using namespace std;

// =============================================================================

// Fetch the L last filtered chat entries.
class ChatProxyModel::ChatModelFilter : public QSortFilterProxyModel {
public:
  ChatModelFilter (QObject *parent) : QSortFilterProxyModel(parent) {}

  ChatModel::EntryType getEntryTypeFilter () {
    return mEntryTypeFilter;
  }

  void setEntryTypeFilter (ChatModel::EntryType type) {
    mEntryTypeFilter = type;
    invalidate();
  }

protected:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &) const override {
    if (mEntryTypeFilter == ChatModel::EntryType::GenericEntry)
      return true;

    QModelIndex index = sourceModel()->index(sourceRow, 0, QModelIndex());
    const QVariantMap data = index.data().toMap();

    return data["type"].toInt() == mEntryTypeFilter;
  }

private:
  ChatModel::EntryType mEntryTypeFilter = ChatModel::EntryType::GenericEntry;
};

// =============================================================================

const int ChatProxyModel::ENTRIES_CHUNK_SIZE = 50;

ChatProxyModel::ChatProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(new ChatModelFilter(this));
}

// -----------------------------------------------------------------------------

#define GET_CHAT_MODEL() \
  if (!mChatModel) \
    return; \
  mChatModel

#define CREATE_PARENT_MODEL_FUNCTION(METHOD) \
  void ChatProxyModel::METHOD() { \
    GET_CHAT_MODEL()->METHOD(); \
  }

#define CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(METHOD, ARG_TYPE) \
  void ChatProxyModel::METHOD(ARG_TYPE value) { \
    GET_CHAT_MODEL()->METHOD(value); \
  }

#define CREATE_PARENT_MODEL_FUNCTION_WITH_ID(METHOD) \
  void ChatProxyModel::METHOD(int id) { \
    QModelIndex sourceIndex = mapToSource(index(id, 0)); \
    GET_CHAT_MODEL()->METHOD( \
      static_cast<ChatModelFilter *>(sourceModel())->mapToSource(sourceIndex).row() \
    ); \
  }

CREATE_PARENT_MODEL_FUNCTION(compose);
CREATE_PARENT_MODEL_FUNCTION(removeAllEntries);

CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(sendFileMessage, const QString &);
CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(sendMessage, const QString &);

CREATE_PARENT_MODEL_FUNCTION_WITH_ID(downloadFile);
CREATE_PARENT_MODEL_FUNCTION_WITH_ID(openFile);
CREATE_PARENT_MODEL_FUNCTION_WITH_ID(openFileDirectory);
CREATE_PARENT_MODEL_FUNCTION_WITH_ID(removeEntry);
CREATE_PARENT_MODEL_FUNCTION_WITH_ID(resendMessage);

#undef GET_CHAT_MODEL
#undef CREATE_PARENT_MODEL_FUNCTION
#undef CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM
#undef CREATE_PARENT_MODEL_FUNCTION_WITH_ID

// -----------------------------------------------------------------------------

void ChatProxyModel::loadMoreEntries () {
  int count = rowCount();
  int parentCount = sourceModel()->rowCount();

  if (count < parentCount) {
    // Do not increase `mMaxDisplayedEntries` if it's not necessary...
    // Limit qml calls.
    if (count == mMaxDisplayedEntries)
      mMaxDisplayedEntries += ENTRIES_CHUNK_SIZE;

    invalidateFilter();

    count = rowCount() - count;
    if (count > 0)
      emit moreEntriesLoaded(count);
  }
}

void ChatProxyModel::setEntryTypeFilter (ChatModel::EntryType type) {
  ChatModelFilter *chatModelFilter = static_cast<ChatModelFilter *>(sourceModel());

  if (chatModelFilter->getEntryTypeFilter() != type) {
    chatModelFilter->setEntryTypeFilter(type);
    emit entryTypeFilterChanged(type);
  }
}

// -----------------------------------------------------------------------------

bool ChatProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &) const {
  return sourceModel()->rowCount() - sourceRow <= mMaxDisplayedEntries;
}

// -----------------------------------------------------------------------------

QString ChatProxyModel::getSipAddress () const {
  return mChatModel ? mChatModel->getSipAddress() : QString("");
}

void ChatProxyModel::setSipAddress (const QString &sipAddress) {
  mMaxDisplayedEntries = ENTRIES_CHUNK_SIZE;

  if (mChatModel) {
    ChatModel *chatModel = mChatModel.get();
    QObject::disconnect(chatModel, &ChatModel::isRemoteComposingChanged, this, &ChatProxyModel::handleIsRemoteComposingChanged);
    QObject::disconnect(chatModel, &ChatModel::messageReceived, this, &ChatProxyModel::handleMessageReceived);
    QObject::disconnect(chatModel, &ChatModel::messageSent, this, &ChatProxyModel::handleMessageSent);
  }

  mChatModel = CoreManager::getInstance()->getChatModelFromSipAddress(sipAddress);

  if (mChatModel) {
    mChatModel->resetMessagesCount();

    ChatModel *chatModel = mChatModel.get();
    QObject::connect(chatModel, &ChatModel::isRemoteComposingChanged, this, &ChatProxyModel::handleIsRemoteComposingChanged);
    QObject::connect(chatModel, &ChatModel::messageReceived, this, &ChatProxyModel::handleMessageReceived);
    QObject::connect(chatModel, &ChatModel::messageSent, this, &ChatProxyModel::handleMessageSent);
  }

  static_cast<ChatModelFilter *>(sourceModel())->setSourceModel(mChatModel.get());
}

bool ChatProxyModel::getIsRemoteComposing () const {
  return mChatModel ? mChatModel->getIsRemoteComposing() : false;
}

// -----------------------------------------------------------------------------

void ChatProxyModel::handleIsRemoteComposingChanged (bool status) {
  emit isRemoteComposingChanged(status);
}

void ChatProxyModel::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &) {
  mMaxDisplayedEntries++;
  mChatModel->resetMessagesCount();
}

void ChatProxyModel::handleMessageSent (const shared_ptr<linphone::ChatMessage> &) {
  mMaxDisplayedEntries++;
}
