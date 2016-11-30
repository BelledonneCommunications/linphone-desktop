#include "ChatProxyModel.hpp"

// ===================================================================

ChatModelFilter::ChatModelFilter (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(&m_chat_model);
}

bool ChatModelFilter::filterAcceptsRow (int source_row, const QModelIndex &) const {
  if (m_entry_type_filter == ChatModel::EntryType::GenericEntry)
    return true;

  QModelIndex index = sourceModel()->index(source_row, 0, QModelIndex());
  const QVariantMap &data = qvariant_cast<QVariantMap>(
    index.data()
  );

  return data["type"].toInt() == m_entry_type_filter;
}

void ChatModelFilter::setEntryTypeFilter (ChatModel::EntryType type) {
  m_entry_type_filter = type;
  invalidateFilter();
}

// ===================================================================

const unsigned int ChatProxyModel::ENTRIES_CHUNK_SIZE = 25;

ChatProxyModel::ChatProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(&m_chat_model_filter);
}

void ChatProxyModel::loadMoreEntries () {
  int count = rowCount();
  int parent_count = m_chat_model_filter.rowCount();

  if (count < parent_count) {
    // Do not increase `m_n_max_displayed_entries` if it's not necessary...
    // Limit qml calls.
    if (count == m_n_max_displayed_entries)
      m_n_max_displayed_entries += ENTRIES_CHUNK_SIZE;

    invalidateFilter();

    if (count < rowCount())
      emit moreEntriesLoaded();
  }
}

void ChatProxyModel::setEntryTypeFilter (ChatModel::EntryType type) {
  if (m_chat_model_filter.m_entry_type_filter != type) {
    m_chat_model_filter.setEntryTypeFilter(type);
    emit entryTypeFilterChanged(type);
  }
}

void ChatProxyModel::removeEntry (int id) {
  QModelIndex source_index = mapToSource(index(id, 0));
  static_cast<ChatModel *>(m_chat_model_filter.sourceModel())->removeEntry(
    m_chat_model_filter.mapToSource(source_index).row()
  );
}

bool ChatProxyModel::filterAcceptsRow (int source_row, const QModelIndex &) const {
  return m_chat_model_filter.rowCount() - source_row <= m_n_max_displayed_entries;
}
