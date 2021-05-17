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
#include "utils/LinphoneUtils.hpp"
#include "utils/Utils.hpp"

#include "LdapModel.hpp"

// =============================================================================

using namespace std;

LdapModel::LdapModel (const int& id,QObject *parent ) : QObject(parent), mId(id){
	mIsValid = false;
	mMaxResults = 50;
	mTimeout = 5;
	mDebug = false;
	mVerifyServerCertificates = -1;
	mUseTls = true;
	mUseSal = false;
	mServer = "ldap://ldap.example.org";
	mConfig["enable"] = "0";
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
        CoreManager *coreManager = CoreManager::getInstance();
        auto lConfig = coreManager->getCore()->getConfig();
        std::string section = ("ldap_"+QString::number(mId)).toStdString();
        lConfig->cleanSection(section);
        for(auto it = mConfig.begin() ; it != mConfig.end() ; ++it)
            lConfig->setString(section, it.key().toStdString(), it.value().toString().toStdString());
    }
}

void LdapModel::unsave(){
    if(mId>=0){
        CoreManager *coreManager = CoreManager::getInstance();
        auto lConfig = coreManager->getCore()->getConfig();
        std::string section = ("ldap_"+QString::number(mId)).toStdString();
        lConfig->cleanSection(section);
    }
}

bool LdapModel::load(const std::string& section){
	bool ok = false;
	CoreManager *coreManager = CoreManager::getInstance();
	auto lConfig = coreManager->getCore()->getConfig();
	std::string sectionName;
	size_t i = section.length()-1;
	while(i>0 && section[i] != '_')// Get the name strip number
		--i;
	if(i>0){
		sectionName = section.substr(0,i);
		mId = atoi(section.substr(i+1).c_str());
	}else{
		sectionName = section;
		mId = 0;
	}
	if(sectionName == "ldap"){
		mConfig.clear();
		auto keys = lConfig->getKeysNamesList(section);
		for(auto itKeys = keys.begin() ; itKeys != keys.end() ; ++itKeys){
			mConfig[QString::fromStdString(*itKeys)] = QString::fromStdString(lConfig->getString(section, *itKeys, ""));
		}
		unset();
		ok = true;
	}
	return ok;
}

QVariantMap LdapModel::getConfig(){
	return mConfig;
}

void LdapModel::setConfig(const QVariantMap& config){
	mConfig = config;
	emit configChanged();
}

void LdapModel::set(){
	mConfig["server"] = mServer;
	mConfig["display_name"] = mDisplayName;
	mConfig["use_sal"] = (mUseSal?"1":"0");
	mConfig["use_tls"] = (mUseTls?"1":"0");
	mConfig["server"] = mServer;
	mConfig["max_results"] = mMaxResults;
	mConfig["timeout"] = mTimeout;
	mConfig["password"] = mPassword;
	mConfig["bind_dn"] = mBindDn;
	mConfig["base_object"] = mBaseObject;
	mConfig["filter"] = mFilter;
	mConfig["name_attribute"] = mNameAttributes;
	mConfig["sip_attribute"] = mSipAttributes;
	mConfig["sip_domain"] = mSipDomain;
	mConfig["debug"] = (mDebug?"1":"0");
	mConfig["verify_server_certificates"] = mVerifyServerCertificates;
}

void LdapModel::unset(){
	mServer = mConfig["server"].toString();
	mDisplayName = mConfig["display_name"].toString();
	mUseTls = mConfig["use_tls"].toString() == "1";
	mUseSal = mConfig["use_sal"].toString() == "1";
	mMaxResults = mConfig["max_results"].toInt();
	mTimeout = mConfig["timeout"].toInt();
	mPassword = mConfig["password"].toString();
	mBindDn = mConfig["bind_dn"].toString();
	mBaseObject = mConfig["base_object"].toString();
	mFilter = mConfig["filter"].toString();
	mNameAttributes = mConfig["name_attribute"].toString();
	mSipAttributes = mConfig["sip_attribute"].toString();
	mSipDomain = mConfig["sip_domain"].toString();
	mDebug = mConfig["debug"].toString() == "1";
	mVerifyServerCertificates = mConfig["verify_server_certificates"].toInt();
	
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
	return mConfig["enable"].toString() == "1";
}
void LdapModel::setEnabled(const bool& data){
	if(isValid()){
		mConfig["enable"] = (data?"1":"0");
		save();
	}else
		mConfig["enable"] = "0";
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
