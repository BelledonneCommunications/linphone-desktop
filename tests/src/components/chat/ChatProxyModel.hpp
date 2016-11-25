#ifndef CHAT_PROXY_MODEL_H_
#define CHAT_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

#include "ChatModel.hpp"

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
  ChatModel *getChatModel () {
    return &m_chat_model;
  }

  void setEntryTypeFilter (ChatModel::EntryType type) {
    // TODO.
  }

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const;

private:
  QString getSipAddress () const {
    return m_chat_model.getSipAddress();
  }

  void setSipAddress (const QString &sip_address) {
    m_chat_model.setSipAddress(sip_address);
  }

  ChatModel m_chat_model;
};

#endif // CHAT_PROXY_MODEL_H_
