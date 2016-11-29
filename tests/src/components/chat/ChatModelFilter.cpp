#include "ChatProxyModel.hpp"

// ===================================================================

ChatModelFilter::ChatModelFilter (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(&m_chat_model);
}

bool ChatModelFilter::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  if (m_entry_type_filter == ChatModel::EntryType::GenericEntry)
    return true;

  QModelIndex index = sourceModel()->index(source_row, 0, QModelIndex());
  const QVariantMap &data = qvariant_cast<QVariantMap>(
    index.data()
  );

  return data["type"].toInt() == m_entry_type_filter;
}
