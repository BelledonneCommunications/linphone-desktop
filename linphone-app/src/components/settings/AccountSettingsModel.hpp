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

#ifndef ACCOUNT_SETTINGS_MODEL_H_
#define ACCOUNT_SETTINGS_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QVector>

// =============================================================================

class AccountSettingsModel : public QObject {
	Q_OBJECT
	
	// Selected account.
	Q_PROPERTY(QString username READ getUsername WRITE setUsername NOTIFY usernameChanged)
	Q_PROPERTY(QString sipAddress READ getUsedSipAddressAsStringUriOnly NOTIFY sipAddressChanged)
	Q_PROPERTY(QString fullSipAddress READ getUsedSipAddressAsString NOTIFY fullSipAddressChanged)
	Q_PROPERTY(RegistrationState registrationState READ getRegistrationState NOTIFY registrationStateChanged)
	
	Q_PROPERTY(QString conferenceUri READ getConferenceUri NOTIFY conferenceUriChanged)
	Q_PROPERTY(QString videoConferenceUri READ getVideoConferenceUri NOTIFY videoConferenceUriChanged)
	Q_PROPERTY(QString limeServerUrl READ getLimeServerUrl NOTIFY limeServerUrlChanged)
	
	// Default info.
	Q_PROPERTY(QString primaryDisplayName READ getPrimaryDisplayName WRITE setPrimaryDisplayName NOTIFY primaryDisplayNameChanged)
	Q_PROPERTY(QString primaryUsername READ getPrimaryUsername WRITE setPrimaryUsername NOTIFY primaryUsernameChanged)
	Q_PROPERTY(QString primarySipAddress READ getPrimarySipAddress NOTIFY primarySipAddressChanged)

	Q_PROPERTY(QString defaultAccountDomain READ getDefaultAccountDomain NOTIFY defaultAccountChanged)
	
	Q_PROPERTY(QVariantList accounts READ getAccounts NOTIFY accountsChanged)
	Q_PROPERTY(int missedCallsCount READ getMissedCallsCount NOTIFY missedCallsCountChanged)
	Q_PROPERTY(int unreadMessagesCount READ getUnreadMessagesCount NOTIFY unreadMessagesCountChanged)
	
	
public:
	enum RegistrationState {
		RegistrationStateRegistered,
		RegistrationStateNotRegistered,
		RegistrationStateInProgress,
		RegistrationStateNoAccount,
	};
	Q_ENUM(RegistrationState);
	
	AccountSettingsModel (QObject *parent = Q_NULLPTR);
	
	std::shared_ptr<linphone::Address> getUsedSipAddress () const;
	void setUsedSipAddress (const std::shared_ptr<linphone::Address> &address);
	
	std::shared_ptr<linphone::Account> findAccount(std::shared_ptr<const linphone::Address> address) const ;
	
	
	QString getUsedSipAddressAsStringUriOnly () const;
	QString getUsedSipAddressAsString () const;
	
	// Update account with parameters or add a new one in core.
	bool addOrUpdateAccount (std::shared_ptr<linphone::Account> account, const std::shared_ptr<linphone::AccountParams>& accountParams);
	
	Q_INVOKABLE QVariantMap getAccountDescription (const std::shared_ptr<linphone::Account> &account);
	QString getConferenceUri() const;
	QString getVideoConferenceUri() const;
	QString getLimeServerUrl() const;
	bool getUseInternationalPrefixForCallsAndChats() const;
	int getMissedCallsCount() const;
	int getUnreadMessagesCount() const;
	
	Q_INVOKABLE void setDefaultAccount (const std::shared_ptr<linphone::Account> &account = nullptr);
	Q_INVOKABLE void setDefaultAccountFromSipAddress (const QString &sipAddress);
	Q_INVOKABLE void enableRegister (std::shared_ptr<linphone::Account> account, bool enable);
	static void enableRegister(std::shared_ptr<linphone::AccountParams> params, bool registerEnabled, QString contactParameters);
	
	Q_INVOKABLE bool addOrUpdateAccount (const std::shared_ptr<linphone::Account> &account, const QVariantMap &data);
	Q_INVOKABLE bool addOrUpdateAccount (const QVariantMap &data);// Create default account and apply data
	Q_INVOKABLE void removeAccount (const std::shared_ptr<linphone::Account> &account);
	
	Q_INVOKABLE std::shared_ptr<linphone::Account> createAccount (const QString& assistantFile);
	
	Q_INVOKABLE void addAuthInfo (
			const std::shared_ptr<linphone::AuthInfo> &authInfo,
			const QString &password,
			const QString &userId
			);
	
	Q_INVOKABLE void eraseAllPasswords ();
	
signals:
	
	void usernameChanged();
	void sipAddressChanged();
	void fullSipAddressChanged();
	void registrationStateChanged();
	void conferenceUriChanged();
	void videoConferenceUriChanged();
	void limeServerUrlChanged();
	
	void primaryDisplayNameChanged();
	void primaryUsernameChanged();
	void primarySipAddressChanged();
	
	void accountsChanged();
	
	void accountSettingsUpdated ();
	void defaultAccountChanged();
	void publishPresenceChanged();
	void defaultRegistrationChanged();
	void missedCallsCountChanged();
	void unreadMessagesCountChanged();
	
private:
	QString getUsername () const;
	void setUsername (const QString &username);
	
	RegistrationState getRegistrationState () const;
	
	// ---------------------------------------------------------------------------
	
	QString getPrimaryUsername () const;
	void setPrimaryUsername (const QString &username);
	
	QString getPrimaryDisplayName () const;
	void setPrimaryDisplayName (const QString &displayName);
	
	QString getPrimarySipAddress () const;

	QString getDefaultAccountDomain () const;
	
	// ---------------------------------------------------------------------------
	
	QVariantList getAccounts () const;
	
	// ---------------------------------------------------------------------------
	
	void handleRegistrationStateChanged (
			const std::shared_ptr<linphone::Account> &account,
			linphone::RegistrationState state
			);
	
	QVector<std::shared_ptr<linphone::Account> > mRemovingAccounts;
	std::shared_ptr<linphone::Account> mSelectedAccount;
};

Q_DECLARE_METATYPE(std::shared_ptr<linphone::Account>);

#endif // ACCOUNT_SETTINGS_MODEL_H_
