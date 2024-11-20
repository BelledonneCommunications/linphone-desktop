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

#ifndef LDAP_MODEL_H_
#define LDAP_MODEL_H_

#include "tool/AbstractObject.hpp"
#include <QObject>
#include <linphone++/linphone.hh>

class LdapModel : public QObject, public AbstractObject {
	Q_OBJECT

public:
	LdapModel(const std::shared_ptr<linphone::RemoteContactDirectory> &ldap, QObject *parent = nullptr);
	~LdapModel();

	void setDefaultParams();
	void save();
	void remove();

	DECLARE_GETSET(bool, enabled, Enabled)
	DECLARE_GETSET(QString, serverUrl, ServerUrl)
	DECLARE_GETSET(QString, bindDn, BindDn)
	DECLARE_GETSET(QString, password, Password)
	DECLARE_GETSET(linphone::Ldap::AuthMethod, authMethod, AuthMethod)
	DECLARE_GETSET(bool, tls, Tls)
	DECLARE_GETSET(linphone::Ldap::CertVerificationMode,
	               serverCertificatesVerificationMode,
	               ServerCertificatesVerificationMode)
	DECLARE_GETSET(QString, baseObject, BaseObject)
	DECLARE_GETSET(QString, filter, Filter)
	DECLARE_GETSET(int, limit, Limit)
	DECLARE_GETSET(int, timeout, Timeout)
	DECLARE_GETSET(int, delay, Delay)
	DECLARE_GETSET(int, minCharacters, MinCharacters)
	DECLARE_GETSET(QString, nameAttribute, NameAttribute)
	DECLARE_GETSET(QString, sipAttribute, SipAttribute)
	DECLARE_GETSET(QString, sipDomain, SipDomain)
	DECLARE_GETSET(bool, debug, Debug)

signals:
	void saved();
	void removed();

private:
	std::shared_ptr<linphone::RemoteContactDirectory> mLdap;
	std::shared_ptr<linphone::LdapParams> mLdapParamsClone;

	DECLARE_ABSTRACT_OBJECT
};

#endif
