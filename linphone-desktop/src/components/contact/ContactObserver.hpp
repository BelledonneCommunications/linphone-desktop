/*
 * ContactObserver.hpp
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

#ifndef CONTACT_OBSERVER_H_
#define CONTACT_OBSERVER_H_

#include <QObject>

// =============================================================================

class ContactModel;

class ContactObserver : public QObject {
  friend class SipAddressesModel;

  Q_OBJECT;

  Q_PROPERTY(QString sipAddress READ getSipAddress CONSTANT);
  Q_PROPERTY(ContactModel * contact READ getContact NOTIFY contactChanged);

public:
  ContactObserver (const QString &sip_address);
  ~ContactObserver () = default;

  ContactModel *getContact () const {
    return m_contact;
  }

signals:
  void contactChanged (ContactModel *contact);

private:
  QString getSipAddress () const {
    return m_sip_address;
  }

  void setContact (ContactModel *contact);

  QString m_sip_address;
  ContactModel *m_contact = nullptr;
};

Q_DECLARE_METATYPE(ContactObserver *);

#endif // CONTACT_OBSERVER_H_
