/*
 * SipAddressesModel.hpp
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

#ifndef SIP_ADDRESSES_MODEL_H_
#define SIP_ADDRESSES_MODEL_H_

#include "../chat/ChatModel.hpp"
#include "../contact/ContactModel.hpp"
#include "SipAddressObserver.hpp"

#include <QAbstractListModel>

// =============================================================================

class CoreHandlers;

class SipAddressesModel : public QAbstractListModel {
  Q_OBJECT;

public:
  SipAddressesModel (QObject *parent = Q_NULLPTR);
  ~SipAddressesModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

  void connectToChatModel (ChatModel *chat_model);

  Q_INVOKABLE ContactModel *mapSipAddressToContact (const QString &sip_address) const;
  Q_INVOKABLE SipAddressObserver *getSipAddressObserver (const QString &sip_address);

  Q_INVOKABLE QString interpretUrl (const QString &sip_address) const;

private:
  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  // ---------------------------------------------------------------------------

  void handleContactAdded (ContactModel *contact);
  void handleContactRemoved (const ContactModel *contact);

  void handleSipAddressAdded (ContactModel *contact, const QString &sip_address);
  void handleSipAddressRemoved (ContactModel *contact, const QString &sip_address);

  void handleMessageReceived (const std::shared_ptr<linphone::ChatMessage> &message);
  void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::CallState state);
  void handlePresenceReceived (const QString &sip_address, const shared_ptr<const linphone::PresenceModel> &presence_model);

  // ---------------------------------------------------------------------------

  // A sip address exists in this list if a contact is linked to it, or a call, or a message.

  void addOrUpdateSipAddress (QVariantMap &map, ContactModel *contact);
  void addOrUpdateSipAddress (QVariantMap &map, const std::shared_ptr<linphone::Call> &call);
  void addOrUpdateSipAddress (QVariantMap &map, const std::shared_ptr<linphone::ChatMessage> &message);

  template<class T>
  void addOrUpdateSipAddress (const QString &sip_address, T data);

  // ---------------------------------------------------------------------------

  void removeContactOfSipAddress (const QString &sip_address);

  void initSipAddresses ();

  void updateObservers (const QString &sip_address, ContactModel *contact);
  void updateObservers (const QString &sip_address, const Presence::PresenceStatus &presence_status);

  QHash<QString, QVariantMap> m_sip_addresses;
  QList<const QVariantMap *> m_refs;

  QMultiHash<QString, SipAddressObserver *> m_observers;

  std::shared_ptr<CoreHandlers> m_core_handlers;
};

#endif // SIP_ADDRESSES_MODEL_H_
