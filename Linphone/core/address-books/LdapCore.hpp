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

#include "model/address-books/LdapModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class LdapCore : public QObject, public AbstractObject {
	Q_OBJECT

public:
	static QSharedPointer<LdapCore> create(const std::shared_ptr<linphone::Ldap> &ldap);
	LdapCore(const std::shared_ptr<linphone::Ldap> &ldap);
	~LdapCore();

	void setSelf(QSharedPointer<LdapCore> me);

	Q_INVOKABLE void remove();
	Q_INVOKABLE void save();
	Q_INVOKABLE bool isValid();

	DECLARE_CORE_GETSET(bool, enabled, Enabled)
	DECLARE_CORE_GETSET(QString, server, Server)
	DECLARE_CORE_GETSET(QString, bindDn, BindDn)
	DECLARE_CORE_GETSET(QString, password, Password)
	DECLARE_CORE_GETSET(linphone::Ldap::AuthMethod, authMethod, AuthMethod)
	DECLARE_CORE_GETSET(bool, tls, Tls)
	DECLARE_CORE_GETSET(linphone::Ldap::CertVerificationMode,
	                    serverCertificatesVerificationMode,
	                    ServerCertificatesVerificationMode)
	DECLARE_CORE_GETSET(QString, baseObject, BaseObject)
	DECLARE_CORE_GETSET(QString, filter, Filter)
	DECLARE_CORE_GETSET(int, maxResults, MaxResults)
	DECLARE_CORE_GETSET(int, timeout, Timeout)
	DECLARE_CORE_GETSET(int, delay, Delay)
	DECLARE_CORE_GETSET(int, minChars, MinChars)
	DECLARE_CORE_GETSET(QString, nameAttribute, NameAttribute)
	DECLARE_CORE_GETSET(QString, sipAttribute, SipAttribute)
	DECLARE_CORE_GETSET(QString, sipDomain, SipDomain)
	DECLARE_CORE_GETSET(linphone::Ldap::DebugLevel, debugLevel, DebugLevel)

private:
	std::shared_ptr<LdapModel> mLdapModel;
	QSharedPointer<SafeConnection<LdapCore, LdapModel>> mLdapModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(LdapCore *)
#endif
