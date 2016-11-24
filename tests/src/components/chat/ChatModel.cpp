#include "../../utils.hpp"

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
  emit sipAddressChanged(sip_address);
}
