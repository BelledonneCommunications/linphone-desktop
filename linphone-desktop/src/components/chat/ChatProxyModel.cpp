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

#include "ChatProxyModel.hpp"

using namespace std;

// =============================================================================

// Fetch the L last filtered chat entries.
class ChatProxyModel::ChatModelFilter : public QSortFilterProxyModel {
public:
  ChatModelFilter (QObject *parent) : QSortFilterProxyModel(parent) {
    setSourceModel(&mChatModel);
  }

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
    const QVariantMap &data = index.data().toMap();

    return data["type"].toInt() == mEntryTypeFilter;
  }

private:
  ChatModel mChatModel;
  ChatModel::EntryType mEntryTypeFilter = ChatModel::EntryType::GenericEntry;
};

// =============================================================================

const int ChatProxyModel::ENTRIES_CHUNK_SIZE = 50;

ChatProxyModel::ChatProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  mChatModelFilter = new ChatModelFilter(this);

  setSourceModel(mChatModelFilter);

  ChatModel *chat = static_cast<ChatModel *>(mChatModelFilter->sourceModel());

  QObject::connect(chat, &ChatModel::messageReceived, this, [this](const shared_ptr<linphone::ChatMessage> &) {
      mMaxDisplayedEntries++;
    });

  QObject::connect(chat, &ChatModel::messageSent, this, [this](const shared_ptr<linphone::ChatMessage> &) {
      mMaxDisplayedEntries++;
    });
}

void ChatProxyModel::loadMoreEntries () {
  int count = rowCount();
  int parentCount = mChatModelFilter->rowCount();

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
  if (mChatModelFilter->getEntryTypeFilter() != type) {
    mChatModelFilter->setEntryTypeFilter(type);
    emit entryTypeFilterChanged(type);
  }
}

void ChatProxyModel::removeEntry (int id) {
  QModelIndex sourceIndex = mapToSource(index(id, 0));
  static_cast<ChatModel *>(mChatModelFilter->sourceModel())->removeEntry(
    mChatModelFilter->mapToSource(sourceIndex).row()
  );
}

void ChatProxyModel::removeAllEntries () {
  static_cast<ChatModel *>(mChatModelFilter->sourceModel())->removeAllEntries();
}

void ChatProxyModel::sendMessage (const QString &message) {
  static_cast<ChatModel *>(mChatModelFilter->sourceModel())->sendMessage(message);
}

void ChatProxyModel::resendMessage (int id) {
  QModelIndex sourceIndex = mapToSource(index(id, 0));
  static_cast<ChatModel *>(mChatModelFilter->sourceModel())->resendMessage(
    mChatModelFilter->mapToSource(sourceIndex).row()
  );
}

void ChatProxyModel::sendFileMessage (const QString &path) {
  static_cast<ChatModel *>(mChatModelFilter->sourceModel())->sendFileMessage(path);
}

void ChatProxyModel::downloadFile (int id) {
  QModelIndex sourceIndex = mapToSource(index(id, 0));
  static_cast<ChatModel *>(mChatModelFilter->sourceModel())->downloadFile(
    mChatModelFilter->mapToSource(sourceIndex).row()
  );
}

// -----------------------------------------------------------------------------

bool ChatProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &) const {
  return mChatModelFilter->rowCount() - sourceRow <= mMaxDisplayedEntries;
}

// -----------------------------------------------------------------------------

QString ChatProxyModel::getSipAddress () const {
  return static_cast<ChatModel *>(mChatModelFilter->sourceModel())->getSipAddress();
}

void ChatProxyModel::setSipAddress (const QString &sipAddress) {
  static_cast<ChatModel *>(mChatModelFilter->sourceModel())->setSipAddress(
    sipAddress
  );
}
