#include <QDateTime>
#include <QtDebug>

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "ChatModel.hpp"

using namespace std;

// ===================================================================

QHash<int, QByteArray> ChatModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Roles::ChatEntry] = "$chatEntry";
  roles[Roles::SectionDate] = "$sectionDate";
  return roles;
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
    QPair<QVariantMap, shared_ptr<void> > pair = m_entries.takeAt(row);

    switch (pair.first["type"].toInt()) {
      case ChatModel::MessageEntry:
        m_chat_room->deleteMessage(
          static_pointer_cast<linphone::ChatMessage>(pair.second)
        );
        break;
      case ChatModel::CallEntry:

        break;
    }
  }

  endRemoveRows();

  return true;
}

// -------------------------------------------------------------------

void ChatModel::removeEntry (int id) {
  qInfo() << "Removing chat entry:" << id << "of:" << getSipAddress();

  if (!removeRow(id))
    qWarning() << "Unable to remove chat entry:" << id;
}

// -------------------------------------------------------------------

QString ChatModel::getSipAddress () const {
  if (!m_chat_room)
    return "";

  return Utils::linphoneStringToQString(
    m_chat_room->getPeerAddress()->asString()
  );
}

void ChatModel::setSipAddress (const QString &sip_address) {
  if (sip_address == getSipAddress())
    return;

  beginResetModel();

  // Invalid old sip address entries.
  m_entries.clear();

  m_chat_room =
    CoreManager::getInstance()->getCore()->getChatRoomFromUri(
      Utils::qStringToLinphoneString(sip_address)
    );

  // Get messages.
  for (auto &message : m_chat_room->getHistory(0)) {
    QVariantMap map;

    map["type"] = EntryType::MessageEntry;
    map["timestamp"] = QDateTime::fromTime_t(message->getTime());
    map["content"] = Utils::linphoneStringToQString(
      message->getText()
    );
    map["isOutgoing"] = message->isOutgoing();

    m_entries << qMakePair(map, static_pointer_cast<void>(message));
  }

  // Get calls.
  // TODO.

  endResetModel();

  emit sipAddressChanged(sip_address);
}
