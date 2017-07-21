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

#include "../../utils/LinphoneUtils.hpp"
#include "../../utils/Utils.hpp"
#include "../core/CoreManager.hpp"

#include "SipAddressesModel.hpp"

using namespace std;

// =============================================================================

SipAddressesModel::SipAddressesModel (QObject *parent) : QAbstractListModel(parent) {
  initSipAddresses();

  CoreManager *coreManager = CoreManager::getInstance();

  mCoreHandlers = coreManager->getHandlers();

  QObject::connect(coreManager, &CoreManager::chatModelCreated, this, &SipAddressesModel::handleChatModelCreated);

  ContactsListModel *contacts = CoreManager::getInstance()->getContactsListModel();
  QObject::connect(contacts, &ContactsListModel::contactAdded, this, &SipAddressesModel::handleContactAdded);
  QObject::connect(contacts, &ContactsListModel::contactRemoved, this, &SipAddressesModel::handleContactRemoved);
  QObject::connect(contacts, &ContactsListModel::sipAddressAdded, this, &SipAddressesModel::handleSipAddressAdded);
  QObject::connect(contacts, &ContactsListModel::sipAddressRemoved, this, &SipAddressesModel::handleSipAddressRemoved);

  CoreHandlers *coreHandlers = mCoreHandlers.get();
  QObject::connect(coreHandlers, &CoreHandlers::messageReceived, this, &SipAddressesModel::handleMessageReceived);
  QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &SipAddressesModel::handleCallStateChanged);
  QObject::connect(coreHandlers, &CoreHandlers::presenceReceived, this, &SipAddressesModel::handlePresenceReceived);
  QObject::connect(coreHandlers, &CoreHandlers::isComposingChanged, this, &SipAddressesModel::handlerIsComposingChanged);
}

// -----------------------------------------------------------------------------

int SipAddressesModel::rowCount (const QModelIndex &) const {
  return mRefs.count();
}

QHash<int, QByteArray> SipAddressesModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$sipAddress";
  return roles;
}

QVariant SipAddressesModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mRefs.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(*mRefs[row]);

  return QVariant();
}

// -----------------------------------------------------------------------------

QVariantMap SipAddressesModel::find (const QString &sipAddress) const {
  auto it = mSipAddresses.find(sipAddress);
  return it == mSipAddresses.end() ? QVariantMap() : *it;
}

// -----------------------------------------------------------------------------

ContactModel *SipAddressesModel::mapSipAddressToContact (const QString &sipAddress) const {
  auto it = mSipAddresses.find(sipAddress);
  if (it == mSipAddresses.end())
    return nullptr;

  return it->value("contact").value<ContactModel *>();
}

// -----------------------------------------------------------------------------

SipAddressObserver *SipAddressesModel::getSipAddressObserver (const QString &sipAddress) {
  SipAddressObserver *model = new SipAddressObserver(sipAddress);

  {
    auto it = mSipAddresses.find(sipAddress);
    if (it != mSipAddresses.end()) {
      model->setContact(it->value("contact").value<ContactModel *>());
      model->setPresenceStatus(
        it->value("presenceStatus", Presence::PresenceStatus::Offline).value<Presence::PresenceStatus>()
      );
      model->setUnreadMessagesCount(
        it->value("unreadMessagesCount", 0).toInt()
      );
    }
  }

  mObservers.insert(sipAddress, model);
  QObject::connect(
    model, &SipAddressObserver::destroyed, this, [this, model]() {
      const QString sipAddress = model->getSipAddress();
      if (mObservers.remove(sipAddress, model) == 0)
        qWarning() << QStringLiteral("Unable to remove sip address `%1` from observers.").arg(sipAddress);
    });

  return model;
}

// -----------------------------------------------------------------------------

QString SipAddressesModel::getTransportFromSipAddress (const QString &sipAddress) const {
  const shared_ptr<const linphone::Address> address = linphone::Factory::get()->createAddress(
      ::Utils::appStringToCoreString(sipAddress)
    );

  if (!address)
    return QString("");

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

  return QString("");
}

QString SipAddressesModel::addTransportToSipAddress (const QString &sipAddress, const QString &transport) const {
  shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(
      ::Utils::appStringToCoreString(sipAddress)
    );

  if (!address)
    return QString("");

  address->setTransport(LinphoneUtils::stringToTransportType(transport.toUpper()));

  return ::Utils::coreStringToAppString(address->asString());
}

// -----------------------------------------------------------------------------

QString SipAddressesModel::interpretUrl (const QString &sipAddress) {
  shared_ptr<linphone::Address> lAddress = CoreManager::getInstance()->getCore()->interpretUrl(
      ::Utils::appStringToCoreString(sipAddress)
    );

  return lAddress ? ::Utils::coreStringToAppString(lAddress->asStringUriOnly()) : QString("");
}

QString SipAddressesModel::interpretUrl (const QUrl &sipAddress) {
  return sipAddress.toString();
}

bool SipAddressesModel::addressIsValid (const QString &address) {
  return !!linphone::Factory::get()->createAddress(
    ::Utils::appStringToCoreString(address)
  );
}

bool SipAddressesModel::sipAddressIsValid (const QString &sipAddress) {
  shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(
      ::Utils::appStringToCoreString(sipAddress)
    );
  return address && !address->getUsername().empty();
}

// -----------------------------------------------------------------------------

bool SipAddressesModel::removeRow (int row, const QModelIndex &parent) {
  return removeRows(row, 1, parent);
}

bool SipAddressesModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= mSipAddresses.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i) {
    const QVariantMap *map = mRefs.takeAt(row);
    QString sipAddress = (*map)["sipAddress"].toString();

    qInfo() << QStringLiteral("Remove sip address: `%1`.").arg(sipAddress);
    mSipAddresses.remove(sipAddress);
  }

  endRemoveRows();

  return true;
}

// -----------------------------------------------------------------------------

void SipAddressesModel::handleChatModelCreated (const shared_ptr<ChatModel> &chatModel) {
  ChatModel *ptr = chatModel.get();

  QObject::connect(ptr, &ChatModel::allEntriesRemoved, this, [this, ptr] {
    handleAllEntriesRemoved(ptr->getSipAddress());
  });

  QObject::connect(ptr, &ChatModel::messageSent, this, &SipAddressesModel::handleMessageSent);

  QObject::connect(ptr, &ChatModel::messagesCountReset, this, [this, ptr] {
    handleMessagesCountReset(ptr->getSipAddress());
  });
}

void SipAddressesModel::handleContactAdded (ContactModel *contact) {
  for (const auto &sipAddress : contact->getVcardModel()->getSipAddresses())
    addOrUpdateSipAddress(sipAddress.toString(), contact);
}

void SipAddressesModel::handleContactRemoved (const ContactModel *contact) {
  for (const auto &sipAddress : contact->getVcardModel()->getSipAddresses())
    removeContactOfSipAddress(sipAddress.toString());
}

void SipAddressesModel::handleSipAddressAdded (ContactModel *contact, const QString &sipAddress) {
  ContactModel *mappedContact = mapSipAddressToContact(sipAddress);
  if (mappedContact) {
    qWarning() << "Unable to map sip address" << sipAddress << "to" << contact << "- already used by" << mappedContact;
    return;
  }

  addOrUpdateSipAddress(sipAddress, contact);
}

void SipAddressesModel::handleSipAddressRemoved (ContactModel *contact, const QString &sipAddress) {
  ContactModel *mappedContact = mapSipAddressToContact(sipAddress);
  if (contact != mappedContact) {
    qWarning() << "Unable to remove sip address" << sipAddress << "of" << contact << "- already used by" << mappedContact;
    return;
  }

  removeContactOfSipAddress(sipAddress);
}

void SipAddressesModel::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &message) {
  const QString sipAddress = ::Utils::coreStringToAppString(message->getFromAddress()->asStringUriOnly());
  addOrUpdateSipAddress(sipAddress, message);
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
      ::Utils::coreStringToAppString(call->getRemoteAddress()->asStringUriOnly()), call
    );
}

void SipAddressesModel::handlePresenceReceived (
  const QString &sipAddress,
  const shared_ptr<const linphone::PresenceModel> &presenceModel
) {
  Presence::PresenceStatus status;

  switch (presenceModel->getConsolidatedPresence()) {
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

  auto it = mSipAddresses.find(sipAddress);
  if (it != mSipAddresses.end()) {
    qInfo() << QStringLiteral("Update presence of `%1`: %2.").arg(sipAddress).arg(status);
    (*it)["presenceStatus"] = status;

    int row = mRefs.indexOf(&(*it));
    Q_ASSERT(row != -1);
    emit dataChanged(index(row, 0), index(row, 0));
  }

  updateObservers(sipAddress, status);
}

void SipAddressesModel::handleAllEntriesRemoved (const QString &sipAddress) {
  auto it = mSipAddresses.find(sipAddress);
  if (it == mSipAddresses.end()) {
    qWarning() << QStringLiteral("Unable to found sip address: `%1`.").arg(sipAddress);
    return;
  }

  int row = mRefs.indexOf(&(*it));
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
    ::Utils::coreStringToAppString(message->getToAddress()->asStringUriOnly()),
    message
  );
}

void SipAddressesModel::handleMessagesCountReset (const QString &sipAddress) {
  auto it = mSipAddresses.find(sipAddress);
  if (it != mSipAddresses.end()) {
    (*it)["unreadMessagesCount"] = 0;

    int row = mRefs.indexOf(&(*it));
    Q_ASSERT(row != -1);
    emit dataChanged(index(row, 0), index(row, 0));
  }

  updateObservers(sipAddress, 0);
}

void SipAddressesModel::handlerIsComposingChanged (const shared_ptr<linphone::ChatRoom> &chatRoom) {
  auto it = mSipAddresses.find(::Utils::coreStringToAppString(chatRoom->getPeerAddress()->asStringUriOnly()));
  if (it != mSipAddresses.end()) {
    (*it)["isComposing"] = chatRoom->isRemoteComposing();

    int row = mRefs.indexOf(&(*it));
    Q_ASSERT(row != -1);
    emit dataChanged(index(row, 0), index(row, 0));
  }
}

// -----------------------------------------------------------------------------

void SipAddressesModel::addOrUpdateSipAddress (QVariantMap &map, ContactModel *contact) {
  QString sipAddress = map["sipAddress"].toString();

  if (contact)
    map["contact"] = QVariant::fromValue(contact);
  else if (map.remove("contact") == 0)
    qWarning() << QStringLiteral("`contact` field is empty on sip address: `%1`.").arg(sipAddress);

  updateObservers(sipAddress, contact);
}

void SipAddressesModel::addOrUpdateSipAddress (QVariantMap &map, const shared_ptr<linphone::Call> &call) {
  const shared_ptr<linphone::CallLog> callLog = call->getCallLog();

  map["timestamp"] = callLog->getStatus() == linphone::CallStatus::CallStatusSuccess
    ? QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000)
    : QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
}

void SipAddressesModel::addOrUpdateSipAddress (QVariantMap &map, const shared_ptr<linphone::ChatMessage> &message) {
  int count = message->getChatRoom()->getUnreadMessagesCount();

  map["timestamp"] = QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000);
  map["unreadMessagesCount"] = count;

  updateObservers(map["sipAddress"].toString(), count);
}

template<typename T>
void SipAddressesModel::addOrUpdateSipAddress (const QString &sipAddress, T data) {
  auto it = mSipAddresses.find(sipAddress);
  if (it != mSipAddresses.end()) {
    addOrUpdateSipAddress(*it, data);

    int row = mRefs.indexOf(&(*it));
    Q_ASSERT(row != -1);
    emit dataChanged(index(row, 0), index(row, 0));

    return;
  }

  QVariantMap map;
  map["sipAddress"] = sipAddress;
  addOrUpdateSipAddress(map, data);

  int row = mRefs.count();

  beginInsertRows(QModelIndex(), row, row);

  qInfo() << QStringLiteral("Add sip address: `%1`.").arg(sipAddress);

  mSipAddresses[sipAddress] = map;
  mRefs << &mSipAddresses[sipAddress];

  endInsertRows();
}

// -----------------------------------------------------------------------------

void SipAddressesModel::removeContactOfSipAddress (const QString &sipAddress) {
  auto it = mSipAddresses.find(sipAddress);
  if (it == mSipAddresses.end()) {
    qWarning() << QStringLiteral("Unable to remove unavailable sip address: `%1`.").arg(sipAddress);
    return;
  }

  // Try to map other contact on this sip address.
  ContactModel *contactModel = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(sipAddress);
  updateObservers(sipAddress, contactModel);

  qInfo() << QStringLiteral("Map new contact on sip address: `%1`.").arg(sipAddress) << contactModel;
  addOrUpdateSipAddress(*it, contactModel);

  int row = mRefs.indexOf(&(*it));
  Q_ASSERT(row != -1);

  // History exists, signal changes.
  if (it->contains("timestamp") || contactModel) {
    emit dataChanged(index(row, 0), index(row, 0));
    return;
  }

  // Remove sip address if no history.
  removeRow(row);
}

void SipAddressesModel::initSipAddresses () {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  // Get sip addresses from chatrooms.
  for (const auto &chatRoom : core->getChatRooms()) {
    list<shared_ptr<linphone::ChatMessage> > history = chatRoom->getHistory(0);

    if (history.size() == 0)
      continue;

    QString sipAddress = ::Utils::coreStringToAppString(chatRoom->getPeerAddress()->asStringUriOnly());

    QVariantMap map;
    map["sipAddress"] = sipAddress;
    map["timestamp"] = QDateTime::fromMSecsSinceEpoch(history.back()->getTime() * 1000);
    map["unreadMessagesCount"] = chatRoom->getUnreadMessagesCount();

    mSipAddresses[sipAddress] = map;
  }

  // Get sip addresses from calls.
  QSet<QString> addressDone;
  for (const auto &callLog : core->getCallLogs()) {
    const QString sipAddress = ::Utils::coreStringToAppString(callLog->getRemoteAddress()->asStringUriOnly());

    if (addressDone.contains(sipAddress))
      continue; // Already used.

    if (callLog->getStatus() == linphone::CallStatusAborted)
      continue; // Ignore aborted calls.

    addressDone << sipAddress;

    QVariantMap map;
    map["sipAddress"] = sipAddress;

    // The duration can be wrong if status is not success.
    map["timestamp"] = callLog->getStatus() == linphone::CallStatus::CallStatusSuccess
      ? QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000)
      : QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);

    auto it = mSipAddresses.find(sipAddress);
    if (it == mSipAddresses.end() || map["timestamp"] > (*it)["timestamp"])
      mSipAddresses[sipAddress] = map;
  }

  for (const auto &map : mSipAddresses) {
    qInfo() << QStringLiteral("Add sip address: `%1`.").arg(map["sipAddress"].toString());
    mRefs << &map;
  }

  // Get sip addresses from contacts.
  for (auto &contact : CoreManager::getInstance()->getContactsListModel()->mList)
    handleContactAdded(contact);
}

// -----------------------------------------------------------------------------

void SipAddressesModel::updateObservers (const QString &sipAddress, ContactModel *contact) {
  for (auto &observer : mObservers.values(sipAddress))
    observer->setContact(contact);
}

void SipAddressesModel::updateObservers (const QString &sipAddress, const Presence::PresenceStatus &presenceStatus) {
  for (auto &observer : mObservers.values(sipAddress))
    observer->setPresenceStatus(presenceStatus);
}

void SipAddressesModel::updateObservers (const QString &sipAddress, int messagesCount) {
  for (auto &observer : mObservers.values(sipAddress))
    observer->setUnreadMessagesCount(messagesCount);
}
