/*
 * SipAddressObserver.hpp
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
 *  Created on: March 28, 2017
 *      Author: Ronan Abhamon
 */

#ifndef SIP_ADDRESS_OBSERVER_H_
#define SIP_ADDRESS_OBSERVER_H_

#include "../contact/ContactModel.hpp"

// =============================================================================

class SipAddressObserver : public QObject {
  friend class SipAddressesModel;

  Q_OBJECT;

  Q_PROPERTY(QString sipAddress READ getSipAddress CONSTANT);

  Q_PROPERTY(ContactModel * contact READ getContact NOTIFY contactChanged);
  Q_PROPERTY(Presence::PresenceStatus presenceStatus READ getPresenceStatus NOTIFY presenceStatusChanged);

public:
  SipAddressObserver (const QString &sip_address);
  ~SipAddressObserver () = default;

signals:
  void contactChanged (ContactModel *contact);
  void presenceStatusChanged (const Presence::PresenceStatus &presenceStatus);

private:
  QString getSipAddress () const {
    return m_sip_address;
  }

  ContactModel *getContact () const {
    return m_contact;
  }

  void setContact (ContactModel *contact);

  Presence::PresenceStatus getPresenceStatus () const {
    return m_presence_status;
  }

  void setPresenceStatus (const Presence::PresenceStatus &presence_status);

  QString m_sip_address;

  ContactModel *m_contact = nullptr;
  Presence::PresenceStatus m_presence_status = Presence::PresenceStatus::Offline;
};

Q_DECLARE_METATYPE(SipAddressObserver *);

#endif // SIP_ADDRESS_OBSERVER_H_
