/*
 * ChatModel.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
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
    CallStatusDeclined = linphone::CallStatusDeclined,
    CallStatusMissed = linphone::CallStatusMissed,
    CallStatusSuccess = linphone::CallStatusSuccess
  };

  Q_ENUM(CallStatus);

  enum MessageStatus {
    MessageStatusDelivered = linphone::ChatMessageStateDelivered,
    MessageStatusDeliveredToUser = linphone::ChatMessageStateDeliveredToUser,
    MessageStatusDisplayed = linphone::ChatMessageStateDisplayed,
    MessageStatusFileTransferDone = linphone::ChatMessageStateFileTransferDone,
    MessageStatusFileTransferError = linphone::ChatMessageStateFileTransferError,
    MessageStatusIdle = linphone::ChatMessageStateIdle,
    MessageStatusInProgress = linphone::ChatMessageStateInProgress,
    MessageStatusNotDelivered = linphone::ChatMessageStateNotDelivered
  };

  Q_ENUM(MessageStatus);

  ChatModel (const QString &sipAddress);
  ~ChatModel ();

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role) const override;

  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  QString getSipAddress () const;

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

  void resetMessagesCount ();

signals:
  bool isRemoteComposingChanged (bool status);

  void allEntriesRemoved ();

  void messageSent (const std::shared_ptr<linphone::ChatMessage> &message);
  void messageReceived (const std::shared_ptr<linphone::ChatMessage> &message);

  void messagesCountReset ();

private:
  typedef QPair<QVariantMap, std::shared_ptr<void> > ChatEntryData;

  void setSipAddress (const QString &sipAddress);

  const ChatEntryData getFileMessageEntry (int id);

  void fillMessageEntry (QVariantMap &dest, const std::shared_ptr<linphone::ChatMessage> &message);
  void fillCallStartEntry (QVariantMap &dest, const std::shared_ptr<linphone::CallLog> &callLog);
  void fillCallEndEntry (QVariantMap &dest, const std::shared_ptr<linphone::CallLog> &callLog);

  void removeEntry (ChatEntryData &pair);

  void insertCall (const std::shared_ptr<linphone::CallLog> &callLog);
  void insertMessageAtEnd (const std::shared_ptr<linphone::ChatMessage> &message);

  void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::CallState state);
  void handleIsComposingChanged (const std::shared_ptr<linphone::ChatRoom> &chatRoom);
  void handleMessageReceived (const std::shared_ptr<linphone::ChatMessage> &message);

  bool mIsRemoteComposing = false;

  QList<ChatEntryData> mEntries;
  std::shared_ptr<linphone::ChatRoom> mChatRoom;

  std::shared_ptr<CoreHandlers> mCoreHandlers;
  std::shared_ptr<MessageHandlers> mMessageHandlers;
};

#endif // CHAT_MODEL_H_
