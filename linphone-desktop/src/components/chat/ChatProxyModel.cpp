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

// =============================================================================

// Fetch the L last filtered chat entries.
class ChatProxyModel::ChatModelFilter : public QSortFilterProxyModel {
public:
  ChatModelFilter (QObject *parent) : QSortFilterProxyModel(parent) {
    setSourceModel(&m_chat_model);
  }

  ChatModel::EntryType getEntryTypeFilter () {
    return m_entry_type_filter;
  }

  void setEntryTypeFilter (ChatModel::EntryType type) {
    m_entry_type_filter = type;
    invalidate();
  }

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &) const override {
    if (m_entry_type_filter == ChatModel::EntryType::GenericEntry)
      return true;

    QModelIndex index = sourceModel()->index(source_row, 0, QModelIndex());
    const QVariantMap &data = index.data().toMap();

    return data["type"].toInt() == m_entry_type_filter;
  }

private:
  ChatModel m_chat_model;
  ChatModel::EntryType m_entry_type_filter = ChatModel::EntryType::GenericEntry;
};

// =============================================================================

const unsigned int ChatProxyModel::ENTRIES_CHUNK_SIZE = 50;

ChatProxyModel::ChatProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  m_chat_model_filter = new ChatModelFilter(this);

  setSourceModel(m_chat_model_filter);

  ChatModel *chat = static_cast<ChatModel *>(m_chat_model_filter->sourceModel());

  QObject::connect(
    chat, &ChatModel::messageReceived, this, [this](const shared_ptr<linphone::ChatMessage> &) {
      m_n_max_displayed_entries++;
    }
  );

  QObject::connect(
    chat, &ChatModel::messageSent, this, [this](const shared_ptr<linphone::ChatMessage> &) {
      m_n_max_displayed_entries++;
    }
  );
}

void ChatProxyModel::loadMoreEntries () {
  int count = rowCount();
  int parent_count = m_chat_model_filter->rowCount();

  if (count < parent_count) {
    // Do not increase `m_n_max_displayed_entries` if it's not necessary...
    // Limit qml calls.
    if (count == m_n_max_displayed_entries)
      m_n_max_displayed_entries += ENTRIES_CHUNK_SIZE;

    invalidateFilter();

    count = rowCount() - count;
    if (count > 0)
      emit moreEntriesLoaded(count);
  }
}

void ChatProxyModel::setEntryTypeFilter (ChatModel::EntryType type) {
  if (m_chat_model_filter->getEntryTypeFilter() != type) {
    m_chat_model_filter->setEntryTypeFilter(type);
    emit entryTypeFilterChanged(type);
  }
}

void ChatProxyModel::removeEntry (int id) {
  QModelIndex source_index = mapToSource(index(id, 0));
  static_cast<ChatModel *>(m_chat_model_filter->sourceModel())->removeEntry(
    m_chat_model_filter->mapToSource(source_index).row()
  );
}

void ChatProxyModel::removeAllEntries () {
  static_cast<ChatModel *>(m_chat_model_filter->sourceModel())->removeAllEntries();
}

void ChatProxyModel::sendMessage (const QString &message) {
  static_cast<ChatModel *>(m_chat_model_filter->sourceModel())->sendMessage(message);
}

void ChatProxyModel::resendMessage (int id) {
  QModelIndex source_index = mapToSource(index(id, 0));
  static_cast<ChatModel *>(m_chat_model_filter->sourceModel())->resendMessage(
    m_chat_model_filter->mapToSource(source_index).row()
  );
}

void ChatProxyModel::sendFileMessage (const QString &path) {
  static_cast<ChatModel *>(m_chat_model_filter->sourceModel())->sendFileMessage(path);
}

void ChatProxyModel::downloadFile (int id, const QString &download_path) {
  QModelIndex source_index = mapToSource(index(id, 0));
  static_cast<ChatModel *>(m_chat_model_filter->sourceModel())->downloadFile(
    m_chat_model_filter->mapToSource(source_index).row(), download_path
  );
}

// -----------------------------------------------------------------------------

bool ChatProxyModel::filterAcceptsRow (int source_row, const QModelIndex &) const {
  return m_chat_model_filter->rowCount() - source_row <= m_n_max_displayed_entries;
}

// -----------------------------------------------------------------------------

QString ChatProxyModel::getSipAddress () const {
  return static_cast<ChatModel *>(m_chat_model_filter->sourceModel())->getSipAddress();
}

void ChatProxyModel::setSipAddress (const QString &sip_address) {
  static_cast<ChatModel *>(m_chat_model_filter->sourceModel())->setSipAddress(
    sip_address
  );
}
