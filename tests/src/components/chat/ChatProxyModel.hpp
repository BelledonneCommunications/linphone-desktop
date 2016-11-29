#ifndef CHAT_PROXY_MODEL_H_
#define CHAT_PROXY_MODEL_H_

#include "ChatModelFilter.hpp"

// ===================================================================
// Fetch the L last filtered chat entries.
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

  int rowCount (const QModelIndex &parent = QModelIndex()) const override;
  QVariant data (const QModelIndex &index, int role) const override;

public slots:
  void loadMoreEntries ();

  void setEntryTypeFilter (ChatModel::EntryType type) {
    m_chat_model_filter.setEntryTypeFilter(type);
  }

  void removeEntry (int id);

  void removeAllEntries () {
    static_cast<ChatModel *>(m_chat_model_filter.sourceModel())->removeAllEntries();
  }

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
