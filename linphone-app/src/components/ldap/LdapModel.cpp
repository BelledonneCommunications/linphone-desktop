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

#include <QDateTime>
#include <QElapsedTimer>
#include <QUrl>
#include <QtDebug>

#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"

#include "LdapModel.hpp"

// =============================================================================

using namespace std;

LdapModel::LdapModel (std::shared_ptr<linphone::Ldap> ldap, QObject *parent ) : QObject(parent){
	mLdap = ldap;
	mIsValid = false;
	if(mLdap)
		mLdapParams = ldap->getParams()->clone();
	else{
		mLdapParams = CoreManager::getInstance()->getCore()->createLdapParams();
		mLdapParams->setMaxResults(50);	// Desktop default
		mLdapParams->setEnabled(false);
	}

	unset();
}

void LdapModel::init(){
	set();
	unset();
}

bool LdapModel::isValid(){
	bool valid = mServerFieldError=="" 
			&& mMaxResultsFieldError==""
			&& mTimeoutFieldError==""
			&& mPasswordFieldError==""
			&& mBindDnFieldError==""
			&& mBaseObjectFieldError==""
			&& mFilterFieldError==""
			&& mNameAttributesFieldError==""
			&& mSipAttributesFieldError==""
			&& mSipDomainFieldError=="";
	if( valid != mIsValid){
		mIsValid = valid;
		emit isValidChanged();
	}
	return mIsValid;
}
void LdapModel::save(){
	if(isValid()){
		set();
		if(!mLdap) {
			mLdap = CoreManager::getInstance()->getCore()->createLdapWithParams(mLdapParams);
			emit indexChanged();
		}else{
			int oldIndex = getIndex();
			mLdap->setParams(mLdapParams);
			if( oldIndex != getIndex())
				emit indexChanged();
		}
	}
}

void LdapModel::unsave(){
	if(mLdap)
		CoreManager::getInstance()->getCore()->removeLdap(mLdap);
}
QVariantMap LdapModel::getConfig(){
	//return mConfig;
	return QVariantMap();
}

void LdapModel::setConfig(const QVariantMap& config){
	//mConfig = config;
	emit configChanged();
}

void LdapModel::set(){
	mLdapParams->setServer(mServer.toStdString());
	mLdapParams->setCustomValue("display_name", mDisplayName.toStdString());
	mLdapParams->enableSal(mUseSal);
	mLdapParams->enableTls(mUseTls);
	mLdapParams->setMaxResults(mMaxResults);
	mLdapParams->setTimeout(mTimeout);
	mLdapParams->setPassword(mPassword.toStdString());
	mLdapParams->setBindDn(mBindDn.toStdString());
	mLdapParams->setBaseObject(mBaseObject.toStdString());
	mLdapParams->setFilter(mFilter.toStdString());
	mLdapParams->setNameAttribute(mNameAttributes.toStdString());
	mLdapParams->setSipAttribute(mSipAttributes.toStdString());
	mLdapParams->setSipDomain(mSipDomain.toStdString());
	mLdapParams->setDebugLevel( (linphone::Ldap::DebugLevel) mDebug);
	mLdapParams->setServerCertificatesVerificationMode((linphone::Ldap::CertVerificationMode)mVerifyServerCertificates);
}

void LdapModel::unset(){
	mServer = QString::fromStdString(mLdapParams->getServer());
	std::string t = mLdapParams->getCustomValue("display_name");
	mDisplayName = QString::fromStdString(t);
	mUseTls = mLdapParams->tlsEnabled();
	mUseSal = mLdapParams->salEnabled();
	mMaxResults = mLdapParams->getMaxResults();
	mTimeout = mLdapParams->getTimeout();
	mPassword = QString::fromStdString(mLdapParams->getPassword());
	mBindDn = QString::fromStdString(mLdapParams->getBindDn());
	mBaseObject = QString::fromStdString(mLdapParams->getBaseObject());
	mFilter = QString::fromStdString(mLdapParams->getFilter());
	mNameAttributes = QString::fromStdString(mLdapParams->getNameAttribute());
	mSipAttributes = QString::fromStdString(mLdapParams->getSipAttribute());
	mSipDomain = QString::fromStdString(mLdapParams->getSipDomain());
	mDebug = (int)mLdapParams->getDebugLevel();
	mVerifyServerCertificates = (int)mLdapParams->getServerCertificatesVerificationMode();
	testServerField();
	testMaxResultsField();
	testTimeoutField();
	testPasswordField();
	testBindDnField();
	testBaseObjectField();
	testFilterField();
	testNameAttributesField();
	testSipAttributesField();
	testSipDomainField();
	isValid();
}
bool LdapModel::isEnabled(){
	return mLdapParams->getEnabled();
}
void LdapModel::setEnabled(const bool& data){
	if(isValid()){
		mLdapParams->setEnabled(data);
		save();
	}else
		mLdapParams->setEnabled(false);
	emit enabledChanged();
}
//------------------------------------------------------------------------------------

void LdapModel::setServer(const QString& server){
	mServer = server;
	testServerField();
	emit serverChanged();
}
void LdapModel::testServerField(){
	QString valid;
	if(mServer == "")
		valid = "Server must not be empty";
	else{
		QUrl url(mServer);
		if(!url.isValid())
			valid = "Server is not an URL";
		else if(url.scheme().left(4) != "ldap")
			valid = "URL must begin by a ldap scheme.";
		else if(url.scheme() == "ldaps")
			valid = "ldaps is not supported.";
		else
			valid = "";
	}
	if( valid != mServerFieldError){
		mServerFieldError = valid;
		emit serverFieldErrorChanged();
		isValid();
	}
}

void LdapModel::setDisplayName(const QString& displayName){
	mDisplayName = displayName;
	emit displayNameChanged();
}

void LdapModel::setMaxResults(const int& data){
	mMaxResults = data;
	testMaxResultsField();
	emit maxResultsChanged();
}
void LdapModel::testMaxResultsField(){
	QString valid;
	if(mMaxResults <= 0)
		valid = "Max Results must be greater than 0";
	else
		valid = "";
	if( valid != mMaxResultsFieldError){
		mMaxResultsFieldError = valid;
		emit maxResultsFieldErrorChanged();
		isValid();
	}
}

void LdapModel::setTimeout(const int& data){
	mTimeout = data;
	testTimeoutField();
	emit timeoutChanged();
}
void LdapModel::testTimeoutField(){
	QString valid;
	if(mTimeout < 0)
		valid = "Timeout must be positive in seconds.";
	else
		valid = "";
	if( valid != mTimeoutFieldError){
		mTimeoutFieldError = valid;
		emit timeoutFieldErrorChanged();
		isValid();
	}
}

void LdapModel::setPassword(const QString& data){
	mPassword = data;
	testPasswordField();
	emit passwordChanged();
}
void LdapModel::testPasswordField(){
	QString valid = "";
	if( valid != mPasswordFieldError){
		mPasswordFieldError = valid;
		emit passwordFieldErrorChanged();
		isValid();
	}
}

void LdapModel::setBindDn(const QString& data){
	mBindDn = data;
	testBindDnField();
	emit bindDnChanged();
}
void LdapModel::testBindDnField(){
	QString valid;
	if( valid != mBindDnFieldError){
		mBindDnFieldError = valid;
		emit bindDnFieldErrorChanged();
		isValid();
	}
}

void LdapModel::setBaseObject(const QString& data){
	mBaseObject = data;
	testBaseObjectField();
	emit baseObjectChanged();
}
void LdapModel::testBaseObjectField(){
	QString valid;
	if(mBaseObject == "")
		valid = "Search Base must not be empty";
	else
		valid = "";
	if( valid != mBaseObjectFieldError){
		mBaseObjectFieldError = valid;
		emit baseObjectFieldErrorChanged();
		isValid();
	}
}

void LdapModel::setFilter(const QString& data){
	mFilter = data;
	testFilterField();
	emit filterChanged();
}
void LdapModel::testFilterField(){
	QString valid = "";
	if( valid != mFilterFieldError){
		mFilterFieldError = valid;
		emit filterFieldErrorChanged();
		isValid();
	}
}

void LdapModel::setNameAttributes(const QString& data){
	mNameAttributes = data;
	testNameAttributesField();
	emit nameAttributesChanged();
}
void LdapModel::testNameAttributesField(){
	QString valid = "";
	if( valid != mNameAttributesFieldError){
		mNameAttributesFieldError = valid;
		emit nameAttributesFieldErrorChanged();
		isValid();
	}
}

void LdapModel::setSipAttributes(const QString& data){
	mSipAttributes = data;
	testSipAttributesField();
	emit sipAttributesChanged();
}
void LdapModel::testSipAttributesField(){
	QString valid = "";
	if( valid != mSipAttributesFieldError){
		mSipAttributesFieldError = valid;
		emit sipAttributesFieldErrorChanged();
		isValid();
	}
}

void LdapModel::setSipDomain(const QString& data){
	mSipDomain = data;
	testSipDomainField();
	emit sipDomainChanged();
}
void LdapModel::testSipDomainField(){
	QString valid = "";
	if( valid != mSipDomainFieldError){
		mSipDomainFieldError = valid;
		emit sipDomainFieldErrorChanged();
		isValid();
	}
}

int LdapModel::getIndex() const{
	if(mLdap)
		return mLdap->getIndex();
	else
		return -2;
}
