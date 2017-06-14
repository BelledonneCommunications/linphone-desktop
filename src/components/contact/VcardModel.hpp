/*
 * VcardModel.hpp
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

#ifndef VCARD_MODEL_H_
#define VCARD_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class VcardModel : public QObject {
  friend class ContactModel; // Grant access to `mVcard`.

  Q_OBJECT;

  Q_PROPERTY(QString username READ getUsername WRITE setUsername NOTIFY vcardUpdated);
  Q_PROPERTY(QString avatar READ getAvatar WRITE setAvatar NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantMap address READ getAddress NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList sipAddresses READ getSipAddresses NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList companies READ getCompanies NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList emails READ getEmails NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList urls READ getUrls NOTIFY vcardUpdated);

  // ---------------------------------------------------------------------------

public:
  VcardModel (std::shared_ptr<linphone::Vcard> vcard, bool isReadOnly = true);

  ~VcardModel ();

  // ---------------------------------------------------------------------------

  bool getIsReadOnly () const {
    return mIsReadOnly;
  }

  // ---------------------------------------------------------------------------

  QString getAvatar () const;
  bool setAvatar (const QString &path);

  QString getUsername () const;
  void setUsername (const QString &username);

  // ---------------------------------------------------------------------------

  QVariantList getSipAddresses () const;
  QVariantMap getAddress () const;
  QVariantList getEmails () const;
  QVariantList getCompanies () const;
  QVariantList getUrls () const;

  // ---------------------------------------------------------------------------

  Q_INVOKABLE bool addSipAddress (const QString &sipAddress);
  Q_INVOKABLE void removeSipAddress (const QString &sipAddress);
  Q_INVOKABLE bool updateSipAddress (const QString &oldSipAddress, const QString &sipAddress);

  Q_INVOKABLE bool addCompany (const QString &company);
  Q_INVOKABLE void removeCompany (const QString &company);
  Q_INVOKABLE bool updateCompany (const QString &oldCompany, const QString &company);

  Q_INVOKABLE bool addEmail (const QString &email);
  Q_INVOKABLE void removeEmail (const QString &email);
  Q_INVOKABLE bool updateEmail (const QString &oldEmail, const QString &email);

  Q_INVOKABLE bool addUrl (const QString &url);
  Q_INVOKABLE void removeUrl (const QString &url);
  Q_INVOKABLE bool updateUrl (const QString &oldUrl, const QString &url);

  Q_INVOKABLE void setStreet (const QString &street);
  Q_INVOKABLE void setLocality (const QString &locality);
  Q_INVOKABLE void setPostalCode (const QString &postalCode);
  Q_INVOKABLE void setCountry (const QString &country);

  // ---------------------------------------------------------------------------

signals:
  void vcardUpdated ();

  // ---------------------------------------------------------------------------

private:
  bool mIsReadOnly = true;
  bool mAvatarIsReadOnly = true;

  std::shared_ptr<linphone::Vcard> mVcard;
};

Q_DECLARE_METATYPE(VcardModel *);

#endif // VCARD_MODEL_H_
