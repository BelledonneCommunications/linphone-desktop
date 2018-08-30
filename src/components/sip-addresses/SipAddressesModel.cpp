/*
 * SipAddressesModel.cpp
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

#include <QDateTime>
#include <QElapsedTimer>
#include <QUrl>

#include "components/call/CallModel.hpp"
#include "components/chat/ChatModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "utils/LinphoneUtils.hpp"
#include "utils/Utils.hpp"

#include "SipAddressesModel.hpp"

// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------

static inline QVariantMap buildVariantMap (const SipAddressesModel::SipAddressEntry &sipAddressEntry) {
  return QVariantMap{
    { "sipAddress", sipAddressEntry.sipAddress },
    { "contact", QVariant::fromValue(sipAddressEntry.contact) },
    { "presenceStatus", sipAddressEntry.presenceStatus },
    { "__localToConferenceEntry", QVariant::fromValue(&sipAddressEntry.localAddressToConferenceEntry) }
  };
}

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
  QObject::connect(coreHandlers, &CoreHandlers::isComposingChanged, this, &SipAddressesModel::handleIsComposingChanged);
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
    return buildVariantMap(*mRefs[row]);

  return QVariant();
}

// -----------------------------------------------------------------------------

QVariantMap SipAddressesModel::find (const QString &sipAddress) const {
  auto it = mPeerAddressToSipAddressEntry.find(sipAddress);
  if (it == mPeerAddressToSipAddressEntry.end())
    return QVariantMap();

  return buildVariantMap(*it);
}

// -----------------------------------------------------------------------------

ContactModel *SipAddressesModel::mapSipAddressToContact (const QString &sipAddress) const {
  auto it = mPeerAddressToSipAddressEntry.find(sipAddress);
  return it == mPeerAddressToSipAddressEntry.end() ? nullptr : it->contact;
}

// -----------------------------------------------------------------------------

SipAddressObserver *SipAddressesModel::getSipAddressObserver (const QString &peerAddress, const QString &localAddress) {
  SipAddressObserver *model = new SipAddressObserver(peerAddress, localAddress);
  const QString cleanedPeerAddress = cleanSipAddress(peerAddress);
  const QString cleanedLocalAddress = cleanSipAddress(localAddress);

  auto it = mPeerAddressToSipAddressEntry.find(cleanedPeerAddress);
  if (it != mPeerAddressToSipAddressEntry.end()) {
    model->setContact(it->contact);
    model->setPresenceStatus(it->presenceStatus);

    auto it2 = it->localAddressToConferenceEntry.find(cleanedLocalAddress);
    if (it2 != it->localAddressToConferenceEntry.end())
      model->setUnreadMessageCount(it2->unreadMessageCount);
  }

  mObservers.insert(cleanedPeerAddress, model);
  QObject::connect(model, &SipAddressObserver::destroyed, this, [this, model, cleanedPeerAddress, cleanedLocalAddress]() {
    // Do not use `model` methods. `model` is partially destroyed here!
    if (mObservers.remove(cleanedPeerAddress, model) == 0)
      qWarning() << QStringLiteral("Unable to remove (%1, %2) from observers.")
        .arg(cleanedPeerAddress).arg(cleanedLocalAddress);
  });

  return model;
}

// -----------------------------------------------------------------------------

QString SipAddressesModel::getTransportFromSipAddress (const QString &sipAddress) {
  const shared_ptr<const linphone::Address> address = linphone::Factory::get()->createAddress(
    Utils::appStringToCoreString(sipAddress)
  );

  if (!address)
    return QString("");

  switch (address->getTransport()) {
    case linphone::TransportType::Udp:
      return QStringLiteral("UDP");
    case linphone::TransportType::Tcp:
      return QStringLiteral("TCP");
    case linphone::TransportType::Tls:
      return QStringLiteral("TLS");
    case linphone::TransportType::Dtls:
      return QStringLiteral("DTLS");
  }

  return QString("");
}

QString SipAddressesModel::addTransportToSipAddress (const QString &sipAddress, const QString &transport) {
  shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(
    Utils::appStringToCoreString(sipAddress)
  );

  if (!address)
    return QString("");

  address->setTransport(LinphoneUtils::stringToTransportType(transport.toUpper()));

  return Utils::coreStringToAppString(address->asString());
}

// -----------------------------------------------------------------------------

QString SipAddressesModel::interpretSipAddress (const QString &sipAddress, bool checkUsername) {
  shared_ptr<linphone::Address> lAddress = CoreManager::getInstance()->getCore()->interpretUrl(
    Utils::appStringToCoreString(sipAddress)
  );

  if (lAddress && (!checkUsername || !lAddress->getUsername().empty()))
    return Utils::coreStringToAppString(lAddress->asStringUriOnly());
  return QString("");
}

QString SipAddressesModel::interpretSipAddress (const QUrl &sipAddress) {
  return sipAddress.toString();
}

bool SipAddressesModel::addressIsValid (const QString &address) {
  return !!linphone::Factory::get()->createAddress(
    Utils::appStringToCoreString(address)
  );
}

bool SipAddressesModel::sipAddressIsValid (const QString &sipAddress) {
  shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(
    Utils::appStringToCoreString(sipAddress)
  );
  return address && !address->getUsername().empty();
}

QString SipAddressesModel::cleanSipAddress (const QString &sipAddress) {
  const int index = sipAddress.lastIndexOf('<');
  if (index == -1)
    return sipAddress;
  return sipAddress.mid(index + 1, sipAddress.lastIndexOf('>') - index - 1);
}

// -----------------------------------------------------------------------------

bool SipAddressesModel::removeRow (int row, const QModelIndex &parent) {
  return removeRows(row, 1, parent);
}

bool SipAddressesModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= mRefs.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i)
    mPeerAddressToSipAddressEntry.remove(mRefs.takeAt(row)->sipAddress);

  endRemoveRows();

  return true;
}

// -----------------------------------------------------------------------------

void SipAddressesModel::handleChatModelCreated (const shared_ptr<ChatModel> &chatModel) {
  ChatModel *ptr = chatModel.get();

  QObject::connect(ptr, &ChatModel::allEntriesRemoved, this, [this, ptr] {
    handleAllEntriesRemoved(ptr);
  });
  QObject::connect(ptr, &ChatModel::lastEntryRemoved, this, [this, ptr] {
    handleLastEntryRemoved(ptr);
  });
  QObject::connect(ptr, &ChatModel::messageCountReset, this, [this, ptr] {
    handleMessageCountReset(ptr);
  });

  QObject::connect(ptr, &ChatModel::messageSent, this, &SipAddressesModel::handleMessageSent);
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
  qInfo() << "Handle message received.";
  const QString peerAddress(Utils::coreStringToAppString(message->getChatRoom()->getPeerAddress()->asStringUriOnly()));
  addOrUpdateSipAddress(peerAddress, message);
}

void SipAddressesModel::handleCallStateChanged (
  const shared_ptr<linphone::Call> &call,
  linphone::Call::State state
) {
  // Ignore aborted calls.
  if (call->getCallLog()->getStatus() == linphone::Call::Status::Aborted)
    return;

  if (state == linphone::Call::State::End || state == linphone::Call::State::Error)
    addOrUpdateSipAddress(
      Utils::coreStringToAppString(call->getRemoteAddress()->asStringUriOnly()), call
    );
}

void SipAddressesModel::handlePresenceReceived (
  const QString &sipAddress,
  const shared_ptr<const linphone::PresenceModel> &presenceModel
) {
  Presence::PresenceStatus status;

  switch (presenceModel->getConsolidatedPresence()) {
    case linphone::ConsolidatedPresence::Online:
      status = Presence::PresenceStatus::Online;
      break;
    case linphone::ConsolidatedPresence::Busy:
      status = Presence::PresenceStatus::Busy;
      break;
    case linphone::ConsolidatedPresence::DoNotDisturb:
      status = Presence::PresenceStatus::DoNotDisturb;
      break;
    case linphone::ConsolidatedPresence::Offline:
      status = Presence::PresenceStatus::Offline;
      break;
  }

  auto it = mPeerAddressToSipAddressEntry.find(sipAddress);
  if (it != mPeerAddressToSipAddressEntry.end()) {
    qInfo() << QStringLiteral("Update presence of `%1`: %2.").arg(sipAddress).arg(status);
    it->presenceStatus = status;

    int row = mRefs.indexOf(&(*it));
    Q_ASSERT(row != -1);
    emit dataChanged(index(row, 0), index(row, 0));
  }

  updateObservers(sipAddress, status);
}

void SipAddressesModel::handleAllEntriesRemoved (ChatModel *chatModel) {
  auto it = mPeerAddressToSipAddressEntry.find(chatModel->getPeerAddress());
  if (it == mPeerAddressToSipAddressEntry.end())
    return;

  auto it2 = it->localAddressToConferenceEntry.find(chatModel->getLocalAddress());
  if (it2 == it->localAddressToConferenceEntry.end())
    return;
  it->localAddressToConferenceEntry.erase(it2);

  int row = mRefs.indexOf(&(*it));
  Q_ASSERT(row != -1);

  // No history, no contact => Remove sip address from list.
  if (!it->contact && it->localAddressToConferenceEntry.empty()) {
    removeRow(row);
    return;
  }

  emit dataChanged(index(row, 0), index(row, 0));
}

void SipAddressesModel::handleLastEntryRemoved (ChatModel *chatModel) {
  auto it = mPeerAddressToSipAddressEntry.find(chatModel->getPeerAddress());
  if (it == mPeerAddressToSipAddressEntry.end())
    return;

  auto it2 = it->localAddressToConferenceEntry.find(chatModel->getLocalAddress());
  if (it2 == it->localAddressToConferenceEntry.end())
    return;

  int row = mRefs.indexOf(&(*it));
  Q_ASSERT(row != -1);

  Q_ASSERT(chatModel->rowCount() > 0);
  const QVariantMap map = chatModel->data(
    chatModel->index(chatModel->rowCount() - 1, 0),
    ChatModel::ChatEntry
  ).toMap();

  // Update the timestamp with the new last chat message timestamp.
  it2->timestamp = map["timestamp"].toDateTime();
  emit dataChanged(index(row, 0), index(row, 0));
}

void SipAddressesModel::handleMessageCountReset (ChatModel *chatModel) {
  const QString &peerAddress = chatModel->getPeerAddress();
  auto it = mPeerAddressToSipAddressEntry.find(peerAddress);
  if (it == mPeerAddressToSipAddressEntry.end())
    return;

  const QString &localAddress = chatModel->getLocalAddress();
  auto it2 = it->localAddressToConferenceEntry.find(localAddress);
  if (it2 == it->localAddressToConferenceEntry.end())
    return;

  it2->unreadMessageCount = 0;

  int row = mRefs.indexOf(&(*it));
  Q_ASSERT(row != -1);
  emit dataChanged(index(row, 0), index(row, 0));

  updateObservers(peerAddress, localAddress, 0);
}

void SipAddressesModel::handleMessageSent (const shared_ptr<linphone::ChatMessage> &message) {
  qInfo() << "Handle message sent.";
  const QString peerAddress(Utils::coreStringToAppString(message->getChatRoom()->getPeerAddress()->asStringUriOnly()));
  addOrUpdateSipAddress(peerAddress, message);
}

void SipAddressesModel::handleIsComposingChanged (const shared_ptr<linphone::ChatRoom> &chatRoom) {
  auto it = mPeerAddressToSipAddressEntry.find(
    Utils::coreStringToAppString(chatRoom->getPeerAddress()->asStringUriOnly())
  );
  if (it == mPeerAddressToSipAddressEntry.end())
    return;

  auto it2 = it->localAddressToConferenceEntry.find(
    Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly())
  );
  if (it2 == it->localAddressToConferenceEntry.end())
    return;

  it2->isComposing = chatRoom->isRemoteComposing();

  int row = mRefs.indexOf(&(*it));
  Q_ASSERT(row != -1);
  emit dataChanged(index(row, 0), index(row, 0));
}

// -----------------------------------------------------------------------------

void SipAddressesModel::addOrUpdateSipAddress (SipAddressEntry &sipAddressEntry, ContactModel *contact) {
  const QString &sipAddress = sipAddressEntry.sipAddress;

  if (contact)
    sipAddressEntry.contact = contact;
  else if (!sipAddressEntry.contact)
    qWarning() << QStringLiteral("`contact` field is empty on sip address: `%1`.").arg(sipAddress);

  updateObservers(sipAddress, contact);
}

void SipAddressesModel::addOrUpdateSipAddress (SipAddressEntry &sipAddressEntry, const shared_ptr<linphone::Call> &call) {
  const shared_ptr<linphone::CallLog> callLog = call->getCallLog();
  sipAddressEntry.localAddressToConferenceEntry[
    Utils::coreStringToAppString(callLog->getLocalAddress()->asStringUriOnly())
  ].timestamp = callLog->getStatus() == linphone::Call::Status::Success
    ? QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000)
    : QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
}

void SipAddressesModel::addOrUpdateSipAddress (SipAddressEntry &sipAddressEntry, const shared_ptr<linphone::ChatMessage> &message) {
  shared_ptr<linphone::ChatRoom> chatRoom(message->getChatRoom());
  int count = chatRoom->getUnreadMessagesCount();

  QString localAddress(Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly()));
  qInfo() << QStringLiteral("Update (`%1`, `%2`) from chat message.").arg(sipAddressEntry.sipAddress, localAddress);

  ConferenceEntry &conferenceEntry = sipAddressEntry.localAddressToConferenceEntry[localAddress];
  conferenceEntry.timestamp = QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000);
  conferenceEntry.unreadMessageCount = count;

  updateObservers(sipAddressEntry.sipAddress, localAddress, count);
}

template<typename T>
void SipAddressesModel::addOrUpdateSipAddress (const QString &sipAddress, T data) {
  auto it = mPeerAddressToSipAddressEntry.find(sipAddress);
  if (it != mPeerAddressToSipAddressEntry.end()) {
    addOrUpdateSipAddress(*it, data);

    int row = mRefs.indexOf(&(*it));
    Q_ASSERT(row != -1);
    emit dataChanged(index(row, 0), index(row, 0));

    return;
  }

  SipAddressEntry sipAddressEntry{ sipAddress, nullptr, Presence::Offline, {} };
  addOrUpdateSipAddress(sipAddressEntry, data);

  int row = mRefs.count();

  beginInsertRows(QModelIndex(), row, row);

  mPeerAddressToSipAddressEntry[sipAddress] = move(sipAddressEntry);
  mRefs << &mPeerAddressToSipAddressEntry[sipAddress];

  endInsertRows();
}

// -----------------------------------------------------------------------------

void SipAddressesModel::removeContactOfSipAddress (const QString &sipAddress) {
  auto it = mPeerAddressToSipAddressEntry.find(sipAddress);
  if (it == mPeerAddressToSipAddressEntry.end()) {
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

  // History or contact exists, signal changes.
  if (!it->localAddressToConferenceEntry.empty() || contactModel) {
    emit dataChanged(index(row, 0), index(row, 0));
    return;
  }

  // Remove sip address if no history.
  removeRow(row);
}

// -----------------------------------------------------------------------------

void SipAddressesModel::initSipAddresses () {
  QElapsedTimer timer;
  timer.start();

  initSipAddressesFromChat();
  initSipAddressesFromCalls();
  initRefs();
  initSipAddressesFromContacts();

  qInfo() << "Sip addresses model initialized in:" << timer.elapsed() << "ms.";
}

void SipAddressesModel::initSipAddressesFromChat () {
  for (const auto &chatRoom : CoreManager::getInstance()->getCore()->getChatRooms()) {
    list<shared_ptr<linphone::ChatMessage>> history(chatRoom->getHistory(1));
    if (history.empty())
      continue;

    QString peerAddress(Utils::coreStringToAppString(chatRoom->getPeerAddress()->asStringUriOnly()));
    QString localAddress(Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly()));

    getSipAddressEntry(peerAddress)->localAddressToConferenceEntry[localAddress] = {
      chatRoom->getUnreadMessagesCount(),
      false,
      QDateTime::fromMSecsSinceEpoch(history.back()->getTime() * 1000)
    };
  }
}

void SipAddressesModel::initSipAddressesFromCalls () {
  using ConferenceId = QPair<QString, QString>;
  QSet<ConferenceId> conferenceDone;
  for (const auto &callLog : CoreManager::getInstance()->getCore()->getCallLogs()) {
    const QString peerAddress(Utils::coreStringToAppString(callLog->getRemoteAddress()->asStringUriOnly()));
    const QString localAddress(Utils::coreStringToAppString(callLog->getLocalAddress()->asStringUriOnly()));

    switch (callLog->getStatus()) {
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

    ConferenceId conferenceId{ peerAddress, localAddress };
    if (conferenceDone.contains(conferenceId))
      continue; // Already used.
    conferenceDone << conferenceId;

    // The duration can be wrong if status is not success.
    QDateTime timestamp(callLog->getStatus() == linphone::Call::Status::Success
      ? QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000)
      : QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000));

    auto &localToConferenceEntry = getSipAddressEntry(peerAddress)->localAddressToConferenceEntry;
    auto it = localToConferenceEntry.find(localAddress);
    if (it == localToConferenceEntry.end())
      localToConferenceEntry[localAddress] = { 0, false, move(timestamp) };
    else if (it->timestamp.isNull() || timestamp > it->timestamp)
      it->timestamp = move(timestamp);
  }
}

void SipAddressesModel::initSipAddressesFromContacts () {
  for (auto &contact : CoreManager::getInstance()->getContactsListModel()->mList)
    handleContactAdded(contact);
}

void SipAddressesModel::initRefs () {
  for (const auto &sipAddressEntry : mPeerAddressToSipAddressEntry)
    mRefs << &sipAddressEntry;
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

void SipAddressesModel::updateObservers (const QString &peerAddress, const QString &localAddress, int messageCount) {
  for (auto &observer : mObservers.values(peerAddress))
    if (observer->getLocalAddress() == localAddress) {
      observer->setUnreadMessageCount(messageCount);
      return;
    }
}
