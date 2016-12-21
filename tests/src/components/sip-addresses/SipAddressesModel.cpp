#include <QDateTime>
#include <QSet>

#include "../../utils.hpp"
#include "../contacts/ContactsListModel.hpp"
#include "../core/CoreManager.hpp"

#include "SipAddressesModel.hpp"

// =============================================================================

SipAddressesModel::SipAddressesModel (QObject *parent) : QAbstractListModel(parent) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  // Get sip addresses from chatrooms.
  for (const auto &chat_room : core->getChatRooms()) {
    list<shared_ptr<linphone::ChatMessage> > history = chat_room->getHistory(0);

    if (history.size() == 0)
      continue;

    QString sip_address = ::Utils::linphoneStringToQString(chat_room->getPeerAddress()->asString());

    QVariantMap map;
    map["sipAddress"] = sip_address;
    map["timestamp"] = QDateTime::fromMSecsSinceEpoch(static_cast<qint64>(history.back()->getTime()) * 1000);

    m_sip_addresses[sip_address] = map;
  }

  // Get sip addresses from calls.
  QSet<QString> address_done;
  for (const auto &call_log : core->getCallLogs()) {
    QString sip_address = ::Utils::linphoneStringToQString(call_log->getRemoteAddress()->asString());

    if (address_done.contains(sip_address))
      continue; // Already used.
    address_done << sip_address;

    QVariantMap map;
    map["sipAddress"] = sip_address;
    map["timestamp"] = QDateTime::fromMSecsSinceEpoch(
        static_cast<qint64>(call_log->getStartDate() + call_log->getDuration()) * 1000
      );

    auto it = m_sip_addresses.find(sip_address);
    if (it == m_sip_addresses.end() || map["timestamp"] > (*it)["timestamp"])
      m_sip_addresses[sip_address] = map;
  }

  // Get sip addresses from contacts.
  for (auto &contact : CoreManager::getInstance()->getContactsListModel()->m_list) {
    for (const auto &sip_address : contact->getVcardModel()->getSipAddresses()) {
      auto it = m_sip_addresses.find(sip_address.toString());

      if (it == m_sip_addresses.end()) {
        QVariantMap map;
        map["sipAddress"] = sip_address;
        map["contact"] = QVariant::fromValue(contact);
        m_sip_addresses[sip_address.toString()] = map;
      } else
        (*it)["contact"] = QVariant::fromValue(contact);
    }
  }

  for (const auto &map : m_sip_addresses)
    m_refs << &map;
}

// -----------------------------------------------------------------------------

int SipAddressesModel::rowCount (const QModelIndex &) const {
  return m_refs.count();
}

QHash<int, QByteArray> SipAddressesModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$sipAddress";
  return roles;
}

QVariant SipAddressesModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (row < 0 || row >= m_refs.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(*m_refs[row]);

  return QVariant();
}

// ------------------------------------------------------------------------------

ContactModel *SipAddressesModel::mapSipAddressToContact (const QString &sip_address) const {
  auto it = m_sip_addresses.find(sip_address);
  if (it == m_sip_addresses.end())
    return nullptr;

  return it->value("contact").value<ContactModel *>();
}
