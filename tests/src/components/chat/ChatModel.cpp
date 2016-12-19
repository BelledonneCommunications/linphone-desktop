#include <algorithm>

#include <QDateTime>
#include <QTimer>
#include <QtDebug>

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "ChatModel.hpp"

using namespace std;

// =============================================================================

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

  if (row < 0 || row >= m_entries.count())
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

  return true;
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
}

// -----------------------------------------------------------------------------

void ChatModel::fillMessageEntry (
  QVariantMap &dest,
  const shared_ptr<linphone::ChatMessage> &message
) {
  dest["type"] = EntryType::MessageEntry;
  dest["timestamp"] = QDateTime::fromMSecsSinceEpoch(static_cast<qint64>(message->getTime()) * 1000);
  dest["content"] = ::Utils::linphoneStringToQString(message->getText());
  dest["isOutgoing"] = message->isOutgoing();
}

void ChatModel::fillCallStartEntry (
  QVariantMap &dest,
  const shared_ptr<linphone::CallLog> &call_log
) {
  QDateTime timestamp = QDateTime::fromMSecsSinceEpoch(static_cast<qint64>(call_log->getStartDate()) * 1000);

  dest["type"] = EntryType::CallEntry;
  dest["timestamp"] = timestamp;
  dest["isOutgoing"] = call_log->getDir() == linphone::CallDirOutgoing;
  dest["status"] = call_log->getStatus();
  dest["isStart"] = true;
}

void ChatModel::fillCallEndEntry (
  QVariantMap &dest,
  const shared_ptr<linphone::CallLog> &call_log
) {
  QDateTime timestamp = QDateTime::fromMSecsSinceEpoch(
      static_cast<qint64>(call_log->getStartDate() + call_log->getDuration()) * 1000
    );

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
    case ChatModel::MessageEntry:
      m_chat_room->deleteMessage(static_pointer_cast<linphone::ChatMessage>(pair.second));
      break;
    case ChatModel::CallEntry:
      if (pair.first["status"].toInt() == linphone::CallStatusSuccess) {
        // WARNING: Unable to remove symmetric call here. (start/end)
        // We are between `beginRemoveRows` and `endRemoveRows`.
        // A solution is to schedule a `removeEntry` call in the Qt main loop.
        shared_ptr<void> linphone_ptr = pair.second;
        QTimer::singleShot(
          0, this, [this, linphone_ptr]() {
            auto it = find_if(
                m_entries.begin(), m_entries.end(), [linphone_ptr](const ChatEntryData &pair) {
                  return pair.second == linphone_ptr;
                }
              );

            if (it != m_entries.end())
              removeEntry(static_cast<int>(distance(m_entries.begin(), it)));
          }
        );
      }

      CoreManager::getInstance()->getCore()->removeCallLog(static_pointer_cast<linphone::CallLog>(pair.second));
      break;
    default:
      qWarning() << QStringLiteral("Unknown chat entry type: %1.").arg(type);
  }
}

QString ChatModel::getSipAddress () const {
  if (!m_chat_room)
    return "";

  return ::Utils::linphoneStringToQString(
    m_chat_room->getPeerAddress()->asString()
  );
}

void ChatModel::setSipAddress (const QString &sip_address) {
  if (sip_address == getSipAddress())
    return;

  beginResetModel();

  // Invalid old sip address entries.
  m_entries.clear();

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  string std_sip_address = ::Utils::qStringToLinphoneString(sip_address);

  m_chat_room = core->getChatRoomFromUri(std_sip_address);

  // Get messages.
  for (auto &message : m_chat_room->getHistory(0)) {
    QVariantMap map;

    fillMessageEntry(map, message);
    m_entries << qMakePair(map, static_pointer_cast<void>(message));
  }

  // Get calls.
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

      return m_entries.insert(it, pair);
    };

  for (auto &call_log : core->getCallHistoryForAddress(m_chat_room->getPeerAddress())) {
    linphone::CallStatus status = call_log->getStatus();

    // Ignore aborted calls.
    if (status == linphone::CallStatusAborted)
      continue;

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

  endResetModel();

  emit sipAddressChanged(sip_address);
}
