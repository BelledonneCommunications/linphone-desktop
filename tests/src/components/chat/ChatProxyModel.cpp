#include "ChatProxyModel.hpp"

#include <QtDebug>
// ===================================================================

ChatProxyModel::ChatProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  m_chat_model.setParent(this);
  setSourceModel(&m_chat_model);
  setFilterCaseSensitivity(Qt::CaseInsensitive);
}

bool ChatProxyModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
  const QVariantMap &data = qvariant_cast<QVariantMap>(
    index.data()
  );

  qDebug() << data["type"];

  return true; // TODO.
}
