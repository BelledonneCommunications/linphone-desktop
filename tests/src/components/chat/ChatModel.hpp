#ifndef CHAT_MODEL_H_
#define CHAT_MODEL_H_

#include <linphone++/linphone.hh>
#include <QAbstractListModel>

// =============================================================================
// Fetch all N messages of a ChatRoom.
// =============================================================================

class CoreHandlers;

class ChatModel : public QAbstractListModel {
  class MessageHandlers;

  Q_OBJECT;

  Q_PROPERTY(QString sipAddress READ getSipAddress WRITE setSipAddress NOTIFY sipAddressChanged);

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

  enum MessageStatus {
    MessageStatusDelivered = linphone::ChatMessageStateDelivered,
    MessageStatusInProgress = linphone::ChatMessageStateInProgress,
    MessageStatusNotDelivered = linphone::ChatMessageStateNotDelivered
  };

  Q_ENUM(MessageStatus);

  ChatModel (QObject *parent = Q_NULLPTR);
  ~ChatModel ();

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role) const override;

  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  QString getSipAddress () const;
  void setSipAddress (const QString &sip_address);

  void removeEntry (int id);
  void removeAllEntries ();

  void sendMessage (const QString &message);

signals:
  void sipAddressChanged (const QString &sip_address);
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

  void insertMessageAtEnd (const std::shared_ptr<linphone::ChatMessage> &message);

  QList<ChatEntryData> m_entries;
  std::shared_ptr<linphone::ChatRoom> m_chat_room;

  std::shared_ptr<CoreHandlers> m_core_handlers;
  std::shared_ptr<MessageHandlers> m_message_handlers;
};

#endif // CHAT_MODEL_H_
