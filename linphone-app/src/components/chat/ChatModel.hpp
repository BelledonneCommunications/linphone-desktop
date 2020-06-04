/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

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

public:
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
    CallStatusDeclined = int(linphone::Call::Status::Declined),
    CallStatusMissed = int(linphone::Call::Status::Missed),
    CallStatusSuccess = int(linphone::Call::Status::Success),
    CallStatusAborted = int(linphone::Call::Status::Aborted),
    CallStatusEarlyAborted = int(linphone::Call::Status::EarlyAborted),
    CallStatusAcceptedElsewhere = int(linphone::Call::Status::AcceptedElsewhere),
    CallStatusDeclinedElsewhere = int(linphone::Call::Status::DeclinedElsewhere)
  };
  Q_ENUM(CallStatus);

  enum MessageStatus {
    MessageStatusDelivered = int(linphone::ChatMessage::State::Delivered),
    MessageStatusDeliveredToUser = int(linphone::ChatMessage::State::DeliveredToUser),
    MessageStatusDisplayed = int(linphone::ChatMessage::State::Displayed),
    MessageStatusFileTransferDone = int(linphone::ChatMessage::State::FileTransferDone),
    MessageStatusFileTransferError = int(linphone::ChatMessage::State::FileTransferError),
    MessageStatusFileTransferInProgress = int(linphone::ChatMessage::State::FileTransferInProgress),
    MessageStatusIdle = int(linphone::ChatMessage::State::Idle),
    MessageStatusInProgress = int(linphone::ChatMessage::State::InProgress),
    MessageStatusNotDelivered = int(linphone::ChatMessage::State::NotDelivered)
    
  };
  Q_ENUM(MessageStatus);

  ChatModel (const QString &peerAddress, const QString &localAddress);
  ~ChatModel ();

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role) const override;

  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  QString getPeerAddress () const;
  QString getLocalAddress () const;
  QString getFullPeerAddress () const;
  QString getFullLocalAddress () const;

  bool getIsRemoteComposing () const;

  void removeEntry (int id);
  void removeAllEntries ();

  void sendMessage (const QString &message);

  void resendMessage (int id);

  void sendFileMessage (const QString &path);

  void downloadFile (int id);
  void openFile (int id, bool showDirectory = false);
  void openFileDirectory (int id) {
    openFile(id, true);
  }

  bool fileWasDownloaded (int id);

  void compose ();

  void resetMessageCount ();

signals:
  bool isRemoteComposingChanged (bool status);

  void allEntriesRemoved ();
  void lastEntryRemoved ();

  void messageSent (const std::shared_ptr<linphone::ChatMessage> &message);
  void messageReceived (const std::shared_ptr<linphone::ChatMessage> &message);

  void messageCountReset ();

  void focused ();

private:
  typedef QPair<QVariantMap, std::shared_ptr<void>> ChatEntryData;

  void setSipAddresses (const QString &peerAddress, const QString &localAddress);

  const ChatEntryData getFileMessageEntry (int id);

  void removeEntry (ChatEntryData &entry);

  void insertCall (const std::shared_ptr<linphone::CallLog> &callLog);
  void insertMessageAtEnd (const std::shared_ptr<linphone::ChatMessage> &message);

  void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);
  void handleIsComposingChanged (const std::shared_ptr<linphone::ChatRoom> &chatRoom);
  void handleMessageReceived (const std::shared_ptr<linphone::ChatMessage> &message);

  bool mIsRemoteComposing = false;

  mutable QList<ChatEntryData> mEntries;
  std::shared_ptr<linphone::ChatRoom> mChatRoom;

  std::shared_ptr<CoreHandlers> mCoreHandlers;
  std::shared_ptr<MessageHandlers> mMessageHandlers;
};

#endif // CHAT_MODEL_H_
