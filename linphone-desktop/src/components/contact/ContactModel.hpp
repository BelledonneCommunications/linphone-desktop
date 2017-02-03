/*
 * ContactModel.hpp
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

#ifndef CONTACT_MODEL_H_
#define CONTACT_MODEL_H_

#include "../presence/Presence.hpp"
#include "VcardModel.hpp"

// =============================================================================

class ContactModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(Presence::PresenceStatus presenceStatus READ getPresenceStatus NOTIFY contactUpdated);
  Q_PROPERTY(Presence::PresenceLevel presenceLevel READ getPresenceLevel NOTIFY contactUpdated);
  Q_PROPERTY(VcardModel * vcard READ getVcardModelPtr NOTIFY contactUpdated);

  friend class ContactsListModel;
  friend class ContactsListProxyModel;
  friend class SmartSearchBarModel;

public:
  ContactModel (std::shared_ptr<linphone::Friend> linphone_friend);
  ContactModel (VcardModel *vcard);
  ~ContactModel () = default;

  std::shared_ptr<VcardModel> getVcardModel () const {
    return m_vcard;
  }

  Q_INVOKABLE void startEdit ();
  Q_INVOKABLE void endEdit ();
  Q_INVOKABLE void abortEdit ();

signals:
  void contactUpdated ();
  void sipAddressAdded (const QString &sip_address);
  void sipAddressRemoved (const QString &sip_address);

private:
  Presence::PresenceStatus getPresenceStatus () const;
  Presence::PresenceLevel getPresenceLevel () const;

  VcardModel *getVcardModelPtr () const {
    return m_vcard.get();
  }

  QVariantList m_old_sip_addresses;

  std::shared_ptr<VcardModel> m_vcard;
  std::shared_ptr<linphone::Friend> m_linphone_friend;
};

Q_DECLARE_METATYPE(ContactModel *);

#endif // CONTACT_MODEL_H_
