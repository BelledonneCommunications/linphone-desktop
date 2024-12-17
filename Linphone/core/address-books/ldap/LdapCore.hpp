/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#ifndef LDAP_CORE_H_
#define LDAP_CORE_H_

#include "model/address-books/ldap/LdapModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class LdapCore : public QObject, public AbstractObject {
	Q_OBJECT

public:
	static QSharedPointer<LdapCore> create(const std::shared_ptr<linphone::RemoteContactDirectory> &ldap);
	LdapCore(const std::shared_ptr<linphone::RemoteContactDirectory> &ldap);
	~LdapCore();

	void setSelf(QSharedPointer<LdapCore> me);

	Q_INVOKABLE void remove();
	Q_INVOKABLE void save();
	Q_INVOKABLE void undo();
	Q_INVOKABLE bool isValid();

	Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
	Q_PROPERTY(bool saved READ isSaved WRITE setSaved NOTIFY savedChanged)

	DECLARE_CORE_GETSET_MEMBER(QString, serverUrl, ServerUrl)
	DECLARE_CORE_GETSET_MEMBER(QString, bindDn, BindDn)
	DECLARE_CORE_GETSET_MEMBER(QString, password, Password)
	DECLARE_CORE_GETSET_MEMBER(linphone::Ldap::AuthMethod, authMethod, AuthMethod)
	DECLARE_CORE_GETSET_MEMBER(bool, tls, Tls)
	DECLARE_CORE_GETSET_MEMBER(linphone::Ldap::CertVerificationMode,
	                           serverCertificatesVerificationMode,
	                           ServerCertificatesVerificationMode)
	DECLARE_CORE_GETSET_MEMBER(QString, baseObject, BaseObject)
	DECLARE_CORE_GETSET_MEMBER(QString, filter, Filter)
	DECLARE_CORE_GETSET_MEMBER(int, limit, Limit)
	DECLARE_CORE_GETSET_MEMBER(int, timeout, Timeout)
	DECLARE_CORE_GETSET_MEMBER(int, delay, Delay)
	DECLARE_CORE_GETSET_MEMBER(int, minCharacters, MinCharacters)
	DECLARE_CORE_GETSET_MEMBER(QString, nameAttribute, NameAttribute)
	DECLARE_CORE_GETSET_MEMBER(QString, sipAttribute, SipAttribute)
	DECLARE_CORE_GETSET_MEMBER(QString, sipDomain, SipDomain)
	DECLARE_CORE_GETSET_MEMBER(bool, debug, Debug)

public:
	bool isEnabled() const;
	void setEnabled(bool enabled);

	bool isSaved() const;
	void setSaved(bool saved);

signals:
	void enabledChanged();
	void savedChanged();

protected:
	void writeIntoModel(std::shared_ptr<LdapModel> model) const;
	void writeFromModel(const std::shared_ptr<LdapModel> &model);

private:
	bool mEnabled = false;
	bool mIsSaved = false;
	std::shared_ptr<LdapModel> mLdapModel;
	QSharedPointer<SafeConnection<LdapCore, LdapModel>> mLdapModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(LdapCore *)
#endif
