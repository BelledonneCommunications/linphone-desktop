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

#include "LdapCore.hpp"
#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(LdapCore)

QSharedPointer<LdapCore> LdapCore::create(const std::shared_ptr<linphone::RemoteContactDirectory> &ldap) {
	auto sharedPointer = QSharedPointer<LdapCore>(new LdapCore(ldap), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

LdapCore::LdapCore(const std::shared_ptr<linphone::RemoteContactDirectory> &ldap) : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mLdapModel = Utils::makeQObject_ptr<LdapModel>(ldap);

	INIT_CORE_MEMBER(ServerUrl, mLdapModel)
	INIT_CORE_MEMBER(BindDn, mLdapModel)
	INIT_CORE_MEMBER(Password, mLdapModel)
	INIT_CORE_MEMBER(AuthMethod, mLdapModel)
	INIT_CORE_MEMBER(Tls, mLdapModel)
	INIT_CORE_MEMBER(ServerCertificatesVerificationMode, mLdapModel)
	INIT_CORE_MEMBER(BaseObject, mLdapModel)
	INIT_CORE_MEMBER(Filter, mLdapModel)
	INIT_CORE_MEMBER(Limit, mLdapModel)
	INIT_CORE_MEMBER(Timeout, mLdapModel)
	INIT_CORE_MEMBER(Delay, mLdapModel)
	INIT_CORE_MEMBER(MinCharacters, mLdapModel)
	INIT_CORE_MEMBER(NameAttribute, mLdapModel)
	INIT_CORE_MEMBER(SipAttribute, mLdapModel)
	INIT_CORE_MEMBER(SipDomain, mLdapModel)
	INIT_CORE_MEMBER(Debug, mLdapModel)
	INIT_CORE_MEMBER(Enabled, mLdapModel)
}

LdapCore::~LdapCore() {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
}

void LdapCore::remove() {
	mLdapModelConnection->invokeToModel([this]() {
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		mLdapModel->remove();
	});
}

bool LdapCore::isValid() {
	return !mServerUrl.isEmpty() && !mBaseObject.isEmpty();
}

void LdapCore::setSelf(QSharedPointer<LdapCore> me) {
	mLdapModelConnection = SafeConnection<LdapCore, LdapModel>::create(me, mLdapModel);

	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, QString, serverUrl, ServerUrl)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, QString, bindDn, BindDn)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, QString, password, Password)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, linphone::Ldap::AuthMethod,
	                           authMethod, AuthMethod)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, bool, tls, Tls)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel,
	                           linphone::Ldap::CertVerificationMode, serverCertificatesVerificationMode,
	                           ServerCertificatesVerificationMode)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, QString, baseObject, BaseObject)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, QString, filter, Filter)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, int, limit, Limit)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, int, timeout, Timeout)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, int, delay, Delay)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, int, minCharacters, MinCharacters)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, QString, nameAttribute,
	                           NameAttribute)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, QString, sipAttribute,
	                           SipAttribute)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, QString, sipDomain, SipDomain)
	DEFINE_CORE_GETSET_CONNECT(mLdapModelConnection, LdapCore, LdapModel, mLdapModel, bool, debug, Debug)

	mLdapModelConnection->makeConnectToModel(&LdapModel::saved, [this]() {
		mLdapModelConnection->invokeToCore([this]() { emit App::getInstance()->getSettings()->ldapConfigChanged(); });
	});
	mLdapModelConnection->makeConnectToModel(&LdapModel::removed, [this]() {
		mLdapModelConnection->invokeToCore([this]() { emit App::getInstance()->getSettings()->ldapConfigChanged(); });
	});
}

bool LdapCore::isEnabled() const {
	return mEnabled;
}

void LdapCore::setEnabled(bool enabled) {
	if (mEnabled != enabled) {
		mEnabled = enabled;
		emit enabledChanged();
		setSaved(false);
	}
}

bool LdapCore::isSaved() const {
	return mIsSaved;
}

void LdapCore::setSaved(bool saved) {
	if (mIsSaved != saved) {
		mIsSaved = saved;
		emit savedChanged();
	}
}

void LdapCore::writeIntoModel(std::shared_ptr<LdapModel> model) const {
	mustBeInLinphoneThread(getClassName() + Q_FUNC_INFO);
	model->setEnabled(mEnabled);
}

void LdapCore::writeFromModel(const std::shared_ptr<LdapModel> &model) {
	mustBeInLinphoneThread(getClassName() + Q_FUNC_INFO);
	setEnabled(model->getEnabled());
}

void LdapCore::save() {
	mLdapModelConnection->invokeToModel([this]() {
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		writeIntoModel(mLdapModel);
		mLdapModel->save();
		mLdapModelConnection->invokeToCore([this] { setSaved(true); });
	});
}

void LdapCore::undo() {
	if (mLdapModel) {
		mLdapModelConnection->invokeToModel([this] { writeFromModel(mLdapModel); });
	}
}
