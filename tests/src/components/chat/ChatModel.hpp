#ifndef CHAT_MODEL_H_
#define CHAT_MODEL_H_

#include <QAbstractListModel>
#include <linphone++/linphone.hh>

// ===================================================================

class ChatModel : public QAbstractListModel {
  Q_OBJECT;

  Q_PROPERTY(
    QString sipAddress
    READ getSipAddress
    WRITE setSipAddress
    NOTIFY sipAddressChanged
  );

public:
  ChatModel (QObject *parent = Q_NULLPTR) : QAbstractListModel(parent) {}

  int rowCount (const QModelIndex &index = QModelIndex()) const {
    return m_entries.count();
  }

  QHash<int, QByteArray> roleNames () const;
  QVariant data (const QModelIndex &index, int role) const;

signals:
  void sipAddressChanged (const QString &sipAddress);

private:
  QString getSipAddress () const;
  void setSipAddress (const QString &sip_address);

  QList<QVariantMap> m_entries;
  std::shared_ptr<linphone::ChatRoom> m_chat_room;
};

#endif // CHAT_MODEL_H_
