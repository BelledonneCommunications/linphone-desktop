#include <QDateTime>
#include <QSet>
#include <QtDebug>

#include "../../utils.hpp"
#include "../chat/ChatModel.hpp"
#include "../core/CoreManager.hpp"

#include "SipAddressesModel.hpp"

using namespace std;

// =============================================================================

SipAddressesModel::SipAddressesModel (QObject *parent) : QAbstractListModel(parent) {
  initSipAddresses();
  ContactsListModel *contacts = CoreManager::getInstance()->getContactsListModel();

  QObject::connect(contacts, &ContactsListModel::contactAdded, this, &SipAddressesModel::handleContactAdded);
  QObject::connect(contacts, &ContactsListModel::contactRemoved, this, &SipAddressesModel::handleContactRemoved);

  QObject::connect(
    contacts, &ContactsListModel::sipAddressAdded, this, [this](ContactModel *contact, const QString &sip_address) {
      // TODO: Avoid the limitation of one contact by sip address.
      ContactModel *mapped_contact = mapSipAddressToContact(sip_address);
      if (mapped_contact) {
        qWarning() << "Unable to map sip address" << sip_address << "to" << contact << "- already used by" << mapped_contact;
        return;
      }

      addOrUpdateSipAddress(sip_address, contact);
    }
  );

  QObject::connect(
    contacts, &ContactsListModel::sipAddressRemoved, this, [this](ContactModel *contact, const QString &sip_address) {
      ContactModel *mapped_contact = mapSipAddressToContact(sip_address);
      if (contact != mapped_contact) {
        qWarning() << "Unable to remove sip address" << sip_address << "of" << contact << "- already used by" << mapped_contact;
        return;
      }

      removeContactOfSipAddress(sip_address);
    }
  );
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

  if (!index.isValid() || row < 0 || row >= m_refs.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(*m_refs[row]);

  return QVariant();
}

// -----------------------------------------------------------------------------

ContactModel *SipAddressesModel::mapSipAddressToContact (const QString &sip_address) const {
  auto it = m_sip_addresses.find(sip_address);
  if (it == m_sip_addresses.end())
    return nullptr;

  return it->value("contact").value<ContactModel *>();
}

// -----------------------------------------------------------------------------

ContactObserver *SipAddressesModel::getContactObserver (const QString &sip_address) {
  ContactObserver *model = new ContactObserver(sip_address);
  model->setContact(mapSipAddressToContact(sip_address));

  m_observers.insert(sip_address, model);
  QObject::connect(
    model, &ContactObserver::destroyed, this, [this, model]() {
      const QString &sip_address = model->getSipAddress();
      if (m_observers.remove(sip_address, model) == 0)
        qWarning() << QStringLiteral("Unable to remove sip address `%1` from observers.").arg(sip_address);
    }
  );

  return model;
}

// -----------------------------------------------------------------------------

void SipAddressesModel::handleAllHistoryEntriesRemoved () {
  QObject *sender = QObject::sender();
  if (!sender)
    return;

  ChatModel *chat_model = qobject_cast<ChatModel *>(sender);
  if (!chat_model)
    return;

  const QString sip_address = chat_model->getSipAddress();
  auto it = m_sip_addresses.find(sip_address);
  if (it == m_sip_addresses.end()) {
    qWarning() << QStringLiteral("Unable to found sip address: `%1`.").arg(sip_address);
    return;
  }

  int row = m_refs.indexOf(&(*it));
  Q_ASSERT(row != -1);

  // No history, no contact => Remove sip address from list.
  if (!it->contains("contact")) {
    removeRow(row);
    return;
  }

  // Signal changes.
  it->remove("timestamp");
  emit dataChanged(index(row, 0), index(row, 0));
}

void SipAddressesModel::handleReceivedMessage (
  const shared_ptr<linphone::ChatRoom> &room,
  const shared_ptr<linphone::ChatMessage> &message
) {
  const QString &sip_address = ::Utils::linphoneStringToQString(message->getFromAddress()->asString());
  addOrUpdateSipAddress(sip_address, nullptr, static_cast<qint64>(message->getTime()));
}

// -----------------------------------------------------------------------------

bool SipAddressesModel::removeRow (int row, const QModelIndex &parent) {
  return removeRows(row, 1, parent);
}

bool SipAddressesModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= m_sip_addresses.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i) {
    const QVariantMap *map = m_refs.takeAt(row);
    QString sip_address = (*map)["sipAddress"].toString();

    qInfo() << QStringLiteral("Remove sip address: `%1`.").arg(sip_address);
    m_sip_addresses.remove(sip_address);
  }

  endRemoveRows();

  return true;
}

void SipAddressesModel::handleContactAdded (ContactModel *contact) {
  for (const auto &sip_address : contact->getVcardModel()->getSipAddresses())
    addOrUpdateSipAddress(sip_address.toString(), contact);
}

void SipAddressesModel::handleContactRemoved (const ContactModel *contact) {
  for (const auto &sip_address : contact->getVcardModel()->getSipAddresses())
    removeContactOfSipAddress(sip_address.toString());
}

void SipAddressesModel::addOrUpdateSipAddress (const QString &sip_address, ContactModel *contact, qint64 timestamp) {
  auto it = m_sip_addresses.find(sip_address);
  if (it != m_sip_addresses.end()) {
    if (contact) {
      (*it)["contact"] = QVariant::fromValue(contact);
      updateObservers(sip_address, contact);
    }

    if (timestamp)
      (*it)["timestamp"] = QDateTime::fromMSecsSinceEpoch(timestamp * 1000);

    int row = m_refs.indexOf(&(*it));
    Q_ASSERT(row != -1);
    emit dataChanged(index(row, 0), index(row, 0));

    return;
  }

  QVariantMap map;
  map["sipAddress"] = sip_address;

  if (contact) {
    map["contact"] = QVariant::fromValue(contact);
    updateObservers(sip_address, contact);
  }

  if (timestamp)
    map["timestamp"] = QDateTime::fromMSecsSinceEpoch(timestamp * 1000);

  int row = m_refs.count();

  beginInsertRows(QModelIndex(), row, row);

  qInfo() << QStringLiteral("Add sip address: `%1`.").arg(sip_address);

  m_sip_addresses[sip_address] = map;
  m_refs << &m_sip_addresses[sip_address];

  endInsertRows();
}

void SipAddressesModel::removeContactOfSipAddress (const QString &sip_address) {
  auto it = m_sip_addresses.find(sip_address);
  if (it == m_sip_addresses.end()) {
    qWarning() << QStringLiteral("Unable to remove unavailable sip address: `%1`.").arg(sip_address);
    return;
  }

  updateObservers(sip_address, nullptr);

  if (it->remove("contact") == 0)
    qWarning() << QStringLiteral("`contact` field is empty on sip address: `%1`.").arg(sip_address);

  int row = m_refs.indexOf(&(*it));
  Q_ASSERT(row != -1);

  // History exists, signal changes.
  if (it->contains("timestamp")) {
    emit dataChanged(index(row, 0), index(row, 0));
    return;
  }

  // Remove sip address if no history.
  removeRow(row);
}

void SipAddressesModel::initSipAddresses () {
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

    if (call_log->getStatus() == linphone::CallStatusAborted)
      continue; // Ignore aborted calls.

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

  for (const auto &map : m_sip_addresses)
    m_refs << &map;

  // Get sip addresses from contacts.
  for (auto &contact : CoreManager::getInstance()->getContactsListModel()->m_list)
    handleContactAdded(contact);
}

void SipAddressesModel::updateObservers (const QString &sip_address, ContactModel *contact) {
  for (auto &observer : m_observers.values(sip_address)) {
    if (contact != observer->getContact())
      observer->setContact(contact);
  }
}
