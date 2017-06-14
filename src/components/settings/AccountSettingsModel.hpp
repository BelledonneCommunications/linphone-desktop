/*
 * AccountSettingsModel.hpp
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

#ifndef ACCOUNT_SETTINGS_MODEL_H_
#define ACCOUNT_SETTINGS_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class AccountSettingsModel : public QObject {
  Q_OBJECT;

  // Selected proxy config.
  Q_PROPERTY(QString username READ getUsername WRITE setUsername NOTIFY accountSettingsUpdated);
  Q_PROPERTY(QString sipAddress READ getSipAddress NOTIFY accountSettingsUpdated);
  Q_PROPERTY(RegistrationState registrationState READ getRegistrationState NOTIFY accountSettingsUpdated);

  // Default info.
  Q_PROPERTY(QString primaryDisplayName READ getPrimaryDisplayName WRITE setPrimaryDisplayName NOTIFY accountSettingsUpdated);
  Q_PROPERTY(QString primaryUsername READ getPrimaryUsername WRITE setPrimaryUsername NOTIFY accountSettingsUpdated);
  Q_PROPERTY(QString primarySipAddress READ getPrimarySipAddress NOTIFY accountSettingsUpdated);

  Q_PROPERTY(QVariantList accounts READ getAccounts NOTIFY accountSettingsUpdated);

public:
  enum RegistrationState {
    RegistrationStateRegistered,
    RegistrationStateNotRegistered,
    RegistrationStateInProgress
  };

  Q_ENUM(RegistrationState);

  AccountSettingsModel (QObject *parent = Q_NULLPTR);
  ~AccountSettingsModel () = default;

  bool addOrUpdateProxyConfig (const std::shared_ptr<linphone::ProxyConfig> &proxyConfig);

  Q_INVOKABLE QVariantMap getProxyConfigDescription (const std::shared_ptr<linphone::ProxyConfig> &proxyConfig);

  Q_INVOKABLE void setDefaultProxyConfig (const std::shared_ptr<linphone::ProxyConfig> &proxyConfig);

  Q_INVOKABLE bool addOrUpdateProxyConfig (const std::shared_ptr<linphone::ProxyConfig> &proxyConfig, const QVariantMap &data);
  Q_INVOKABLE void removeProxyConfig (const std::shared_ptr<linphone::ProxyConfig> &proxyConfig);

  Q_INVOKABLE std::shared_ptr<linphone::ProxyConfig> createProxyConfig ();

  Q_INVOKABLE void addAuthInfo (
    const std::shared_ptr<linphone::AuthInfo> &authInfo,
    const QString &password,
    const QString &userId
  );

  Q_INVOKABLE void eraseAllPasswords ();

signals:
  void accountSettingsUpdated ();

private:
  QString getUsername () const;
  void setUsername (const QString &username);

  QString getSipAddress () const;

  RegistrationState getRegistrationState () const;

  // ---------------------------------------------------------------------------

  QString getPrimaryUsername () const;
  void setPrimaryUsername (const QString &username);

  QString getPrimaryDisplayName () const;
  void setPrimaryDisplayName (const QString &displayName);

  QString getPrimarySipAddress () const;

  // ---------------------------------------------------------------------------

  QVariantList getAccounts () const;

  void setUsedSipAddress (const std::shared_ptr<const linphone::Address> &address);
  std::shared_ptr<const linphone::Address> getUsedSipAddress () const;

  // ---------------------------------------------------------------------------

  void handleRegistrationStateChanged (
    const std::shared_ptr<linphone::ProxyConfig> &proxyConfig,
    linphone::RegistrationState state
  );
};

Q_DECLARE_METATYPE(std::shared_ptr<linphone::ProxyConfig> );

#endif // ACCOUNT_SETTINGS_MODEL_H_
