#ifndef CHAT_MODEL_H_
#define CHAT_MODEL_H_

#include <linphone++/linphone.hh>
#include <QAbstractListModel>

// =============================================================================
// Fetch all N messages of a ChatRoom.
// =============================================================================

class ChatModel : public QAbstractListModel {
  Q_OBJECT;

  Q_PROPERTY(
    QString sipAddress
    READ getSipAddress
    WRITE setSipAddress
    NOTIFY sipAddressChanged
  );

public:
  typedef QPair<QVariantMap, std::shared_ptr<void> > ChatEntryData;

  enum Roles {
    ChatEntry = Qt::DisplayRole,
    SectionDate
  };

  enum EntryType {
    GenericEntry,
    MessageEntry,
    CallEntry
  };

  Q_ENUM(EntryType);

  enum CallStatus {
    CallStatusDeclined = linphone::CallStatusDeclined,
    CallStatusMissed = linphone::CallStatusMissed,
    CallStatusSuccess = linphone::CallStatusSuccess
  };

  Q_ENUM(CallStatus);

  ChatModel (QObject *parent = Q_NULLPTR);
  ~ChatModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role) const override;

  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  QString getSipAddress () const;
  void setSipAddress (const QString &sip_address);

public slots:
  void removeEntry (int id);
  void removeAllEntries ();

signals:
  void sipAddressChanged (const QString &sipAddress);
  void allEntriesRemoved ();

private:
  void fillMessageEntry (
    QVariantMap &dest,
    const std::shared_ptr<linphone::ChatMessage> &message
  );

  void fillCallStartEntry (
    QVariantMap &dest,
    const std::shared_ptr<linphone::CallLog> &call_log
  );

  void fillCallEndEntry (
    QVariantMap &dest,
    const std::shared_ptr<linphone::CallLog> &call_log
  );

  void removeEntry (ChatEntryData &pair);

  QList<ChatEntryData> m_entries;
  std::shared_ptr<linphone::ChatRoom> m_chat_room;
};

#endif // CHAT_MODEL_H_
