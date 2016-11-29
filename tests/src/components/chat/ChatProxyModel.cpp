#include "ChatProxyModel.hpp"

// ===================================================================

const unsigned int ChatProxyModel::ENTRIES_CHUNK_SIZE = 25;

ChatProxyModel::ChatProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(&m_chat_model_filter);
}

int ChatProxyModel::rowCount (const QModelIndex &parent) const {
  int size = QSortFilterProxyModel::rowCount(parent);
  return size < m_n_max_displayed_entries ? size : m_n_max_displayed_entries;
}

QVariant ChatProxyModel::data (const QModelIndex &index, int role) const {
  QAbstractItemModel *model = sourceModel();

  return model->data(
    model->index(
      mapToSource(index).row() + (model->rowCount() - rowCount()),
      0
    ),
    role
  );
}

void ChatProxyModel::loadMoreEntries () {
  // TODO.
}

void ChatProxyModel::removeEntry (int id) {
  QModelIndex source_index = mapToSource(index(id, 0));

  static_cast<ChatModel *>(m_chat_model_filter.sourceModel())->removeEntry(
    mapToSource(source_index).row()
  );
}
