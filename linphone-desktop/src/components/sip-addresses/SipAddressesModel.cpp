/*
 * SipAddressesModel.cpp
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

  m_core_handlers = CoreManager::getInstance()->getHandlers();

  ContactsListModel *contacts = CoreManager::getInstance()->getContactsListModel();

  QObject::connect(contacts, &ContactsListModel::contactAdded, this, &SipAddressesModel::handleContactAdded);
  QObject::connect(contacts, &ContactsListModel::contactRemoved, this, &SipAddressesModel::handleContactRemoved);

  QObject::connect(contacts, &ContactsListModel::sipAddressAdded, this, &SipAddressesModel::handleSipAddressAdded);
  QObject::connect(contacts, &ContactsListModel::sipAddressRemoved, this, &SipAddressesModel::handleSipAddressRemoved);

  QObject::connect(&(*m_core_handlers), &CoreHandlers::messageReceived, this, &SipAddressesModel::handleMessageReceived);
  QObject::connect(&(*m_core_handlers), &CoreHandlers::callStateChanged, this, &SipAddressesModel::handleCallStateChanged);
  QObject::connect(&(*m_core_handlers), &CoreHandlers::presenceReceived, this, &SipAddressesModel::handlePresenceReceived);
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

void SipAddressesModel::connectToChatModel (ChatModel *chat_model) {
  QObject::connect(chat_model, &ChatModel::allEntriesRemoved, this, [this, chat_model] {
    handleAllEntriesRemoved(chat_model->getSipAddress());
  });

  QObject::connect(chat_model, &ChatModel::messageSent, this, &SipAddressesModel::handleMessageSent);

  QObject::connect(chat_model, &ChatModel::messagesCountReset, this, [this, chat_model] {
    handleMessagesCountReset(chat_model->getSipAddress());
  });
}

// -----------------------------------------------------------------------------

ContactModel *SipAddressesModel::mapSipAddressToContact (const QString &sip_address) const {
  auto it = m_sip_addresses.find(sip_address);
  if (it == m_sip_addresses.end())
    return nullptr;

  return it->value("contact").value<ContactModel *>();
}

// -----------------------------------------------------------------------------

SipAddressObserver *SipAddressesModel::getSipAddressObserver (const QString &sip_address) {
  SipAddressObserver *model = new SipAddressObserver(sip_address);

  {
    auto it = m_sip_addresses.find(sip_address);
    if (it != m_sip_addresses.end()) {
      model->setContact(it->value("contact").value<ContactModel *>());
      model->setPresenceStatus(
        it->value("presenceStatus", Presence::PresenceStatus::Offline).value<Presence::PresenceStatus>()
      );
      model->setUnreadMessagesCount(
        it->value("unreadMessagesCount", 0).toInt()
      );
    }
  }

  m_observers.insert(sip_address, model);
  QObject::connect(
    model, &SipAddressObserver::destroyed, this, [this, model]() {
      const QString &sip_address = model->getSipAddress();
      if (m_observers.remove(sip_address, model) == 0)
        qWarning() << QStringLiteral("Unable to remove sip address `%1` from observers.").arg(sip_address);
    }
  );

  return model;
}

// -----------------------------------------------------------------------------

QString SipAddressesModel::interpretUrl (const QString &sip_address) const {
  shared_ptr<linphone::Address> l_address = CoreManager::getInstance()->getCore()->interpretUrl(
      ::Utils::qStringToLinphoneString(sip_address)
    );

  return l_address ? ::Utils::linphoneStringToQString(l_address->asStringUriOnly()) : "";
}

QString SipAddressesModel::getTransportFromSipAddress (const QString &sip_address) const {
  const shared_ptr<const linphone::Address> address = linphone::Factory::get()->createAddress(
      ::Utils::qStringToLinphoneString(sip_address)
    );

  if (!address)
    return QStringLiteral("");

  switch (address->getTransport()) {
    case linphone::TransportTypeUdp:
      return QStringLiteral("UDP");
    case linphone::TransportTypeTcp:
      return QStringLiteral("TCP");
    case linphone::TransportTypeTls:
      return QStringLiteral("TLS");
    case linphone::TransportTypeDtls:
      return QStringLiteral("DTLS");
  }

  return QStringLiteral("");
}

QString SipAddressesModel::addTransportToSipAddress (const QString &sip_address, const QString &transport) const {
  shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(
      ::Utils::qStringToLinphoneString(sip_address)
    );

  if (!address)
    return "";

  QString _transport = transport.toUpper();
  if (_transport == "TCP")
    address->setTransport(linphone::TransportType::TransportTypeTcp);
  else if (_transport == "UDP")
    address->setTransport(linphone::TransportType::TransportTypeUdp);
  else if (_transport == "TLS")
    address->setTransport(linphone::TransportType::TransportTypeTls);
  else
    address->setTransport(linphone::TransportType::TransportTypeDtls);

  return ::Utils::linphoneStringToQString(address->asString());
}

bool SipAddressesModel::sipAddressIsValid (const QString &sip_address) const {
  shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(
      ::Utils::qStringToLinphoneString(sip_address)
    );

  return !!address;
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

// -----------------------------------------------------------------------------

void SipAddressesModel::handleContactAdded (ContactModel *contact) {
  for (const auto &sip_address : contact->getVcardModel()->getSipAddresses())
    addOrUpdateSipAddress(sip_address.toString(), contact);
}

void SipAddressesModel::handleContactRemoved (const ContactModel *contact) {
  for (const auto &sip_address : contact->getVcardModel()->getSipAddresses())
    removeContactOfSipAddress(sip_address.toString());
}

void SipAddressesModel::handleSipAddressAdded (ContactModel *contact, const QString &sip_address) {
  ContactModel *mapped_contact = mapSipAddressToContact(sip_address);
  if (mapped_contact) {
    qWarning() << "Unable to map sip address" << sip_address << "to" << contact << "- already used by" << mapped_contact;
    return;
  }

  addOrUpdateSipAddress(sip_address, contact);
}

void SipAddressesModel::handleSipAddressRemoved (ContactModel *contact, const QString &sip_address) {
  ContactModel *mapped_contact = mapSipAddressToContact(sip_address);
  if (contact != mapped_contact) {
    qWarning() << "Unable to remove sip address" << sip_address << "of" << contact << "- already used by" << mapped_contact;
    return;
  }

  removeContactOfSipAddress(sip_address);
}

void SipAddressesModel::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &message) {
  const QString &sip_address = ::Utils::linphoneStringToQString(message->getFromAddress()->asStringUriOnly());
  addOrUpdateSipAddress(sip_address, message);
}

void SipAddressesModel::handleCallStateChanged (
  const shared_ptr<linphone::Call> &call,
  linphone::CallState state
) {
  // Ignore aborted calls.
  if (call->getCallLog()->getStatus() == linphone::CallStatus::CallStatusAborted)
    return;

  if (state == linphone::CallStateEnd || state == linphone::CallStateError)
    addOrUpdateSipAddress(
      ::Utils::linphoneStringToQString(call->getRemoteAddress()->asStringUriOnly()), call
    );
}

void SipAddressesModel::handlePresenceReceived (
  const QString &sip_address,
  const shared_ptr<const linphone::PresenceModel> &presence_model
) {
  Presence::PresenceStatus status;

  switch (presence_model->getConsolidatedPresence()) {
    case linphone::ConsolidatedPresenceOnline:
      status = Presence::PresenceStatus::Online;
      break;
    case linphone::ConsolidatedPresenceBusy:
      status = Presence::PresenceStatus::Busy;
      break;
    case linphone::ConsolidatedPresenceDoNotDisturb:
      status = Presence::PresenceStatus::DoNotDisturb;
      break;
    case linphone::ConsolidatedPresenceOffline:
      status = Presence::PresenceStatus::Offline;
      break;
  }

  auto it = m_sip_addresses.find(sip_address);
  if (it != m_sip_addresses.end()) {
    qInfo() << QStringLiteral("Update presence of `%1`: %2.").arg(sip_address).arg(status);
    (*it)["presenceStatus"] = status;

    int row = m_refs.indexOf(&(*it));
    Q_ASSERT(row != -1);
    emit dataChanged(index(row, 0), index(row, 0));
  }

  updateObservers(sip_address, status);
}

void SipAddressesModel::handleAllEntriesRemoved (const QString &sip_address) {
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

void SipAddressesModel::handleMessageSent (const shared_ptr<linphone::ChatMessage> &message) {
  addOrUpdateSipAddress(
    ::Utils::linphoneStringToQString(message->getToAddress()->asStringUriOnly()),
    message
  );
}

void SipAddressesModel::handleMessagesCountReset (const QString &sip_address) {
  auto it = m_sip_addresses.find(sip_address);
  if (it != m_sip_addresses.end()) {
    (*it)["unreadMessagesCount"] = 0;

    int row = m_refs.indexOf(&(*it));
    Q_ASSERT(row != -1);
    emit dataChanged(index(row, 0), index(row, 0));
  }

  updateObservers(sip_address, 0);
}

// -----------------------------------------------------------------------------

void SipAddressesModel::addOrUpdateSipAddress (QVariantMap &map, ContactModel *contact) {
  map["contact"] = QVariant::fromValue(contact);
  updateObservers(map["sipAddress"].toString(), contact);
}

void SipAddressesModel::addOrUpdateSipAddress (QVariantMap &map, const shared_ptr<linphone::Call> &call) {
  const shared_ptr<linphone::CallLog> call_log = call->getCallLog();

  map["timestamp"] = call_log->getStatus() == linphone::CallStatus::CallStatusSuccess
    ? QDateTime::fromMSecsSinceEpoch((call_log->getStartDate() + call_log->getDuration()) * 1000)
    : QDateTime::fromMSecsSinceEpoch(call_log->getStartDate() * 1000);
}

void SipAddressesModel::addOrUpdateSipAddress (QVariantMap &map, const shared_ptr<linphone::ChatMessage> &message) {
  int count = message->getChatRoom()->getUnreadMessagesCount();

  map["timestamp"] = QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000);
  map["unreadMessagesCount"] = count;

  updateObservers(map["sipAddress"].toString(), count);
}

template<typename T>
void SipAddressesModel::addOrUpdateSipAddress (const QString &sip_address, T data) {
  auto it = m_sip_addresses.find(sip_address);
  if (it != m_sip_addresses.end()) {
    addOrUpdateSipAddress(*it, data);

    int row = m_refs.indexOf(&(*it));
    Q_ASSERT(row != -1);
    emit dataChanged(index(row, 0), index(row, 0));

    return;
  }

  QVariantMap map;
  map["sipAddress"] = sip_address;
  addOrUpdateSipAddress(map, data);

  int row = m_refs.count();

  beginInsertRows(QModelIndex(), row, row);

  qInfo() << QStringLiteral("Add sip address: `%1`.").arg(sip_address);

  m_sip_addresses[sip_address] = map;
  m_refs << &m_sip_addresses[sip_address];

  endInsertRows();
}

// -----------------------------------------------------------------------------

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

    QString sip_address = ::Utils::linphoneStringToQString(chat_room->getPeerAddress()->asStringUriOnly());

    QVariantMap map;
    map["sipAddress"] = sip_address;
    map["timestamp"] = QDateTime::fromMSecsSinceEpoch(history.back()->getTime() * 1000);
    map["unreadMessagesCount"] = chat_room->getUnreadMessagesCount();

    m_sip_addresses[sip_address] = map;
  }

  // Get sip addresses from calls.
  QSet<QString> address_done;
  for (const auto &call_log : core->getCallLogs()) {
    const QString &sip_address = ::Utils::linphoneStringToQString(call_log->getRemoteAddress()->asStringUriOnly());

    if (address_done.contains(sip_address))
      continue; // Already used.

    if (call_log->getStatus() == linphone::CallStatusAborted)
      continue; // Ignore aborted calls.

    address_done << sip_address;

    QVariantMap map;
    map["sipAddress"] = sip_address;

    // The duration can be wrong if status is not success.
    map["timestamp"] = call_log->getStatus() == linphone::CallStatus::CallStatusSuccess
      ? QDateTime::fromMSecsSinceEpoch((call_log->getStartDate() + call_log->getDuration()) * 1000)
      : QDateTime::fromMSecsSinceEpoch(call_log->getStartDate() * 1000);

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

// -----------------------------------------------------------------------------

void SipAddressesModel::updateObservers (const QString &sip_address, ContactModel *contact) {
  for (auto &observer : m_observers.values(sip_address))
    observer->setContact(contact);
}

void SipAddressesModel::updateObservers (const QString &sip_address, const Presence::PresenceStatus &presence_status) {
  for (auto &observer : m_observers.values(sip_address))
    observer->setPresenceStatus(presence_status);
}

void SipAddressesModel::updateObservers (const QString &sip_address, int messages_count) {
  for (auto &observer : m_observers.values(sip_address))
    observer->setUnreadMessagesCount(messages_count);
}
