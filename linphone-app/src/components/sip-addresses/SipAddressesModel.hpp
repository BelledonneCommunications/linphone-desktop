/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef SIP_ADDRESSES_MODEL_H_
#define SIP_ADDRESSES_MODEL_H_

#include <QAbstractListModel>
#include <QDateTime>

#include "SipAddressObserver.hpp"

// =============================================================================

class QUrl;

class ChatModel;
class CoreHandlers;
class HistoryModel;

class SipAddressesModel : public QAbstractListModel {
  Q_OBJECT;

public:
  struct ConferenceEntry {
    int unreadMessageCount;
    int missedCallCount;
    bool isComposing;
    QDateTime timestamp;
  };

  struct SipAddressEntry {
    QString sipAddress;
    ContactModel *contact;
    Presence::PresenceStatus presenceStatus;
    QHash<QString, ConferenceEntry> localAddressToConferenceEntry;
  };

  SipAddressesModel (QObject *parent = Q_NULLPTR);
  
  void reset();

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

  Q_INVOKABLE QVariantMap find (const QString &sipAddress) const;
  Q_INVOKABLE ContactModel *mapSipAddressToContact (const QString &sipAddress) const;
  Q_INVOKABLE SipAddressObserver *getSipAddressObserver (const QString &peerAddress, const QString &localAddress);

  // ---------------------------------------------------------------------------
  // Sip addresses helpers.
  // ---------------------------------------------------------------------------

  Q_INVOKABLE static QString getTransportFromSipAddress (const QString &sipAddress);
  Q_INVOKABLE static QString addTransportToSipAddress (const QString &sipAddress, const QString &transport);

  Q_INVOKABLE static QString interpretSipAddress (const QString &sipAddress, bool checkUsername = true);
  Q_INVOKABLE static QString interpretSipAddress (const QUrl &sipAddress);
  Q_INVOKABLE static QString interpretSipAddress (const QString &sipAddress, const QString &domain);

  Q_INVOKABLE static bool addressIsValid (const QString &address);
  Q_INVOKABLE static bool sipAddressIsValid (const QString &sipAddress);

  Q_INVOKABLE static QString cleanSipAddress (const QString &sipAddress);

  // ---------------------------------------------------------------------------
signals:
  void sipAddressReset();// The model has been reset
 
public slots:
  void handleAllCallCountReset ();

private:
  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  // ---------------------------------------------------------------------------

  void handleChatModelCreated (const std::shared_ptr<ChatModel> &chatModel);
  void handleHistoryModelCreated (HistoryModel *historyModel) ;

  void handleContactAdded (ContactModel *contact);
  void handleContactRemoved (const ContactModel *contact);

  void handleSipAddressAdded (ContactModel *contact, const QString &sipAddress);
  void handleSipAddressRemoved (ContactModel *contact, const QString &sipAddress);

  void handleMessageReceived (const std::shared_ptr<linphone::ChatMessage> &message);
  void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);
  void handlePresenceReceived (const QString &sipAddress, const std::shared_ptr<const linphone::PresenceModel> &presenceModel);

  void handleAllEntriesRemoved (ChatModel *chatModel);
  void handleLastEntryRemoved (ChatModel *chatModel);
  
  void handleMessageCountReset (ChatModel *chatModel);

  void handleMessageSent (const std::shared_ptr<linphone::ChatMessage> &message);

  void handleIsComposingChanged (const std::shared_ptr<linphone::ChatRoom> &chatRoom);

  // ---------------------------------------------------------------------------

  // A sip address exists in this list if a contact is linked to it, or a call, or a message.

  void addOrUpdateSipAddress (SipAddressEntry &sipAddressEntry, ContactModel *contact);
  void addOrUpdateSipAddress (SipAddressEntry &sipAddressEntry, const std::shared_ptr<linphone::Call> &call);
  void addOrUpdateSipAddress (SipAddressEntry &sipAddressEntry, const std::shared_ptr<linphone::ChatMessage> &message);


  //NMN TODO bind to missedCall event and implement void addOrUpdateSipAddress

  template<class T>
  void addOrUpdateSipAddress (const QString &sipAddress, T data);

  // ---------------------------------------------------------------------------

  void removeContactOfSipAddress (const QString &sipAddress);

  void initSipAddresses ();

  void initSipAddressesFromChat ();
  void initSipAddressesFromCalls ();
  void initSipAddressesFromContacts ();

  void initRefs ();

  void updateObservers (const QString &sipAddress, ContactModel *contact);
  void updateObservers (const QString &sipAddress, const Presence::PresenceStatus &presenceStatus);
  void updateObservers (const QString &peerAddress, const QString &localAddress, int messageCount, int missedCallCount);

  // ---------------------------------------------------------------------------

  SipAddressEntry *getSipAddressEntry (const QString &peerAddress) {
    auto it = mPeerAddressToSipAddressEntry.find(peerAddress);
    if (it == mPeerAddressToSipAddressEntry.end())
      it = mPeerAddressToSipAddressEntry.insert(peerAddress, { peerAddress, nullptr, Presence::Offline, {} });
    return &(*it);
  }
  QHash<QString, SipAddressEntry> mPeerAddressToSipAddressEntry;
  QList<const SipAddressEntry *> mRefs;

  QMultiHash<QString, SipAddressObserver *> mObservers;

  std::shared_ptr<CoreHandlers> mCoreHandlers;
};

using LocalAddressToConferenceEntry = QHash<QString, SipAddressesModel::ConferenceEntry>;
Q_DECLARE_METATYPE(const LocalAddressToConferenceEntry *);

#endif // SIP_ADDRESSES_MODEL_H_
