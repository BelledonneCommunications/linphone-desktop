/*
 * ChatModel.cpp
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

#include <algorithm>

#include <QDateTime>
#include <QFileDialog>
#include <QFileInfo>
#include <QImage>
#include <QtDebug>
#include <QTimer>
#include <QUuid>

#include "../../app/App.hpp"
#include "../../app/paths/Paths.hpp"
#include "../../app/providers/ThumbnailProvider.hpp"
#include "../../Utils.hpp"
#include "../core/CoreManager.hpp"

#include "ChatModel.hpp"

#define THUMBNAIL_IMAGE_FILE_HEIGHT 100
#define THUMBNAIL_IMAGE_FILE_WIDTH 100

// In Bytes.
#define FILE_SIZE_LIMIT 524288000

using namespace std;

// =============================================================================

inline void fillThumbnailProperty (QVariantMap &dest, const shared_ptr<linphone::ChatMessage> &message) {
  string fileId = message->getAppdata();
  if (!fileId.empty() && !dest.contains("thumbnail"))
    dest["thumbnail"] = QStringLiteral("image://%1/%2")
      .arg(ThumbnailProvider::PROVIDER_ID).arg(::Utils::linphoneStringToQString(fileId));
}

inline void createThumbnail (const shared_ptr<linphone::ChatMessage> &message) {
  if (!message->getAppdata().empty())
    return;

  QString thumbnailPath = ::Utils::linphoneStringToQString(message->getFileTransferFilepath());

  QImage image(thumbnailPath);
  if (image.isNull())
    return;

  QImage thumbnail = image.scaled(
      THUMBNAIL_IMAGE_FILE_WIDTH, THUMBNAIL_IMAGE_FILE_HEIGHT,
      Qt::KeepAspectRatio, Qt::SmoothTransformation
    );

  QString uuid = QUuid::createUuid().toString();
  QString fileId = QStringLiteral("%1.jpg").arg(uuid.mid(1, uuid.length() - 2));

  if (!thumbnail.save(::Utils::linphoneStringToQString(Paths::getThumbnailsDirPath()) + fileId, "jpg", 100)) {
    qWarning() << QStringLiteral("Unable to create thumbnail of: `%1`.").arg(thumbnailPath);
    return;
  }

  message->setAppdata(::Utils::qStringToLinphoneString(fileId));
}

inline void removeFileMessageThumbnail (const shared_ptr<linphone::ChatMessage> &message) {
  if (message && message->getFileTransferInformation()) {
    message->cancelFileTransfer();

    string fileId = message->getAppdata();
    if (!fileId.empty()) {
      QString thumbnailPath = ::Utils::linphoneStringToQString(Paths::getThumbnailsDirPath() + fileId);
      if (!QFile::remove(thumbnailPath))
        qWarning() << QStringLiteral("Unable to remove `%1`.").arg(thumbnailPath);
    }
  }
}

// -----------------------------------------------------------------------------

class ChatModel::MessageHandlers : public linphone::ChatMessageListener {
  friend class ChatModel;

public:
  MessageHandlers (ChatModel *chatModel) : mChatModel(chatModel) {}

  ~MessageHandlers () = default;

private:
  QList<ChatEntryData>::iterator findMessageEntry (const shared_ptr<linphone::ChatMessage> &message) {
    return find_if(
      mChatModel->mEntries.begin(), mChatModel->mEntries.end(), [&message](const ChatEntryData &pair) {
        return pair.second == message;
      }
    );
  }

  void signalDataChanged (const QList<ChatEntryData>::iterator &it) {
    int row = static_cast<int>(distance(mChatModel->mEntries.begin(), it));
    emit mChatModel->dataChanged(mChatModel->index(row, 0), mChatModel->index(row, 0));
  }

  shared_ptr<linphone::Buffer> onFileTransferSend (
    const shared_ptr<linphone::ChatMessage> &,
    const shared_ptr<const linphone::Content> &,
    size_t,
    size_t
  ) override {
    qWarning() << "`onFileTransferSend` called.";
    return nullptr;
  }

  void onFileTransferProgressIndication (
    const shared_ptr<linphone::ChatMessage> &message,
    const shared_ptr<const linphone::Content> &,
    size_t offset,
    size_t
  ) override {
    if (!mChatModel)
      return;

    auto it = findMessageEntry(message);
    if (it == mChatModel->mEntries.end())
      return;

    (*it).first["fileOffset"] = static_cast<quint64>(offset);

    signalDataChanged(it);
  }

  void onMsgStateChanged (const shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessageState state) override {
    if (!mChatModel)
      return;

    auto it = findMessageEntry(message);
    if (it == mChatModel->mEntries.end())
      return;

    // File message downloaded.
    if (state == linphone::ChatMessageStateFileTransferDone && !message->isOutgoing()) {
      createThumbnail(message);
      fillThumbnailProperty((*it).first, message);
      App::getInstance()->getNotifier()->notifyReceivedFileMessage(message);
    }

    (*it).first["status"] = state;

    signalDataChanged(it);
  }

  ChatModel *mChatModel;
};

// -----------------------------------------------------------------------------

ChatModel::ChatModel (QObject *parent) : QAbstractListModel(parent) {
  CoreManager *core = CoreManager::getInstance();

  mCoreHandlers = core->getHandlers();
  mMessageHandlers = make_shared<MessageHandlers>(this);

  core->getSipAddressesModel()->connectToChatModel(this);

  QObject::connect(&(*mCoreHandlers), &CoreHandlers::messageReceived, this, &ChatModel::handleMessageReceived);
  QObject::connect(&(*mCoreHandlers), &CoreHandlers::callStateChanged, this, &ChatModel::handleCallStateChanged);
}

ChatModel::~ChatModel () {
  mMessageHandlers->mChatModel = nullptr;
}

QHash<int, QByteArray> ChatModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Roles::ChatEntry] = "$chatEntry";
  roles[Roles::SectionDate] = "$sectionDate";
  return roles;
}

int ChatModel::rowCount (const QModelIndex &) const {
  return mEntries.count();
}

QVariant ChatModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mEntries.count())
    return QVariant();

  switch (role) {
    case Roles::ChatEntry:
      return QVariant::fromValue(mEntries[row].first);
    case Roles::SectionDate:
      return QVariant::fromValue(mEntries[row].first["timestamp"].toDate());
  }

  return QVariant();
}

bool ChatModel::removeRow (int row, const QModelIndex &) {
  return removeRows(row, 1);
}

bool ChatModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= mEntries.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i) {
    removeEntry(mEntries[row]);
    mEntries.removeAt(row);
  }

  endRemoveRows();

  if (mEntries.count() == 0)
    emit allEntriesRemoved();

  return true;
}

QString ChatModel::getSipAddress () const {
  if (!mChatRoom)
    return "";

  return ::Utils::linphoneStringToQString(
    mChatRoom->getPeerAddress()->asStringUriOnly()
  );
}

void ChatModel::setSipAddress (const QString &sipAddress) {
  if (sipAddress == getSipAddress() || sipAddress.isEmpty())
    return;

  beginResetModel();

  // Invalid old sip address entries.
  mEntries.clear();

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  mChatRoom = core->getChatRoomFromUri(::Utils::qStringToLinphoneString(sipAddress));

  if (mChatRoom->getUnreadMessagesCount() > 0)
    resetMessagesCount();

  // Get messages.
  for (auto &message : mChatRoom->getHistory(0)) {
    QVariantMap map;

    fillMessageEntry(map, message);

    // TODO: Remove me in a future linphone core version.
    if (message->getState() == linphone::ChatMessageStateInProgress)
      map["status"] = linphone::ChatMessageStateNotDelivered;

    mEntries << qMakePair(map, static_pointer_cast<void>(message));
  }

  // Get calls.
  for (auto &callLog : core->getCallHistoryForAddress(mChatRoom->getPeerAddress()))
    insertCall(callLog);

  endResetModel();

  emit sipAddressChanged(sipAddress);
}

// -----------------------------------------------------------------------------

void ChatModel::removeEntry (int id) {
  qInfo() << QStringLiteral("Removing chat entry: %1 of %2.")
    .arg(id).arg(getSipAddress());

  if (!removeRow(id))
    qWarning() << QStringLiteral("Unable to remove chat entry: %1").arg(id);
}

void ChatModel::removeAllEntries () {
  qInfo() << QStringLiteral("Removing all chat entries of: %1.").arg(getSipAddress());

  beginResetModel();

  for (auto &entry : mEntries)
    removeEntry(entry);

  mEntries.clear();

  endResetModel();

  emit allEntriesRemoved();
}

void ChatModel::sendMessage (const QString &message) {
  if (!mChatRoom)
    return;

  shared_ptr<linphone::ChatMessage> _message = mChatRoom->createMessage(::Utils::qStringToLinphoneString(message));
  _message->setListener(mMessageHandlers);

  insertMessageAtEnd(_message);
  mChatRoom->sendChatMessage(_message);

  emit messageSent(_message);
}

void ChatModel::resendMessage (int id) {
  if (!mChatRoom)
    return;

  if (id < 0 || id > mEntries.count()) {
    qWarning() << QStringLiteral("Entry %1 not exists.").arg(id);
    return;
  }

  const ChatEntryData &entry = mEntries[id];
  const QVariantMap &map = entry.first;

  if (map["type"] != EntryType::MessageEntry) {
    qWarning() << QStringLiteral("Unable to resend entry %1. It's not a message.").arg(id);
    return;
  }

  switch (map["status"].toInt()) {
    case MessageStatusFileTransferError:
    case MessageStatusNotDelivered: {
      // TODO: Do not duplicate me! Use a linphone core function in the future.
      shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);

      shared_ptr<linphone::ChatMessage> message2 = message->clone();
      message2->setListener(mMessageHandlers);
      mChatRoom->sendChatMessage(message2);

      removeEntry(id);
      insertMessageAtEnd(message2);

      break;
    }

    default:
      qWarning() << QStringLiteral("Unable to resend message: %1. Bad state.").arg(id);
  }
}

void ChatModel::sendFileMessage (const QString &path) {
  if (!mChatRoom)
    return;

  QFile file(path);
  if (!file.exists())
    return;

  qint64 fileSize = file.size();
  if (fileSize > FILE_SIZE_LIMIT) {
    qWarning() << QStringLiteral("Unable to send file. (Size limit=%1)").arg(FILE_SIZE_LIMIT);
    return;
  }

  shared_ptr<linphone::Content> content = CoreManager::getInstance()->getCore()->createContent();
  content->setType("application");
  content->setSubtype("octet-stream");

  content->setSize(static_cast<size_t>(fileSize));
  content->setName(::Utils::qStringToLinphoneString(QFileInfo(file).fileName()));

  shared_ptr<linphone::ChatMessage> message = mChatRoom->createFileTransferMessage(content);
  message->setFileTransferFilepath(::Utils::qStringToLinphoneString(path));
  message->setListener(mMessageHandlers);

  createThumbnail(message);

  insertMessageAtEnd(message);
  mChatRoom->sendChatMessage(message);

  emit messageSent(message);
}

void ChatModel::downloadFile (int id, const QString &downloadPath) {
  if (!mChatRoom)
    return;

  if (id < 0 || id > mEntries.count()) {
    qWarning() << QStringLiteral("Entry %1 not exists.").arg(id);
    return;
  }

  const ChatEntryData &entry = mEntries[id];
  if (entry.first["type"] != EntryType::MessageEntry) {
    qWarning() << QStringLiteral("Unable to download entry %1. It's not a message.").arg(id);
    return;
  }

  shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);
  if (!message->getFileTransferInformation()) {
    qWarning() << QStringLiteral("Entry %1 is not a file message.").arg(id);
    return;
  }

  switch (message->getState()) {
    case MessageStatusDelivered:
    case MessageStatusDeliveredToUser:
    case MessageStatusDisplayed:
    case MessageStatusFileTransferDone:
      break;

    default:
      qWarning() << QStringLiteral("Unable to download file of entry %1. It was not uploaded.").arg(id);
      return;
  }

  message->setFileTransferFilepath(
    ::Utils::qStringToLinphoneString(downloadPath.startsWith("file://")
      ? downloadPath.mid(sizeof("file://") - 1)
      : downloadPath
    )
  );
  message->setListener(mMessageHandlers);

  if (message->downloadFile() < 0)
    qWarning() << QStringLiteral("Unable to download file of entry %1.").arg(id);
}

// -----------------------------------------------------------------------------

void ChatModel::fillMessageEntry (QVariantMap &dest, const shared_ptr<linphone::ChatMessage> &message) {
  dest["type"] = EntryType::MessageEntry;
  dest["timestamp"] = QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000);
  dest["content"] = ::Utils::linphoneStringToQString(message->getText());
  dest["isOutgoing"] = message->isOutgoing() || message->getState() == linphone::ChatMessageStateIdle;
  dest["status"] = message->getState();

  shared_ptr<const linphone::Content> content = message->getFileTransferInformation();
  if (content) {
    dest["fileSize"] = static_cast<quint64>(content->getSize());
    dest["fileName"] = ::Utils::linphoneStringToQString(content->getName());
    fillThumbnailProperty(dest, message);
  }
}

void ChatModel::fillCallStartEntry (QVariantMap &dest, const shared_ptr<linphone::CallLog> &callLog) {
  QDateTime timestamp = QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);

  dest["type"] = EntryType::CallEntry;
  dest["timestamp"] = timestamp;
  dest["isOutgoing"] = callLog->getDir() == linphone::CallDirOutgoing;
  dest["status"] = callLog->getStatus();
  dest["isStart"] = true;
}

void ChatModel::fillCallEndEntry (QVariantMap &dest, const shared_ptr<linphone::CallLog> &callLog) {
  QDateTime timestamp = QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000);

  dest["type"] = EntryType::CallEntry;
  dest["timestamp"] = timestamp;
  dest["isOutgoing"] = callLog->getDir() == linphone::CallDirOutgoing;
  dest["status"] = callLog->getStatus();
  dest["isStart"] = false;
}

// -----------------------------------------------------------------------------

void ChatModel::removeEntry (ChatEntryData &pair) {
  int type = pair.first["type"].toInt();

  switch (type) {
    case ChatModel::MessageEntry: {
      shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(pair.second);
      removeFileMessageThumbnail(message);
      mChatRoom->deleteMessage(message);
      break;
    }

    case ChatModel::CallEntry: {
      if (pair.first["status"].toInt() == linphone::CallStatusSuccess) {
        // WARNING: Unable to remove symmetric call here. (start/end)
        // We are between `beginRemoveRows` and `endRemoveRows`.
        // A solution is to schedule a `removeEntry` call in the Qt main loop.
        shared_ptr<void> linphonePtr = pair.second;
        QTimer::singleShot(
          0, this, [this, linphonePtr]() {
            auto it = find_if(mEntries.begin(), mEntries.end(), [linphonePtr](const ChatEntryData &pair) {
                  return pair.second == linphonePtr;
                });

            if (it != mEntries.end())
              removeEntry(static_cast<int>(distance(mEntries.begin(), it)));
          }
        );
      }

      CoreManager::getInstance()->getCore()->removeCallLog(static_pointer_cast<linphone::CallLog>(pair.second));
      break;
    }

    default:
      qWarning() << QStringLiteral("Unknown chat entry type: %1.").arg(type);
  }
}

void ChatModel::insertCall (const shared_ptr<linphone::CallLog> &callLog) {
  auto insertEntry = [this](
      const ChatEntryData &pair,
      const QList<ChatEntryData>::iterator *start = NULL
    ) {
      auto it = lower_bound(
          start ? *start : mEntries.begin(), mEntries.end(), pair,
          [](const ChatEntryData &a, const ChatEntryData &b) {
            return a.first["timestamp"] < b.first["timestamp"];
          }
        );

      int row = static_cast<int>(distance(mEntries.begin(), it));

      beginInsertRows(QModelIndex(), row, row);
      it = mEntries.insert(it, pair);
      endInsertRows();

      return it;
    };

  linphone::CallStatus status = callLog->getStatus();

  // Ignore aborted calls.
  if (status == linphone::CallStatusAborted)
    return;

  // Add start call.
  QVariantMap start;
  fillCallStartEntry(start, callLog);
  auto it = insertEntry(qMakePair(start, static_pointer_cast<void>(callLog)));

  // Add end call. (if necessary)
  if (status == linphone::CallStatusSuccess) {
    QVariantMap end;
    fillCallEndEntry(end, callLog);
    insertEntry(qMakePair(end, static_pointer_cast<void>(callLog)), &it);
  }
}

void ChatModel::insertMessageAtEnd (const shared_ptr<linphone::ChatMessage> &message) {
  int row = mEntries.count();

  beginInsertRows(QModelIndex(), row, row);

  QVariantMap map;
  fillMessageEntry(map, message);
  mEntries << qMakePair(map, static_pointer_cast<void>(message));

  endInsertRows();
}

void ChatModel::resetMessagesCount () {
  mChatRoom->markAsRead();
  emit messagesCountReset();
}

// -----------------------------------------------------------------------------

void ChatModel::handleCallStateChanged (const shared_ptr<linphone::Call> &call, linphone::CallState state) {
  if (
    (state == linphone::CallStateEnd || state == linphone::CallStateError) &&
    mChatRoom == CoreManager::getInstance()->getCore()->getChatRoom(call->getRemoteAddress())
  )
    insertCall(call->getCallLog());
}

void ChatModel::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &message) {
  if (mChatRoom == message->getChatRoom()) {
    insertMessageAtEnd(message);
    resetMessagesCount();

    emit messageReceived(message);
  }
}
