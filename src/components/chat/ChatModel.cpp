/*
 * ChatModel.cpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
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
#include <QDesktopServices>
#include <QElapsedTimer>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QTimer>
#include <QUuid>

#include "app/App.hpp"
#include "app/paths/Paths.hpp"
#include "app/providers/ThumbnailProvider.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/QExifImageHeader.hpp"
#include "utils/Utils.hpp"

#include "ChatModel.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr int ThumbnailImageFileWidth = 100;
  constexpr int ThumbnailImageFileHeight = 100;

  // In Bytes.
  constexpr qint64 FileSizeLimit = 524288000;
}

static inline QString getFileId (const shared_ptr<linphone::ChatMessage> &message) {
  return Utils::coreStringToAppString(message->getAppdata()).section(':', 0, 0);
}

static inline QString getDownloadPath (const shared_ptr<linphone::ChatMessage> &message) {
  return Utils::coreStringToAppString(message->getAppdata()).section(':', 1);
}

static inline bool fileWasDownloaded (const shared_ptr<linphone::ChatMessage> &message) {
  const QString path = getDownloadPath(message);
  return !path.isEmpty() && QFileInfo(path).isFile();
}

static inline void fillThumbnailProperty (QVariantMap &dest, const shared_ptr<linphone::ChatMessage> &message) {
  QString fileId = getFileId(message);
  if (!fileId.isEmpty() && !dest.contains("thumbnail"))
    dest["thumbnail"] = QStringLiteral("image://%1/%2")
      .arg(ThumbnailProvider::ProviderId).arg(fileId);
}

static inline void createThumbnail (const shared_ptr<linphone::ChatMessage> &message) {
  if (!message->getAppdata().empty())
    return;

  QString thumbnailPath = Utils::coreStringToAppString(message->getFileTransferFilepath());
  QImage image(thumbnailPath);
  if (image.isNull())
    return;

  int rotation = 0;
  QExifImageHeader exifImageHeader;
  if (exifImageHeader.loadFromJpeg(thumbnailPath))
    rotation = int(exifImageHeader.value(QExifImageHeader::ImageTag::Orientation).toShort());

  QImage thumbnail = image.scaled(
    ThumbnailImageFileWidth, ThumbnailImageFileHeight,
    Qt::KeepAspectRatio, Qt::SmoothTransformation
  );

  if (rotation != 0) {
    QTransform transform;
    if (rotation == 3 || rotation == 4)
      transform.rotate(180);
    else if (rotation == 5 || rotation == 6)
      transform.rotate(90);
    else if (rotation == 7 || rotation == 8)
      transform.rotate(-90);

    thumbnail = thumbnail.transformed(transform);
    if (rotation == 2 || rotation == 4 || rotation == 5 || rotation == 7)
      thumbnail = thumbnail.mirrored(true, false);
  }

  QString uuid = QUuid::createUuid().toString();
  QString fileId = QStringLiteral("%1.jpg").arg(uuid.mid(1, uuid.length() - 2));

  if (!thumbnail.save(Utils::coreStringToAppString(Paths::getThumbnailsDirPath()) + fileId, "jpg", 100)) {
    qWarning() << QStringLiteral("Unable to create thumbnail of: `%1`.").arg(thumbnailPath);
    return;
  }

  message->setAppdata(Utils::appStringToCoreString(fileId));
}

static inline void removeFileMessageThumbnail (const shared_ptr<linphone::ChatMessage> &message) {
  if (message && message->getFileTransferInformation()) {
    message->cancelFileTransfer();

    string fileId = message->getAppdata();
    if (!fileId.empty()) {
      QString thumbnailPath = Utils::coreStringToAppString(Paths::getThumbnailsDirPath() + fileId);
      if (!QFile::remove(thumbnailPath))
        qWarning() << QStringLiteral("Unable to remove `%1`.").arg(thumbnailPath);
    }
  }
}

// -----------------------------------------------------------------------------

static inline void fillMessageEntry (QVariantMap &dest, const shared_ptr<linphone::ChatMessage> &message) {
  dest["content"] = Utils::coreStringToAppString(message->getText());
  dest["isOutgoing"] = message->isOutgoing() || message->getState() == linphone::ChatMessage::State::Idle;

  // Old workaround.
  // It can exist messages with a not delivered status. It's a linphone core bug.
  linphone::ChatMessage::State state = message->getState();
  if (state == linphone::ChatMessage::State::InProgress)
    dest["status"] = ChatModel::MessageStatusNotDelivered;
  else
    dest["status"] = static_cast<ChatModel::MessageStatus>(message->getState());

  shared_ptr<const linphone::Content> content = message->getFileTransferInformation();
  if (content) {
    dest["fileSize"] = quint64(content->getFileSize());
    dest["fileName"] = Utils::coreStringToAppString(content->getName());
    dest["wasDownloaded"] = ::fileWasDownloaded(message);

    fillThumbnailProperty(dest, message);
  }
}

static inline void fillCallStartEntry (QVariantMap &dest, const shared_ptr<linphone::CallLog> &callLog) {
  dest["type"] = ChatModel::CallEntry;
  dest["timestamp"] = QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
  dest["isOutgoing"] = callLog->getDir() == linphone::Call::Dir::Outgoing;
  dest["status"] = static_cast<ChatModel::CallStatus>(callLog->getStatus());
  dest["isStart"] = true;
}

static inline void fillCallEndEntry (QVariantMap &dest, const shared_ptr<linphone::CallLog> &callLog) {
  dest["type"] = ChatModel::CallEntry;
  dest["timestamp"] = QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000);
  dest["isOutgoing"] = callLog->getDir() == linphone::Call::Dir::Outgoing;
  dest["status"] = static_cast<ChatModel::CallStatus>(callLog->getStatus());
  dest["isStart"] = false;
}

// -----------------------------------------------------------------------------

class ChatModel::MessageHandlers : public linphone::ChatMessageListener {
  friend class ChatModel;

public:
  MessageHandlers (ChatModel *chatModel) : mChatModel(chatModel) {}

private:
  QList<ChatEntryData>::iterator findMessageEntry (const shared_ptr<linphone::ChatMessage> &message) {
    return find_if(mChatModel->mEntries.begin(), mChatModel->mEntries.end(), [&message](const ChatEntryData &entry) {
      return entry.second == message;
    });
  }

  void signalDataChanged (const QList<ChatEntryData>::iterator &it) {
    int row = int(distance(mChatModel->mEntries.begin(), it));
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

    (*it).first["fileOffset"] = quint64(offset);

    signalDataChanged(it);
  }

  void onMsgStateChanged (const shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state) override {
    if (!mChatModel)
      return;

    auto it = findMessageEntry(message);
    if (it == mChatModel->mEntries.end())
      return;

    // File message downloaded.
    if (state == linphone::ChatMessage::State::FileTransferDone && !message->isOutgoing()) {
      createThumbnail(message);
      fillThumbnailProperty((*it).first, message);

      message->setAppdata(
        Utils::appStringToCoreString(getFileId(message)) + ':' + message->getFileTransferFilepath()
      );
      (*it).first["wasDownloaded"] = true;

      App::getInstance()->getNotifier()->notifyReceivedFileMessage(message);
    }

    (*it).first["status"] = static_cast<MessageStatus>(state);

    signalDataChanged(it);
  }

  ChatModel *mChatModel;
};

// -----------------------------------------------------------------------------

ChatModel::ChatModel (const QString &peerAddress, const QString &localAddress) {
  CoreManager *coreManager = CoreManager::getInstance();

  mCoreHandlers = coreManager->getHandlers();
  mMessageHandlers = make_shared<MessageHandlers>(this);

  setSipAddresses(peerAddress, localAddress);

  {
    CoreHandlers *coreHandlers = mCoreHandlers.get();
    QObject::connect(coreHandlers, &CoreHandlers::messageReceived, this, &ChatModel::handleMessageReceived);
    QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &ChatModel::handleCallStateChanged);
    QObject::connect(coreHandlers, &CoreHandlers::isComposingChanged, this, &ChatModel::handleIsComposingChanged);
  }
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
    case Roles::ChatEntry: {
      auto &data = mEntries[row].first;
      if (!data.contains("status"))
        fillMessageEntry(data, static_pointer_cast<linphone::ChatMessage>(mEntries[row].second));
      return QVariant::fromValue(data);
    }
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
  else if (limit == mEntries.count())
    emit lastEntryRemoved();

  return true;
}

QString ChatModel::getPeerAddress () const {
  return Utils::coreStringToAppString(
    mChatRoom->getPeerAddress()->asStringUriOnly()
  );
}

QString ChatModel::getLocalAddress () const {
  return Utils::coreStringToAppString(
    mChatRoom->getLocalAddress()->asStringUriOnly()
  );
}

void ChatModel::setSipAddresses (const QString &peerAddress, const QString &localAddress) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Factory> factory(linphone::Factory::get());

  mChatRoom = core->getChatRoom(
    factory->createAddress(Utils::appStringToCoreString(peerAddress)),
    factory->createAddress(Utils::appStringToCoreString(localAddress))
  );
  Q_ASSERT(mChatRoom);

  handleIsComposingChanged(mChatRoom);

  // Get messages.
  mEntries.clear();

  QElapsedTimer timer;
  timer.start();

  for (auto &message : mChatRoom->getHistory(0))
    mEntries << qMakePair(
      QVariantMap{
        { "type", EntryType::MessageEntry },
        { "timestamp", QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000) }
      },
      static_pointer_cast<void>(message)
    );

  // Get calls.
  for (auto &callLog : core->getCallHistory(mChatRoom->getPeerAddress(), mChatRoom->getLocalAddress()))
    insertCall(callLog);

  qInfo() << QStringLiteral("ChatModel (%1, %2) loaded in %3 milliseconds.")
    .arg(peerAddress).arg(localAddress).arg(timer.elapsed());
}

bool ChatModel::getIsRemoteComposing () const {
  return mIsRemoteComposing;
}

// -----------------------------------------------------------------------------

void ChatModel::removeEntry (int id) {
  qInfo() << QStringLiteral("Removing chat entry: %1 of (%2, %3).")
    .arg(id).arg(getPeerAddress()).arg(getLocalAddress());

  if (!removeRow(id))
    qWarning() << QStringLiteral("Unable to remove chat entry: %1").arg(id);
}

void ChatModel::removeAllEntries () {
  qInfo() << QStringLiteral("Removing all chat entries of: (%1, %2).")
    .arg(getPeerAddress()).arg(getLocalAddress());

  beginResetModel();

  for (auto &entry : mEntries)
    removeEntry(entry);

  mEntries.clear();

  endResetModel();

  emit allEntriesRemoved();
}

// -----------------------------------------------------------------------------

void ChatModel::sendMessage (const QString &message) {
  shared_ptr<linphone::ChatMessage> _message = mChatRoom->createMessage(Utils::appStringToCoreString(message));
  _message->setListener(mMessageHandlers);

  insertMessageAtEnd(_message);
  mChatRoom->sendChatMessage(_message);

  emit messageSent(_message);
}

void ChatModel::resendMessage (int id) {
  if (id < 0 || id > mEntries.count()) {
    qWarning() << QStringLiteral("Entry %1 not exists.").arg(id);
    return;
  }

  const ChatEntryData entry = mEntries[id];
  const QVariantMap map = entry.first;

  if (map["type"] != EntryType::MessageEntry) {
    qWarning() << QStringLiteral("Unable to resend entry %1. It's not a message.").arg(id);
    return;
  }

  switch (map["status"].toInt()) {
    case MessageStatusFileTransferError:
    case MessageStatusNotDelivered: {
      shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);
      message->setListener(mMessageHandlers);
      message->resend();

      break;
    }

    default:
      qWarning() << QStringLiteral("Unable to resend message: %1. Bad state.").arg(id);
  }
}

void ChatModel::sendFileMessage (const QString &path) {
  QFile file(path);
  if (!file.exists())
    return;

  qint64 fileSize = file.size();
  if (fileSize > FileSizeLimit) {
    qWarning() << QStringLiteral("Unable to send file. (Size limit=%1)").arg(FileSizeLimit);
    return;
  }

  shared_ptr<linphone::Content> content = CoreManager::getInstance()->getCore()->createContent();
  {
    QStringList mimeType = QMimeDatabase().mimeTypeForFile(path).name().split('/');
    if (mimeType.length() != 2) {
      qWarning() << QStringLiteral("Unable to get supported mime type for: `%1`.").arg(path);
      return;
    }
    content->setType(Utils::appStringToCoreString(mimeType[0]));
    content->setSubtype(Utils::appStringToCoreString(mimeType[1]));
  }

  content->setSize(size_t(fileSize));
  content->setName(Utils::appStringToCoreString(QFileInfo(file).fileName()));

  shared_ptr<linphone::ChatMessage> message = mChatRoom->createFileTransferMessage(content);
  message->setFileTransferFilepath(Utils::appStringToCoreString(path));
  message->setListener(mMessageHandlers);

  createThumbnail(message);

  insertMessageAtEnd(message);
  mChatRoom->sendChatMessage(message);

  emit messageSent(message);
}

// -----------------------------------------------------------------------------

void ChatModel::downloadFile (int id) {
  const ChatEntryData entry = getFileMessageEntry(id);
  if (!entry.second)
    return;

  shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);

  switch (static_cast<MessageStatus>(message->getState())) {
    case MessageStatusDelivered:
    case MessageStatusDeliveredToUser:
    case MessageStatusDisplayed:
    case MessageStatusFileTransferDone:
      break;

    default:
      qWarning() << QStringLiteral("Unable to download file of entry %1. It was not uploaded.").arg(id);
      return;
  }

  bool soFarSoGood;
  const QString safeFilePath = Utils::getSafeFilePath(
    QStringLiteral("%1%2")
      .arg(CoreManager::getInstance()->getSettingsModel()->getDownloadFolder())
      .arg(entry.first["fileName"].toString()),
    &soFarSoGood
  );

  if (!soFarSoGood) {
    qWarning() << QStringLiteral("Unable to create safe file path for: %1.").arg(id);
    return;
  }

  message->setFileTransferFilepath(Utils::appStringToCoreString(safeFilePath));
  message->setListener(mMessageHandlers);

  if (!message->downloadFile())
    qWarning() << QStringLiteral("Unable to download file of entry %1.").arg(id);
}

void ChatModel::openFile (int id, bool showDirectory) {
  const ChatEntryData entry = getFileMessageEntry(id);
  if (!entry.second)
    return;

  shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);
  if (!::fileWasDownloaded(message)) {
    downloadFile(id);
    return;
  }

  QFileInfo info(getDownloadPath(message));
  QDesktopServices::openUrl(
    QUrl(QStringLiteral("file:///%1").arg(showDirectory ? info.absolutePath() : info.absoluteFilePath()))
  );
}

bool ChatModel::fileWasDownloaded (int id) {
  const ChatEntryData entry = getFileMessageEntry(id);
  return entry.second && ::fileWasDownloaded(static_pointer_cast<linphone::ChatMessage>(entry.second));
}

void ChatModel::compose () {
  mChatRoom->compose();
}

void ChatModel::resetMessageCount () {
  if (mChatRoom->getUnreadMessagesCount() > 0) {
    mChatRoom->markAsRead();
    emit messageCountReset();
  }
}

// -----------------------------------------------------------------------------

const ChatModel::ChatEntryData ChatModel::getFileMessageEntry (int id) {
  if (id < 0 || id > mEntries.count()) {
    qWarning() << QStringLiteral("Entry %1 not exists.").arg(id);
    return ChatEntryData();
  }

  const ChatEntryData entry = mEntries[id];
  if (entry.first["type"] != EntryType::MessageEntry) {
    qWarning() << QStringLiteral("Unable to download entry %1. It's not a message.").arg(id);
    return ChatEntryData();
  }

  shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);
  if (!message->getFileTransferInformation()) {
    qWarning() << QStringLiteral("Entry %1 is not a file message.").arg(id);
    return ChatEntryData();
  }

  return entry;
}

// -----------------------------------------------------------------------------

void ChatModel::removeEntry (ChatEntryData &entry) {
  int type = entry.first["type"].toInt();

  switch (type) {
    case ChatModel::MessageEntry: {
      shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);
      removeFileMessageThumbnail(message);
      mChatRoom->deleteMessage(message);
      break;
    }

    case ChatModel::CallEntry: {
      if (entry.first["status"].toInt() == CallStatusSuccess) {
        // WARNING: Unable to remove symmetric call here. (start/end)
        // We are between `beginRemoveRows` and `endRemoveRows`.
        // A solution is to schedule a `removeEntry` call in the Qt main loop.
        shared_ptr<void> linphonePtr = entry.second;
        QTimer::singleShot(0, this, [this, linphonePtr]() {
          auto it = find_if(mEntries.begin(), mEntries.end(), [linphonePtr](const ChatEntryData &entry) {
            return entry.second == linphonePtr;
          });

          if (it != mEntries.end())
            removeEntry(int(distance(mEntries.begin(), it)));
        });
      }

      CoreManager::getInstance()->getCore()->removeCallLog(static_pointer_cast<linphone::CallLog>(entry.second));
      break;
    }

    default:
      qWarning() << QStringLiteral("Unknown chat entry type: %1.").arg(type);
  }
}

void ChatModel::insertCall (const shared_ptr<linphone::CallLog> &callLog) {
  linphone::Call::Status status = callLog->getStatus();
  switch (status) {
    case linphone::Call::Status::Aborted:
    case linphone::Call::Status::EarlyAborted:
      return; // Ignore aborted calls.

    case linphone::Call::Status::AcceptedElsewhere:
    case linphone::Call::Status::DeclinedElsewhere:
      return; // Ignore accepted calls on other device.

    case linphone::Call::Status::Success:
    case linphone::Call::Status::Missed:
    case linphone::Call::Status::Declined:
      break;
  }

  auto insertEntry = [this](
    const ChatEntryData &entry,
    const QList<ChatEntryData>::iterator *start = NULL
  ) {
    auto it = lower_bound(start ? *start : mEntries.begin(), mEntries.end(), entry, [](const ChatEntryData &a, const ChatEntryData &b) {
      return a.first["timestamp"] < b.first["timestamp"];
    });

    int row = int(distance(mEntries.begin(), it));

    beginInsertRows(QModelIndex(), row, row);
    it = mEntries.insert(it, entry);
    endInsertRows();

    return it;
  };

  // Add start call.
  QVariantMap start;
  fillCallStartEntry(start, callLog);
  auto it = insertEntry(qMakePair(start, static_pointer_cast<void>(callLog)));

  // Add end call. (if necessary)
  if (status == linphone::Call::Status::Success) {
    QVariantMap end;
    fillCallEndEntry(end, callLog);
    insertEntry(qMakePair(end, static_pointer_cast<void>(callLog)), &it);
  }
}

void ChatModel::insertMessageAtEnd (const shared_ptr<linphone::ChatMessage> &message) {
  int row = mEntries.count();

  beginInsertRows(QModelIndex(), row, row);

  QVariantMap map{
    { "type", EntryType::MessageEntry },
    { "timestamp", QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000) }
  };
  fillMessageEntry(map, message);
  mEntries << qMakePair(map, static_pointer_cast<void>(message));

  endInsertRows();
}

// -----------------------------------------------------------------------------

void ChatModel::handleCallStateChanged (const shared_ptr<linphone::Call> &call, linphone::Call::State state) {
  if (
    (state == linphone::Call::State::End || state == linphone::Call::State::Error) &&
    mChatRoom == CoreManager::getInstance()->getCore()->findChatRoom(call->getRemoteAddress(), mChatRoom->getLocalAddress())
  )
    insertCall(call->getCallLog());
}

void ChatModel::handleIsComposingChanged (const shared_ptr<linphone::ChatRoom> &chatRoom) {
  if (mChatRoom == chatRoom) {
    bool isRemoteComposing = mChatRoom->isRemoteComposing();
    if (isRemoteComposing != mIsRemoteComposing) {
      mIsRemoteComposing = isRemoteComposing;
      emit isRemoteComposingChanged(mIsRemoteComposing);
    }
  }
}

void ChatModel::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &message) {
  if (mChatRoom == message->getChatRoom()) {
    insertMessageAtEnd(message);
    emit messageReceived(message);
  }
}
