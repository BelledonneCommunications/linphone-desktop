#include "ChatProxyModel.hpp"

// ===================================================================

ChatProxyModel::ChatProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  m_chat_model.setParent(this);
  setSourceModel(&m_chat_model);
  setFilterCaseSensitivity(Qt::CaseInsensitive);
}

void ChatProxyModel::removeEntry (int id) {
  m_chat_model.removeEntry(
    mapToSource(index(id, 0)).row()
  );
}

bool ChatProxyModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  if (m_entry_type_filter == ChatModel::EntryType::GenericEntry)
    return true;

  QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
  const QVariantMap &data = qvariant_cast<QVariantMap>(
    index.data()
  );

  return (data["type"].toInt() == m_entry_type_filter);
}
