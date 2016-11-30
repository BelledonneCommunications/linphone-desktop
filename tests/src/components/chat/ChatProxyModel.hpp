#ifndef CHAT_PROXY_MODEL_H_
#define CHAT_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

#include "ChatModel.hpp"

// ===================================================================
// Fetch the L last filtered chat entries.
// ===================================================================

// Cannot be used as a nested class by Qt and `Q_OBJECTY` macro
// must be used in header c++ file.
class ChatModelFilter : public QSortFilterProxyModel {
  friend class ChatProxyModel;
  Q_OBJECT;

public:
  ChatModelFilter (QObject *parent = Q_NULLPTR);

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &parent) const;

private:
  void setEntryTypeFilter (ChatModel::EntryType type);

  ChatModel m_chat_model;
  ChatModel::EntryType m_entry_type_filter = ChatModel::EntryType::GenericEntry;
};

// ===================================================================

class ChatProxyModel : public QSortFilterProxyModel {
  Q_OBJECT;

  Q_PROPERTY(
    QString sipAddress
    READ getSipAddress
    WRITE setSipAddress
    NOTIFY sipAddressChanged
  );

signals:
  void sipAddressChanged (const QString &sipAddress);

public:
  ChatProxyModel (QObject *parent = Q_NULLPTR);

public slots:
  void loadMoreEntries ();

  void setEntryTypeFilter (ChatModel::EntryType type) {
    m_chat_model_filter.setEntryTypeFilter(type);
  }

  void removeEntry (int id);

  void removeAllEntries () {
    static_cast<ChatModel *>(m_chat_model_filter.sourceModel())->removeAllEntries();
  }

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const;

private:
  QString getSipAddress () const {
    static_cast<ChatModel *>(m_chat_model_filter.sourceModel())->getSipAddress();
  }

  void setSipAddress (const QString &sip_address) {
    static_cast<ChatModel *>(m_chat_model_filter.sourceModel())->setSipAddress(
      sip_address
    );
  }

  ChatModelFilter m_chat_model_filter;

  unsigned int m_n_max_displayed_entries = ENTRIES_CHUNK_SIZE;

  static const unsigned int ENTRIES_CHUNK_SIZE;
};

#endif // CHAT_PROXY_MODEL_H_
