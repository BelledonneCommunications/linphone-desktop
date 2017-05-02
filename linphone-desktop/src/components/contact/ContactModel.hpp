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

  Q_PROPERTY(Presence::PresenceStatus presenceStatus READ getPresenceStatus NOTIFY presenceStatusChanged);
  Q_PROPERTY(Presence::PresenceLevel presenceLevel READ getPresenceLevel NOTIFY presenceLevelChanged);
  Q_PROPERTY(VcardModel * vcard READ getVcardModel WRITE setVcardModel NOTIFY contactUpdated);

  // Grant access to `mLinphoneFriend`.
  friend class ContactsListModel;
  friend class ContactsListProxyModel;
  friend class SmartSearchBarModel;

public:
  ContactModel (QObject *parent, std::shared_ptr<linphone::Friend> linphoneFriend);
  ContactModel (QObject *parent, VcardModel *vcardModel);
  ~ContactModel () = default;

  void refreshPresence ();

  Q_INVOKABLE void startEdit ();
  Q_INVOKABLE void endEdit ();
  Q_INVOKABLE void abortEdit ();

  VcardModel *getVcardModel () const;
  void setVcardModel (VcardModel *vcardModel);

signals:
  void contactUpdated ();

  void presenceStatusChanged (Presence::PresenceStatus status);
  void presenceLevelChanged (Presence::PresenceLevel level);
  void sipAddressAdded (const QString &sipAddress);
  void sipAddressRemoved (const QString &sipAddress);

private:
  Presence::PresenceStatus getPresenceStatus () const;
  Presence::PresenceLevel getPresenceLevel () const;

  QVariantList mOldSipAddresses;

  VcardModel *mVcardModel;
  std::shared_ptr<linphone::Friend> mLinphoneFriend;
};

Q_DECLARE_METATYPE(ContactModel *);

#endif // CONTACT_MODEL_H_
