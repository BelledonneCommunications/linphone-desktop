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

#ifndef ASSISTANT_MODEL_H_
#define ASSISTANT_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================
#ifdef ENABLE_OAUTH2
class OAuth2Model;
#endif

class AssistantModel : public QObject {
	class Handlers;
	
	Q_OBJECT
	
	Q_PROPERTY(QString email READ getEmail WRITE setEmail NOTIFY emailChanged)
	Q_PROPERTY(QString password READ getPassword WRITE setPassword NOTIFY passwordChanged)
	Q_PROPERTY(QString countryCode READ getCountryCode WRITE setCountryCode NOTIFY countryCodeChanged)
	Q_PROPERTY(QString phoneNumber READ getPhoneNumber WRITE setPhoneNumber NOTIFY phoneNumberChanged)
	Q_PROPERTY(QString phoneCountryCode READ getPhoneCountryCode WRITE setPhoneCountryCode NOTIFY phoneCountryCodeChanged)
	Q_PROPERTY(QString computedPhoneNumber READ getComputedPhoneNumber NOTIFY computedPhoneNumberChanged)
	
	Q_PROPERTY(QString username READ getUsername WRITE setUsername NOTIFY usernameChanged)
	Q_PROPERTY(QString displayName READ getDisplayName WRITE setDisplayName NOTIFY displayNameChanged)
	Q_PROPERTY(QString activationCode READ getActivationCode WRITE setActivationCode NOTIFY activationCodeChanged)
	Q_PROPERTY(QString configFilename READ getConfigFilename WRITE setConfigFilename NOTIFY configFilenameChanged)
	Q_PROPERTY(bool isReadingQRCode READ getIsReadingQRCode WRITE setIsReadingQRCode NOTIFY isReadingQRCodeChanged)
	Q_PROPERTY(bool isProcessing READ getIsProcessing WRITE setIsProcessing NOTIFY isProcessingChanged)
	Q_PROPERTY(bool usePhoneNumber READ getUsePhoneNumber WRITE setUsePhoneNumber NOTIFY usePhoneNumberChanged)
	
	
public:
	AssistantModel (QObject *parent = Q_NULLPTR);
	virtual ~AssistantModel();
	
	Q_INVOKABLE void activate ();
	Q_INVOKABLE void create ();
	Q_INVOKABLE void login ();
	
	Q_INVOKABLE void reset ();
	
	Q_INVOKABLE bool addOtherSipAccount (const QVariantMap &map);
	
	Q_INVOKABLE void createTestAccount();
	Q_INVOKABLE void generateQRCode();
	Q_INVOKABLE void requestQRCode();
	Q_INVOKABLE void readQRCode();
	Q_INVOKABLE void requestOauth2();
	
	Q_INVOKABLE void attachAccount(const QString& token);
	
	Q_INVOKABLE static bool isOAuth2Available();
	
	void checkLinkingAccount();
	
public slots:
	void onQRCodeFound(const std::string & result);
	void onApiReceived(QString apiKey);
	void newQRCodeNotReceivedTest();
	
signals:
	void emailChanged (const QString &email, const QString &error);
	void passwordChanged (const QString &password, const QString &error);
	void countryCodeChanged (const QString &countryCode);
	void usePhoneNumberChanged();
	void phoneNumberChanged (const QString &phoneNumber, const QString &error);
	void phoneCountryCodeChanged();
	void computedPhoneNumberChanged();
	void usernameChanged (const QString &username, const QString &error);
	void displayNameChanged (const QString &displayName, const QString &error);
	void activationCodeChanged (const QString &activationCode);
	void isProcessingChanged();
	
	void activateStatusChanged (const QString &error);
	void createStatusChanged (const QString &error);
	void loginStatusChanged (const QString &error);
	void recoverStatusChanged (const QString &error);
	void oauth2RequestFailed(const QString& error);
	
	void oauth2StatusChanged(const QString& status);
	void oauth2AuthenticationGranted();
	
	void configFilenameChanged (const QString &configFilename);
	
	void newQRCodeReceived(QString code);// code for QRCode generation.
	void newQRCodeNotReceived(QString message, int errorCode);// The QRCode couldn't be generated. Return HTTP error code.
	void provisioningTokenReceived(QString token);// Provisioning token to use
	void isReadingQRCodeChanged();
	void qRCodeFound(QString token);
	
	void qRCodeAttached();
	void qRCodeNotAttached(QString message, int errorCode);
	void apiReceived(QString apiKey);
	
private:
	QString getEmail () const;
	void setEmail (const QString &email);
	
	QString getPassword () const;
	void setPassword (const QString &password);
	
	QString getCountryCode () const;
	void setCountryCode (const QString &countryCode);
	
	bool getUsePhoneNumber() const;
	void setUsePhoneNumber(bool use);
	
	QString getPhoneNumber () const;
	QString getComputedPhoneNumber () const;
	void setPhoneNumber (const QString &phoneNumber);
	
	QString getPhoneCountryCode () const;
	void setPhoneCountryCode (const QString &code);
	
	QString getUsername () const;
	void setUsername (const QString &username);
	
	QString getDisplayName () const;
	void setDisplayName (const QString &displayName);
	
	QString getActivationCode () const;
	void setActivationCode (const QString &activationCode);
	
	QString getConfigFilename () const;
	void setConfigFilename (const QString &configFilename);
	
	bool getIsReadingQRCode() const;
	void setIsReadingQRCode(bool isReading);
	
	bool getIsProcessing() const;
	void setIsProcessing(bool isProcessing);
	
	
	QString mapAccountCreatorUsernameStatusToString (linphone::AccountCreator::UsernameStatus status) const;
	
	QString mCountryCode;
	QString mConfigFilename;
	QString mToken;
	QString mPhoneCountryCode;
	QString mPhoneNumber;
	bool mIsReadingQRCode;
	bool mIsProcessing;
	bool mUsePhoneNumber = false;
	
	std::shared_ptr<linphone::AccountCreator> mAccountCreator;
	std::shared_ptr<Handlers> mHandlers;
#ifdef ENABLE_OAUTH2
	OAuth2Model * oAuth2Model = nullptr;
#endif
};

#endif // ASSISTANT_MODEL_H_
