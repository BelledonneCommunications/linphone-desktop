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

#include "LdapModel.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(LdapModel)

LdapModel::LdapModel(const std::shared_ptr<linphone::RemoteContactDirectory> &ldap, QObject *parent) {
	mustBeInLinphoneThread(getClassName());
	if (ldap) {
		mLdap = ldap;
		mLdapParamsClone = mLdap->getLdapParams();
	} else {
		mLdapParamsClone = CoreModel::getInstance()->getCore()->createLdapParams();
		mLdapParamsClone->setDelay(2000);
		mLdapParamsClone->enableTls(true);

		mLdap = CoreModel::getInstance()->getCore()->createLdapRemoteContactDirectory(mLdapParamsClone);
		mLdap->setTimeout(5);
		mLdap->setLimit(50);
		mLdap->setMinCharacters(0); // Needs to be 0 if Contacts list should be synchronized with LDAP AB
	}
}

LdapModel::~LdapModel() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
}

void LdapModel::save() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	int oldTimeout = 5;
	int oldLimit = 50;
	int oldMinChars = 0;
	if (mLdap) {
		oldTimeout = mLdap->getTimeout();
		oldLimit = mLdap->getLimit();
		oldMinChars = mLdap->getMinCharacters();
		core->removeRemoteContactDirectory(
		    mLdap); // Need to do remove/add when updating, as setParams on existing one also adds it to core.
	}
	mLdap = core->createLdapRemoteContactDirectory(mLdapParamsClone);
	mLdap->setTimeout(oldTimeout);
	mLdap->setLimit(oldLimit);
	mLdap->setMinCharacters(oldMinChars);
	core->addRemoteContactDirectory(mLdap);
	lDebug() << log().arg("LDAP Server saved");
	mLdapParamsClone = mLdap->getLdapParams();
	// Clean cache to take account new searches
	auto ldapFriendList = core->getFriendListByName("ldap_friends");
	if (ldapFriendList) core->removeFriendList(ldapFriendList);
	emit saved();
}

void LdapModel::remove() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	CoreModel::getInstance()->getCore()->removeRemoteContactDirectory(mLdap);
	lDebug() << log().arg("LDAP Server removed");
	emit removed();
}

bool LdapModel::getDebug() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mLdapParamsClone->getDebugLevel() == linphone::Ldap::DebugLevel::Verbose;
}
void LdapModel::setDebug(bool data) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (getDebug() != data) {
		mLdapParamsClone->setDebugLevel(data ? linphone::Ldap::DebugLevel::Verbose : linphone::Ldap::DebugLevel::Off);
		save();
		emit debugChanged(data);
	}
}

DEFINE_GETSET(LdapModel, bool, enabled, Enabled, mLdapParamsClone)
DEFINE_GETSET_MODEL_STRING(LdapModel, serverUrl, ServerUrl, mLdap)
DEFINE_GETSET_MODEL_STRING(LdapModel, bindDn, BindDn, mLdapParamsClone)
DEFINE_GETSET_MODEL_STRING(LdapModel, password, Password, mLdapParamsClone)
DEFINE_GETSET(LdapModel, linphone::Ldap::AuthMethod, authMethod, AuthMethod, mLdapParamsClone)
DEFINE_GETSET_ENABLED(LdapModel, tls, Tls, mLdapParamsClone)
DEFINE_GETSET(LdapModel,
              linphone::Ldap::CertVerificationMode,
              serverCertificatesVerificationMode,
              ServerCertificatesVerificationMode,
              mLdapParamsClone)
DEFINE_GETSET_MODEL_STRING(LdapModel, baseObject, BaseObject, mLdapParamsClone)
DEFINE_GETSET_MODEL_STRING(LdapModel, filter, Filter, mLdapParamsClone)
DEFINE_GETSET(LdapModel, int, limit, Limit, mLdap)
DEFINE_GETSET(LdapModel, int, timeout, Timeout, mLdap)
DEFINE_GETSET(LdapModel, int, delay, Delay, mLdapParamsClone)
DEFINE_GETSET(LdapModel, int, minCharacters, MinCharacters, mLdap)
DEFINE_GETSET_MODEL_STRING(LdapModel, nameAttribute, NameAttribute, mLdapParamsClone)
DEFINE_GETSET_MODEL_STRING(LdapModel, sipAttribute, SipAttribute, mLdapParamsClone)
DEFINE_GETSET_MODEL_STRING(LdapModel, sipDomain, SipDomain, mLdapParamsClone)
