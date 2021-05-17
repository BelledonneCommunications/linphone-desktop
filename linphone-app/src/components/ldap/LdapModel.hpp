/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef LDAP_MODEL_H_
#define LDAP_MODEL_H_

#include <QAbstractListModel>
#include <QDateTime>


// =============================================================================

class CoreHandlers;

class LdapModel : public QObject {
	Q_OBJECT
	Q_PROPERTY(QVariantMap config READ getConfig WRITE setConfig NOTIFY configChanged)
	Q_PROPERTY(bool isValid MEMBER mIsValid NOTIFY isValidChanged)
	
	Q_PROPERTY(QString server MEMBER mServer WRITE setServer NOTIFY serverChanged)
	Q_PROPERTY(QString serverFieldError MEMBER mServerFieldError NOTIFY serverFieldErrorChanged)
	
	Q_PROPERTY(QString displayName MEMBER mDisplayName NOTIFY displayNameChanged)
	
	Q_PROPERTY(bool useTls MEMBER mUseTls NOTIFY useTlsChanged)
	Q_PROPERTY(bool useSal MEMBER mUseSal NOTIFY useSalChanged)
	
	Q_PROPERTY(int maxResults MEMBER mMaxResults WRITE setMaxResults NOTIFY maxResultsChanged)
	Q_PROPERTY(QString maxResultsFieldError MEMBER mMaxResultsFieldError NOTIFY maxResultsFieldErrorChanged)
	
	Q_PROPERTY(int timeout MEMBER mTimeout WRITE setTimeout NOTIFY timeoutChanged)
	Q_PROPERTY(QString timeoutFieldError MEMBER mTimeoutFieldError NOTIFY timeoutFieldErrorChanged)
	
	
	Q_PROPERTY(QString password MEMBER mPassword WRITE setPassword NOTIFY passwordChanged)
	Q_PROPERTY(QString passwordFieldError MEMBER mPasswordFieldError NOTIFY passwordFieldErrorChanged)
	
	Q_PROPERTY(QString bindDn MEMBER mBindDn WRITE setBindDn NOTIFY bindDnChanged)
	Q_PROPERTY(QString bindDnFieldError MEMBER mBindDnFieldError NOTIFY bindDnFieldErrorChanged)
	
	Q_PROPERTY(QString baseObject MEMBER mBaseObject WRITE setBaseObject NOTIFY baseObjectChanged)
	Q_PROPERTY(QString baseObjectFieldError MEMBER mBaseObjectFieldError NOTIFY baseObjectFieldErrorChanged)
	
	Q_PROPERTY(QString filter MEMBER mFilter WRITE setFilter NOTIFY filterChanged)
	Q_PROPERTY(QString filterFieldError MEMBER mFilterFieldError NOTIFY filterFieldErrorChanged)
	
	Q_PROPERTY(QString nameAttributes MEMBER mNameAttributes WRITE setNameAttributes NOTIFY nameAttributesChanged)
	Q_PROPERTY(QString nameAttributesFieldError MEMBER mNameAttributesFieldError NOTIFY nameAttributesFieldErrorChanged)
	
	Q_PROPERTY(QString sipAttributes MEMBER mSipAttributes WRITE setSipAttributes NOTIFY sipAttributesChanged)
	Q_PROPERTY(QString sipAttributesFieldError MEMBER mSipAttributesFieldError NOTIFY sipAttributesFieldErrorChanged)
	
	Q_PROPERTY(QString sipDomain MEMBER mSipDomain WRITE setSipDomain NOTIFY sipDomainChanged)
	Q_PROPERTY(QString sipDomainFieldError MEMBER mSipDomainFieldError NOTIFY sipDomainFieldErrorChanged)
	
	Q_PROPERTY(bool debug MEMBER mDebug NOTIFY debugChanged)
	Q_PROPERTY(int verifyServerCertificates MEMBER mVerifyServerCertificates NOTIFY verifyServerCertificatesChanged)
	
	Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
public:
	
	LdapModel (const int& id = 0,QObject *parent = nullptr);
	
	QVariantMap mConfig;
	bool mIsValid;
	int mId; // "ldap_mId" from section name
	
	QString mServer;
	QString mServerFieldError;
	void setServer(const QString& server);
	void testServerField();
	
	QString mDisplayName;
	
	bool mUseSal;
	bool mUseTls;
	
	int mMaxResults;
	QString mMaxResultsFieldError;
	void setMaxResults(const int& data);
	void testMaxResultsField();

	int mTimeout;
	QString mTimeoutFieldError;
	void setTimeout(const int& data);
	void testTimeoutField();

	QString mPassword;
	QString mPasswordFieldError;
	void setPassword(const QString& data);
	void testPasswordField();
	
	QString mBindDn;
	QString mBindDnFieldError;
	void setBindDn(const QString& data);
	void testBindDnField();
	
	QString mBaseObject;
	QString mBaseObjectFieldError;
	void setBaseObject(const QString& data);
	void testBaseObjectField();
	
	QString mFilter;
	QString mFilterFieldError;
	void setFilter(const QString& data);
	void testFilterField();
	
	QString mNameAttributes;
	QString mNameAttributesFieldError;
	void setNameAttributes(const QString& data);
	void testNameAttributesField();
	
	QString mSipAttributes;
	QString mSipAttributesFieldError;
	void setSipAttributes(const QString& data);
	void testSipAttributesField();
	
	QString mSipDomain;
	QString mSipDomainFieldError;
	void setSipDomain(const QString& data);
	void testSipDomainField();
	
	bool mDebug;
	int mVerifyServerCertificates;
	
// Test if the configuration is valid
	bool isValid();
	void init();// init configuration by default value
	Q_INVOKABLE void save(); // Save configuration to linphonerc
	void unsave();	// Remove configuration from linphonerc
	bool load(const std::string& sectionName);// Load a configuration : ldap_x where x is a unique number
	void set();	// Fix Configuration from variables
	Q_INVOKABLE void unset(); // Set variables from Configuration
	
	QVariantMap getConfig();
	void setConfig(const QVariantMap& config);
	
	bool isEnabled();
	void setEnabled(const bool& data);
	
signals:
	void configChanged();
	void isValidChanged();
	void serverChanged();
	void displayNameChanged();
	void useTlsChanged();
	void useSalChanged();
	void isServerValidChanged();
	void maxResultsChanged();
	void timeoutChanged();
	void passwordChanged();
	void bindDnChanged();
	void baseObjectChanged();
	void filterChanged();
	void nameAttributesChanged();
	void sipAttributesChanged();
	void sipDomainChanged();
	void debugChanged();
	void verifyServerCertificatesChanged();
	
	
	void serverFieldErrorChanged();
	void maxResultsFieldErrorChanged();
	void timeoutFieldErrorChanged();
	void passwordFieldErrorChanged();
	void bindDnFieldErrorChanged();
	void baseObjectFieldErrorChanged();
	void filterFieldErrorChanged();
	void nameAttributesFieldErrorChanged();
	void sipAttributesFieldErrorChanged();
	void sipDomainFieldErrorChanged();
	
	void enabledChanged();
};
Q_DECLARE_METATYPE(LdapModel*);
#endif // LDAP_MODEL_H_
