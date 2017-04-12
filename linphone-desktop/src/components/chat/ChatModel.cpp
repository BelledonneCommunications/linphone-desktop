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
#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "ChatModel.hpp"

#define THUMBNAIL_IMAGE_FILE_HEIGHT 100
#define THUMBNAIL_IMAGE_FILE_WIDTH 100

using namespace std;

// =============================================================================

inline void fillThumbnailProperty (QVariantMap &dest, const shared_ptr<linphone::ChatMessage> &message) {
  string file_id = message->getAppdata();
  if (!file_id.empty() && !dest.contains("thumbnail"))
    dest["thumbnail"] = QStringLiteral("image://%1/%2")
      .arg(ThumbnailProvider::PROVIDER_ID).arg(::Utils::linphoneStringToQString(file_id));
}

inline void createThumbnail (const shared_ptr<linphone::ChatMessage> &message) {
  if (!message->getAppdata().empty())
    return;

  QString thumbnail_path = ::Utils::linphoneStringToQString(message->getFileTransferFilepath());

  QImage image(thumbnail_path);
  if (image.isNull())
    return;

  QImage thumbnail = image.scaled(
      THUMBNAIL_IMAGE_FILE_WIDTH, THUMBNAIL_IMAGE_FILE_HEIGHT,
      Qt::KeepAspectRatio, Qt::SmoothTransformation
    );

  QString uuid = QUuid::createUuid().toString();
  QString file_id = QStringLiteral("%1.jpg").arg(uuid.mid(1, uuid.length() - 2));

  if (!thumbnail.save(::Utils::linphoneStringToQString(Paths::getThumbnailsDirpath()) + file_id, "jpg", 100)) {
    qWarning() << QStringLiteral("Unable to create thumbnail of: `%1`.").arg(thumbnail_path);
    return;
  }

  message->setAppdata(::Utils::qStringToLinphoneString(file_id));
}

inline void removeFileMessageThumbnail (const shared_ptr<linphone::ChatMessage> &message) {
  if (message && message->getFileTransferInformation()) {
    message->cancelFileTransfer();

    string file_id = message->getAppdata();
    if (!file_id.empty()) {
      QString thumbnail_path = ::Utils::linphoneStringToQString(Paths::getThumbnailsDirpath() + file_id);
      if (!QFile::remove(thumbnail_path))
        qWarning() << QStringLiteral("Unable to remove `%1`.").arg(thumbnail_path);
    }
  }
}

// -----------------------------------------------------------------------------

class ChatModel::MessageHandlers : public linphone::ChatMessageListener {
  friend class ChatModel;

public:
  MessageHandlers (ChatModel *chat_model) : m_chat_model(chat_model) {}

  ~MessageHandlers () = default;

private:
  QList<ChatEntryData>::iterator findMessageEntry (const shared_ptr<linphone::ChatMessage> &message) {
    return find_if(
      m_chat_model->m_entries.begin(), m_chat_model->m_entries.end(), [&message](const ChatEntryData &pair) {
        return pair.second == message;
      }
    );
  }

  void signalDataChanged (const QList<ChatEntryData>::iterator &it) {
    int row = static_cast<int>(distance(m_chat_model->m_entries.begin(), it));
    emit m_chat_model->dataChanged(m_chat_model->index(row, 0), m_chat_model->index(row, 0));
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
    if (!m_chat_model)
      return;

    auto it = findMessageEntry(message);
    if (it == m_chat_model->m_entries.end())
      return;

    (*it).first["fileOffset"] = static_cast<quint64>(offset);

    signalDataChanged(it);
  }

  void onMsgStateChanged (const shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessageState state) override {
    if (!m_chat_model)
      return;

    auto it = findMessageEntry(message);
    if (it == m_chat_model->m_entries.end())
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

  ChatModel *m_chat_model;
};

// -----------------------------------------------------------------------------

ChatModel::ChatModel (QObject *parent) : QAbstractListModel(parent) {
  CoreManager *core = CoreManager::getInstance();

  m_core_handlers = core->getHandlers();
  m_message_handlers = make_shared<MessageHandlers>(this);

  core->getSipAddressesModel()->connectToChatModel(this);

  QObject::connect(&(*m_core_handlers), &CoreHandlers::messageReceived, this, &ChatModel::handleMessageReceived);
  QObject::connect(&(*m_core_handlers), &CoreHandlers::callStateChanged, this, &ChatModel::handleCallStateChanged);
}

ChatModel::~ChatModel () {
  m_message_handlers->m_chat_model = nullptr;
}

QHash<int, QByteArray> ChatModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Roles::ChatEntry] = "$chatEntry";
  roles[Roles::SectionDate] = "$sectionDate";
  return roles;
}

int ChatModel::rowCount (const QModelIndex &) const {
  return m_entries.count();
}

QVariant ChatModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= m_entries.count())
    return QVariant();

  switch (role) {
    case Roles::ChatEntry:
      return QVariant::fromValue(m_entries[row].first);
    case Roles::SectionDate:
      return QVariant::fromValue(m_entries[row].first["timestamp"].toDate());
  }

  return QVariant();
}

bool ChatModel::removeRow (int row, const QModelIndex &) {
  return removeRows(row, 1);
}

bool ChatModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= m_entries.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i) {
    removeEntry(m_entries[row]);
    m_entries.removeAt(row);
  }

  endRemoveRows();

  if (m_entries.count() == 0)
    emit allEntriesRemoved();

  return true;
}

QString ChatModel::getSipAddress () const {
  if (!m_chat_room)
    return "";

  return ::Utils::linphoneStringToQString(
    m_chat_room->getPeerAddress()->asStringUriOnly()
  );
}

void ChatModel::setSipAddress (const QString &sip_address) {
  if (sip_address == getSipAddress() || sip_address.isEmpty())
    return;

  beginResetModel();

  // Invalid old sip address entries.
  m_entries.clear();

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  m_chat_room = core->getChatRoomFromUri(::Utils::qStringToLinphoneString(sip_address));

  if (m_chat_room->getUnreadMessagesCount() > 0)
    resetMessagesCount();

  // Get messages.
  for (auto &message : m_chat_room->getHistory(0)) {
    QVariantMap map;

    fillMessageEntry(map, message);

    // TODO: Remove me in a future linphone core version.
    if (message->getState() == linphone::ChatMessageStateInProgress)
      map["status"] = linphone::ChatMessageStateNotDelivered;

    m_entries << qMakePair(map, static_pointer_cast<void>(message));
  }

  // Get calls.
  for (auto &call_log : core->getCallHistoryForAddress(m_chat_room->getPeerAddress()))
    insertCall(call_log);

  endResetModel();

  emit sipAddressChanged(sip_address);
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

  for (auto &entry : m_entries)
    removeEntry(entry);

  m_entries.clear();

  endResetModel();

  emit allEntriesRemoved();
}

void ChatModel::sendMessage (const QString &message) {
  if (!m_chat_room)
    return;

  shared_ptr<linphone::ChatMessage> _message = m_chat_room->createMessage(::Utils::qStringToLinphoneString(message));
  _message->setListener(m_message_handlers);

  insertMessageAtEnd(_message);
  m_chat_room->sendChatMessage(_message);

  emit messageSent(_message);
}

void ChatModel::resendMessage (int id) {
  if (!m_chat_room)
    return;

  if (id < 0 || id > m_entries.count()) {
    qWarning() << QStringLiteral("Entry %1 not exists.").arg(id);
    return;
  }

  const ChatEntryData &entry = m_entries[id];
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
      message2->setListener(m_message_handlers);
      m_chat_room->sendChatMessage(message2);

      removeEntry(id);
      insertMessageAtEnd(message2);

      break;
    }

    default:
      qWarning() << QStringLiteral("Unable to resend message: %1. Bad state.").arg(id);
  }
}

void ChatModel::sendFileMessage (const QString &path) {
  if (!m_chat_room)
    return;

  QFile file(path);
  if (!file.exists())
    return;

  shared_ptr<linphone::Content> content = CoreManager::getInstance()->getCore()->createContent();
  content->setType("application");
  content->setSubtype("octet-stream");
  content->setSize(file.size());
  content->setName(::Utils::qStringToLinphoneString(QFileInfo(file).fileName()));

  shared_ptr<linphone::ChatMessage> message = m_chat_room->createFileTransferMessage(content);
  message->setFileTransferFilepath(::Utils::qStringToLinphoneString(path));
  message->setListener(m_message_handlers);

  createThumbnail(message);

  insertMessageAtEnd(message);
  m_chat_room->sendChatMessage(message);

  emit messageSent(message);
}

void ChatModel::downloadFile (int id, const QString &download_path) {
  if (!m_chat_room)
    return;

  if (id < 0 || id > m_entries.count()) {
    qWarning() << QStringLiteral("Entry %1 not exists.").arg(id);
    return;
  }

  const ChatEntryData &entry = m_entries[id];
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
    ::Utils::qStringToLinphoneString(download_path.startsWith("file://")
      ? download_path.mid(sizeof("file://") - 1)
      : download_path
    )
  );
  message->setListener(m_message_handlers);

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

void ChatModel::fillCallStartEntry (QVariantMap &dest, const shared_ptr<linphone::CallLog> &call_log) {
  QDateTime timestamp = QDateTime::fromMSecsSinceEpoch(call_log->getStartDate() * 1000);

  dest["type"] = EntryType::CallEntry;
  dest["timestamp"] = timestamp;
  dest["isOutgoing"] = call_log->getDir() == linphone::CallDirOutgoing;
  dest["status"] = call_log->getStatus();
  dest["isStart"] = true;
}

void ChatModel::fillCallEndEntry (QVariantMap &dest, const shared_ptr<linphone::CallLog> &call_log) {
  QDateTime timestamp = QDateTime::fromMSecsSinceEpoch((call_log->getStartDate() + call_log->getDuration()) * 1000);

  dest["type"] = EntryType::CallEntry;
  dest["timestamp"] = timestamp;
  dest["isOutgoing"] = call_log->getDir() == linphone::CallDirOutgoing;
  dest["status"] = call_log->getStatus();
  dest["isStart"] = false;
}

// -----------------------------------------------------------------------------

void ChatModel::removeEntry (ChatEntryData &pair) {
  int type = pair.first["type"].toInt();

  switch (type) {
    case ChatModel::MessageEntry: {
      shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(pair.second);
      removeFileMessageThumbnail(message);
      m_chat_room->deleteMessage(message);
      break;
    }

    case ChatModel::CallEntry: {
      if (pair.first["status"].toInt() == linphone::CallStatusSuccess) {
        // WARNING: Unable to remove symmetric call here. (start/end)
        // We are between `beginRemoveRows` and `endRemoveRows`.
        // A solution is to schedule a `removeEntry` call in the Qt main loop.
        shared_ptr<void> linphone_ptr = pair.second;
        QTimer::singleShot(
          0, this, [this, linphone_ptr]() {
            auto it = find_if(m_entries.begin(), m_entries.end(), [linphone_ptr](const ChatEntryData &pair) {
                  return pair.second == linphone_ptr;
                });

            if (it != m_entries.end())
              removeEntry(static_cast<int>(distance(m_entries.begin(), it)));
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

void ChatModel::insertCall (const shared_ptr<linphone::CallLog> &call_log) {
  auto insert_entry = [this](
      const ChatEntryData &pair,
      const QList<ChatEntryData>::iterator *start = NULL
    ) {
      auto it = lower_bound(
          start ? *start : m_entries.begin(), m_entries.end(), pair,
          [](const ChatEntryData &a, const ChatEntryData &b) {
            return a.first["timestamp"] < b.first["timestamp"];
          }
        );

      int row = static_cast<int>(distance(m_entries.begin(), it));

      beginInsertRows(QModelIndex(), row, row);
      it = m_entries.insert(it, pair);
      endInsertRows();

      return it;
    };

  linphone::CallStatus status = call_log->getStatus();

  // Ignore aborted calls.
  if (status == linphone::CallStatusAborted)
    return;

  // Add start call.
  QVariantMap start;
  fillCallStartEntry(start, call_log);
  auto it = insert_entry(qMakePair(start, static_pointer_cast<void>(call_log)));

  // Add end call. (if necessary)
  if (status == linphone::CallStatusSuccess) {
    QVariantMap end;
    fillCallEndEntry(end, call_log);
    insert_entry(qMakePair(end, static_pointer_cast<void>(call_log)), &it);
  }
}

void ChatModel::insertMessageAtEnd (const shared_ptr<linphone::ChatMessage> &message) {
  int row = m_entries.count();

  beginInsertRows(QModelIndex(), row, row);

  QVariantMap map;
  fillMessageEntry(map, message);
  m_entries << qMakePair(map, static_pointer_cast<void>(message));

  endInsertRows();
}

void ChatModel::resetMessagesCount () {
  m_chat_room->markAsRead();
  emit messagesCountReset();
}

// -----------------------------------------------------------------------------

void ChatModel::handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::CallState state) {
  if (m_chat_room == call->getChatRoom() && (state == linphone::CallStateEnd || state == linphone::CallStateError))
    insertCall(call->getCallLog());
}

void ChatModel::handleMessageReceived (const std::shared_ptr<linphone::ChatMessage> &message) {
  if (m_chat_room == message->getChatRoom()) {
    insertMessageAtEnd(message);
    resetMessagesCount();

    emit messageReceived(message);
  }
}
