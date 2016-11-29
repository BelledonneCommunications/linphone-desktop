#ifndef CHAT_MODEL_FILTER_H_
#define CHAT_MODEL_FILTER_H_

#include <QSortFilterProxyModel>

#include "ChatModel.hpp"
#include <QtDebug>

// ===================================================================
// Fetch K filtered chat entries.
// ===================================================================

class ChatModelFilter : public QSortFilterProxyModel {
  friend class ChatProxyModel;

  Q_OBJECT;

public:
  ChatModelFilter (QObject *parent = Q_NULLPTR);

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const;

private:
  void setEntryTypeFilter (ChatModel::EntryType type) {
    m_entry_type_filter = type;
    invalidateFilter();
  }

  ChatModel m_chat_model;

  ChatModel::EntryType m_entry_type_filter = ChatModel::EntryType::GenericEntry;
};

#endif // CHAT_MODEL_FILTER_H_
