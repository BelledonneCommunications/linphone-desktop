/*
 * AssistantModel.hpp
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
 *  Created on: April 6, 2017
 *      Author: Ronan Abhamon
 */

#ifndef ASSISTANT_MODEL_H_
#define ASSISTANT_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class AssistantModel : public QObject {
  class Handlers;

  Q_OBJECT;

  Q_PROPERTY(QString email READ getEmail WRITE setEmail NOTIFY emailChanged);
  Q_PROPERTY(QString password READ getPassword WRITE setPassword NOTIFY passwordChanged);
  Q_PROPERTY(QString countryCode READ getCountryCode WRITE setCountryCode NOTIFY countryCodeChanged);
  Q_PROPERTY(QString phoneNumber READ getPhoneNumber WRITE setPhoneNumber NOTIFY phoneNumberChanged);
  Q_PROPERTY(QString username READ getUsername WRITE setUsername NOTIFY usernameChanged);
  Q_PROPERTY(QString displayName READ getDisplayName WRITE setDisplayName NOTIFY displayNameChanged);
  Q_PROPERTY(QString activationCode READ getActivationCode WRITE setActivationCode NOTIFY activationCodeChanged);
  Q_PROPERTY(QString configFilename READ getConfigFilename WRITE setConfigFilename NOTIFY configFilenameChanged);

public:
  AssistantModel (QObject *parent = Q_NULLPTR);

  Q_INVOKABLE void activate ();
  Q_INVOKABLE void create ();
  Q_INVOKABLE void login ();

  Q_INVOKABLE void reset ();

  Q_INVOKABLE bool addOtherSipAccount (const QVariantMap &map);

signals:
  void emailChanged (const QString &email, const QString &error);
  void passwordChanged (const QString &password, const QString &error);
  void countryCodeChanged (const QString &countryCode);
  void phoneNumberChanged (const QString &phoneNumber, const QString &error);
  void usernameChanged (const QString &username, const QString &error);
  void displayNameChanged (const QString &displayName, const QString &error);
  void activationCodeChanged (const QString &activationCode);

  void activateStatusChanged (const QString &error);
  void createStatusChanged (const QString &error);
  void loginStatusChanged (const QString &error);
  void recoverStatusChanged (const QString &error);

  void configFilenameChanged (const QString &configFilename);

private:
  QString getEmail () const;
  void setEmail (const QString &email);

  QString getPassword () const;
  void setPassword (const QString &password);

  QString getCountryCode () const;
  void setCountryCode (const QString &countryCode);

  QString getPhoneNumber () const;
  void setPhoneNumber (const QString &phoneNumber);

  QString getUsername () const;
  void setUsername (const QString &username);

  QString getDisplayName () const;
  void setDisplayName (const QString &displayName);

  QString getActivationCode () const;
  void setActivationCode (const QString &activationCode);

  QString getConfigFilename () const;
  void setConfigFilename (const QString &configFilename);

  QString mapAccountCreatorUsernameStatusToString (linphone::AccountCreatorUsernameStatus status) const;

  QString mCountryCode;
  QString mConfigFilename;

  std::shared_ptr<linphone::AccountCreator> mAccountCreator;
  std::shared_ptr<Handlers> mHandlers;
};

#endif // ASSISTANT_MODEL_H_
