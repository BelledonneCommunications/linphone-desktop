#include "ChatProxyModel.hpp"

// ===================================================================

ChatProxyModel::ChatProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  m_chat_model.setParent(this);
  setSourceModel(&m_chat_model);
  setFilterCaseSensitivity(Qt::CaseInsensitive);
}

bool ChatProxyModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  return true; // TODO.
}
