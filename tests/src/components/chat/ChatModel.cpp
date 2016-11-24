#include <QDateTime>

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "ChatModel.hpp"

// ===================================================================

QHash<int, QByteArray> ChatModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$chatEntry";
  return roles;
}

QVariant ChatModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (row < 0 || row >= m_entries.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(m_entries[row]);

  return QVariant();
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

  std::shared_ptr<linphone::ChatRoom> chat_room =
    CoreManager::getInstance()->getCore()->getChatRoomFromUri(
      Utils::qStringToLinphoneString(sip_address)
    );

  for (auto &message : chat_room->getHistory(0)) {
    QVariantMap map;

    map["sectionDate"] = 1465389121;
    map["timestamp"] = QDateTime::fromTime_t(message->getTime());
    map["type"] = "message";
    map["content"] = Utils::linphoneStringToQString(
      message->getText()
    );
    map["isOutgoing"] = message->isOutgoing();

    m_entries << map;
  }

  endResetModel();

  emit sipAddressChanged(sip_address);
}
