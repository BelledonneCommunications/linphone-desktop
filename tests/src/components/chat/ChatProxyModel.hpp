#ifndef CHAT_PROXY_MODEL_H_
#define CHAT_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

#include "ChatModel.hpp"

// =============================================================================

class ChatProxyModel : public QSortFilterProxyModel {
  class ChatModelFilter;

  Q_OBJECT;

  Q_PROPERTY(QString sipAddress READ getSipAddress WRITE setSipAddress NOTIFY sipAddressChanged);

public:
  ChatProxyModel (QObject *parent = Q_NULLPTR);

  Q_INVOKABLE void loadMoreEntries ();
  Q_INVOKABLE void setEntryTypeFilter (ChatModel::EntryType type);
  Q_INVOKABLE void removeEntry (int id);

  Q_INVOKABLE void removeAllEntries ();

  Q_INVOKABLE void sendMessage (const QString &message);
  Q_INVOKABLE void resendMessage (int id);

  Q_INVOKABLE void sendFileMessage (const QString &path);

  Q_INVOKABLE void downloadFile (int id, const QString &download_path);

signals:
  void sipAddressChanged (const QString &sip_address);
  void moreEntriesLoaded (int n);

  void entryTypeFilterChanged (ChatModel::EntryType type);

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const override;

private:
  QString getSipAddress () const;
  void setSipAddress (const QString &sip_address);

  ChatModelFilter *m_chat_model_filter;
  int m_n_max_displayed_entries = ENTRIES_CHUNK_SIZE;

  static const unsigned int ENTRIES_CHUNK_SIZE;
};

#endif // CHAT_PROXY_MODEL_H_
