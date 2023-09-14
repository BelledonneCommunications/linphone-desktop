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

#include <QtDebug>
#include <QTimer>

#include "config.h"

#include "app/paths/Paths.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"

#include "AccountSettingsModel.hpp"
#include "SettingsModel.hpp"


// =============================================================================

using namespace std;

static inline AccountSettingsModel::RegistrationState mapLinphoneRegistrationStateToUi (linphone::RegistrationState state) {
	switch (state) {
		case linphone::RegistrationState::None:
		case linphone::RegistrationState::Cleared:
		case linphone::RegistrationState::Failed:
			return AccountSettingsModel::RegistrationStateNotRegistered;
			
		case linphone::RegistrationState::Progress:
			return AccountSettingsModel::RegistrationStateInProgress;
			
		case linphone::RegistrationState::Ok:
			break;
	}
	
	return AccountSettingsModel::RegistrationStateRegistered;
}

// -----------------------------------------------------------------------------

AccountSettingsModel::AccountSettingsModel (QObject *parent) : QObject(parent) {
	CoreManager *coreManager = CoreManager::getInstance();
	QObject::connect(coreManager->getHandlers().get(), &CoreHandlers::registrationStateChanged, this, &AccountSettingsModel::handleRegistrationStateChanged);
	QObject::connect(coreManager, &CoreManager::callLogsCountChanged, this, &AccountSettingsModel::missedCallsCountChanged);
	
	//QObject::connect(coreManager, &CoreManager::eventCountChanged, this, [this]() { emit accountSettingsUpdated(); });
	
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::usernameChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::sipAddressChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::fullSipAddressChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::registrationStateChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::conferenceUriChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::videoConferenceUriChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::limeServerUrlChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::primaryDisplayNameChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::primaryUsernameChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::primarySipAddressChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::accountsChanged);
	QObject::connect(this, &AccountSettingsModel::accountsChanged, this, &AccountSettingsModel::missedCallsCountChanged);
	QObject::connect(this, &AccountSettingsModel::accountsChanged, this, &AccountSettingsModel::unreadMessagesCountChanged);
	mSelectedAccount = coreManager->getCore()->getDefaultAccount();
}

// -----------------------------------------------------------------------------

shared_ptr<linphone::Address> AccountSettingsModel::getUsedSipAddress () const {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Account> account = core->getDefaultAccount();
	return account ? account->getParams()->getIdentityAddress()->clone() : core->createPrimaryContactParsed();
}

 std::shared_ptr<linphone::Account> AccountSettingsModel::findAccount(shared_ptr<const linphone::Address> address) const {
	if(!address)
		return nullptr;
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	list<shared_ptr<linphone::Account>> accounts = CoreManager::getInstance()->getAccountList();
	for(auto account : accounts){
		if(account) {
			auto contactAddress = account->getContactAddress();
			if(contactAddress && contactAddress->weakEqual(address))
				return account;
		}
	}
	return nullptr;
}

void AccountSettingsModel::setUsedSipAddress (const shared_ptr<linphone::Address> &address) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Account> account = core->getDefaultAccount();
	if( account){
		auto params = account->getParams()->clone();
		if(!params->setIdentityAddress(address)) {
			account->setParams(params);
			emit sipAddressChanged();
		}
		return;
	}
	core->setPrimaryContact(address->asString());
	emit sipAddressChanged();
}

QString AccountSettingsModel::getUsedSipAddressAsStringUriOnly () const {
	return Utils::coreStringToAppString(getUsedSipAddress()->asStringUriOnly());
}

QString AccountSettingsModel::getUsedSipAddressAsString () const {
	return Utils::coreStringToAppString(getUsedSipAddress()->asString());
}
// -----------------------------------------------------------------------------

bool AccountSettingsModel::addOrUpdateAccount (std::shared_ptr<linphone::Account> account, const std::shared_ptr<linphone::AccountParams>& accountParams) {
	
	CoreManager *coreManager = CoreManager::getInstance();
	shared_ptr<linphone::Core> core = coreManager->getCore();
	list<shared_ptr<linphone::Account>> accounts = coreManager->getAccountList();
	if(!account)
		account = core->createAccount(accountParams);
	if (account->setParams(accountParams) == -1) {
		qWarning() << QStringLiteral("Unable to update account: `%1`.")
					  .arg(QString::fromStdString(account->getParams()->getIdentityAddress()->asString()));
		return false;
	}
	if (find(accounts.cbegin(), accounts.cend(), account) == accounts.cend()) {
		if (core->addAccount(account) == -1) {
			qWarning() << QStringLiteral("Unable to add account: `%1`.")
						  .arg(QString::fromStdString(account->getParams()->getIdentityAddress()->asString()));
			return false;
		}
		
		coreManager->addingAccount(account->getParams());
	}
	emit accountSettingsUpdated();
	return true;
}

QVariantMap AccountSettingsModel::getAccountDescription (const shared_ptr<linphone::Account> &account) {
	QVariantMap map;
	auto accountParams = account->getParams();
	
	{
		const shared_ptr<const linphone::Address> address = accountParams->getIdentityAddress();
		map["sipAddress"] = address
				? Utils::coreStringToAppString(accountParams->getIdentityAddress()->asString())
				: QString("");
	}
	map["serverAddress"] = Utils::coreStringToAppString(accountParams->getServerAddress()->asString());
	map["registrationDuration"] = accountParams->getExpires();
	map["publishDuration"] = accountParams->getPublishExpires();
	
	if( map["serverAddress"].toString().toUpper().contains("TRANSPORT="))// transport has been specified : let the RFC select the transport
		map["transport"] = LinphoneEnums::toString(LinphoneEnums::fromLinphone(accountParams->getTransport()));
	else// Set to TLS as default
		map["transport"] = "TLS";
		auto routes = accountParams->getRoutesAddresses();
	if( routes.size() > 0)
		map["route"] = Utils::coreStringToAppString(routes.front()->asString());
	else
		map["route"] = "";
	map["conferenceUri"] = Utils::coreStringToAppString(accountParams->getConferenceFactoryUri());
	auto address = accountParams->getAudioVideoConferenceFactoryAddress();
	map["videoConferenceUri"] = address ? Utils::coreStringToAppString(address->asString()) : "";
	map["limeServerUrl"] = Utils::coreStringToAppString(accountParams->getLimeServerUrl());
	map["videoConferenceUri"] = address ? Utils::coreStringToAppString(address->asString()) : "";
	map["contactParams"] = Utils::coreStringToAppString(accountParams->getContactParameters());
	map["avpfInterval"] = accountParams->getAvpfRrInterval();
	map["registerEnabled"] = accountParams->registerEnabled();
	map["publishPresence"] = accountParams->publishEnabled();
	map["avpfEnabled"] = accountParams->getAvpfMode() == linphone::AVPFMode::Enabled;
	map["registrationState"] = mapLinphoneRegistrationStateToUi(account->getState());
	map["dialPrefix"] = Utils::coreStringToAppString(accountParams->getInternationalPrefix());
	map["dialPrefixCallChat"] = accountParams->getUseInternationalPrefixForCallsAndChats();
	map["dialEscapePlus"] = accountParams->dialEscapePlusEnabled();
	map["rtpBundleEnabled"] = accountParams->rtpBundleEnabled();
	
	shared_ptr<linphone::NatPolicy> natPolicy = accountParams->getNatPolicy();
	bool createdNat = !natPolicy;
	if (createdNat)
		natPolicy = CoreManager::getInstance()->getCore()->createNatPolicy();
	map["iceEnabled"] = natPolicy->iceEnabled();
	map["turnEnabled"] = natPolicy->turnEnabled();
	
	
	const string &turnUser(natPolicy->getStunServerUsername());
	const string &stunServer(natPolicy->getStunServer());
	
	map["turnUser"] = Utils::coreStringToAppString(turnUser);
	map["stunServer"] = Utils::coreStringToAppString(stunServer);
	
	if (createdNat){
		auto accountParamsUpdated = accountParams->clone();
		accountParamsUpdated->setNatPolicy(natPolicy);
		account->setParams(accountParamsUpdated);
	}
	if(turnUser != ""){
		shared_ptr<const linphone::AuthInfo> authInfo = CoreManager::getInstance()->getCore()->findAuthInfo(
				"", turnUser, stunServer
				);
		map["turnPassword"] = authInfo ? Utils::coreStringToAppString(authInfo->getPassword()) : QString("");
	}else
		map["turnPassword"] = "";
	
	return map;
}

QString AccountSettingsModel::getConferenceUri() const{
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Account> account = core->getDefaultAccount();
	return account ? Utils::coreStringToAppString(account->getParams()->getConferenceFactoryUri()) : "";
}

QString AccountSettingsModel::getVideoConferenceUri() const{
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Account> account = core->getDefaultAccount();
	if(account) {
		auto address = account->getParams()->getAudioVideoConferenceFactoryAddress();		
		return address ? Utils::coreStringToAppString(address->asString()) : "";
	}else
		return "";
}

QString AccountSettingsModel::getLimeServerUrl() const{
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Account> account = core->getDefaultAccount();
	return account ? Utils::coreStringToAppString(account->getParams()->getLimeServerUrl()) : "";
}

bool AccountSettingsModel::getUseInternationalPrefixForCallsAndChats() const{
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	if(core){
		shared_ptr<linphone::Account> account = core->getDefaultAccount();
		if(account)
			return account->getParams()->getUseInternationalPrefixForCallsAndChats();
	}
	return false;
}

int AccountSettingsModel::getMissedCallsCount() const {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Account> account = core->getDefaultAccount();
	return account ? account->getMissedCallsCount() : core->getMissedCallsCount();
}

int AccountSettingsModel::getUnreadMessagesCount() const {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Account> account = core->getDefaultAccount();
	return account ? account->getUnreadChatMessageCount() : core->getUnreadChatMessageCount();
}


void AccountSettingsModel::setDefaultAccount (const shared_ptr<linphone::Account> &account) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	if (mSelectedAccount != account) {
		core->setDefaultAccount(account);
		mSelectedAccount = account;
		emit accountSettingsUpdated();
		emit defaultAccountChanged();
	}
}

void AccountSettingsModel::setDefaultAccountFromSipAddress (const QString &sipAddress) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	auto address = Utils::interpretUrl(sipAddress);
	if ( core->createPrimaryContactParsed()->weakEqual(address)) {
		setDefaultAccount(nullptr);
		return;
	}
	
	for (const auto &account : CoreManager::getInstance()->getAccountList())
		if (account->getParams()->getIdentityAddress()->weakEqual(address)) {
			setDefaultAccount(account);
			return;
		}
	
	qWarning() << "Unable to set default account from:" << sipAddress;
}

void AccountSettingsModel::enableRegister (std::shared_ptr<linphone::Account> account, bool enable){
	auto params = account->getParams()->clone();
	enableRegister(params, enable, Utils::coreStringToAppString(params->getContactParameters()));
	account->setParams(params);
}

void AccountSettingsModel::removeAccount (const shared_ptr<linphone::Account> &account) {
	
	CoreManager *coreManager = CoreManager::getInstance();
	std::shared_ptr<linphone::Account> newAccount = nullptr;
	std::list<std::shared_ptr<linphone::Account>> allAccounts = coreManager->getAccountList();
	if( account == coreManager->getCore()->getDefaultAccount()){
		for(auto nextAccount : allAccounts){
			if( nextAccount != account){
				newAccount = nextAccount;
				break;
			}
		}
		setDefaultAccount(newAccount);
	}
// "message-expires" is used to keep contact for messages. Setting to 0 will remove the contact for messages too.
// Check if a "message-expires" exists and set it to 0
	QStringList parameters = Utils::coreStringToAppString(account->getParams()->getContactParameters()).split(";", Qt::SkipEmptyParts);
	for(int i = 0 ; i < parameters.size() ; ++i){
		QStringList fields = parameters[i].split("=");
		if( fields.size() > 1 && fields[0].simplified() == "message-expires"){
			parameters[i] = Constants::DefaultContactParametersOnRemove;
		}
	}
	auto accountParams = account->getParams()->clone();
	accountParams->setContactParameters(Utils::appStringToCoreString(parameters.join(";")));	
	bool isRegistered = account->getState() == linphone::RegistrationState::Ok;
	if (account->setParams(accountParams) == -1) {
		qWarning() << QStringLiteral("Unable to reset message-expiry property before removing account: `%1`.")
				  .arg(QString::fromStdString(account->getParams()->getIdentityAddress()->asString()));
	}else if(isRegistered && account->getParams()->registerEnabled()) { // Wait for update
		mRemovingAccounts.push_back(account);
	}else{// Registration is not enabled : Removing without wait.
		CoreManager::getInstance()->getCore()->removeAccount(account);
	}
	
	emit accountSettingsUpdated();
}

void AccountSettingsModel::enableRegister(std::shared_ptr<linphone::AccountParams> params, bool registerEnabled, QString contactParameters){
	bool findMessageExpires = false;
	QStringList parameters = contactParameters.split(";", Qt::SkipEmptyParts);
	for(int i = 0 ; i < parameters.size() ; ++i){
		QStringList fields = parameters[i].split("=");
		if( fields.size() > 1 && fields[0].simplified() == "message-expires"){
			findMessageExpires = true;
			if(!registerEnabled)// replace message-expires by 0 in order to not get new incoming messages.
				parameters[i] = Constants::DefaultContactParametersOnRemove;
			else if(!params->registerEnabled() && fields[1].toInt() == 0)
				parameters[i] = Constants::DefaultContactParameters;
		}
	}
	if(!findMessageExpires){
		if(!registerEnabled)// message-expires was not found we need to disable the account.
			parameters.push_back(Constants::DefaultContactParametersOnRemove);
		else if(!params->registerEnabled())// Switch on
			parameters.push_back(Constants::DefaultContactParameters);
	}
	params->setContactParameters(Utils::appStringToCoreString(parameters.join(";")));
	params->enableRegister(registerEnabled);
}

bool AccountSettingsModel::addOrUpdateAccount(
		const shared_ptr<linphone::Account> &account,
		const QVariantMap &data
		) {
	bool newPublishPresence = false;
	auto accountParams = account->getParams()->clone();
	
	QString literal = data["sipAddress"].toString();
	
	// Sip address.
	{
		
		shared_ptr<linphone::Address> address = Utils::interpretUrl(literal);
		if (!address) {
			qWarning() << QStringLiteral("Unable to create sip address object from: `%1`.").arg(literal);
			return false;
		}
		
		if (accountParams->setIdentityAddress(address)) {
			qWarning() << QStringLiteral("Unable to set identity address: `%1`.")
						  .arg(Utils::coreStringToAppString(address->asStringUriOnly()));
			return false;
		}
	}
	
	// Server address.
	{
		auto serverAddress = Utils::interpretUrl(data["serverAddress"].toString());
		
		if (accountParams->setServerAddress(serverAddress)) {
			qWarning() << QStringLiteral("Unable to add server address: `%1`.").arg(serverAddress->asString().c_str());
			return false;
		}
	}
	
	if(data.contains("registrationDuration"))
		accountParams->setExpires(data["registrationDuration"].toInt());
	if(data.contains("publishDuration"))
		accountParams->setPublishExpires(data["publishDuration"].toInt());
	if(data.contains("route") && data["route"].toString() != "") {
		std::list<std::shared_ptr<linphone::Address>> routes;
		routes.push_back(Utils::interpretUrl(data["route"].toString()));
		accountParams->setRoutesAddresses(routes);
	}
	QString txt = data["conferenceUri"].toString();// Var is used for debug
	accountParams->setConferenceFactoryUri(Utils::appStringToCoreString(txt));
	txt = data["videoConferenceUri"].toString();
	accountParams->setAudioVideoConferenceFactoryAddress(Utils::interpretUrl(txt));
	accountParams->setLimeServerUrl(Utils::appStringToCoreString(data["limeServerUrl"].toString()));

	QString contactParameters = Utils::coreStringToAppString(accountParams->getContactParameters());
	if(data.contains("contactParams"))
		contactParameters = data["contactParams"].toString();
	if(data.contains("avpfInterval"))
		accountParams->setAvpfRrInterval(uint8_t(data["avpfInterval"].toInt()));
	if(data.contains("registerEnabled")){
		enableRegister(accountParams, data["registerEnabled"].toBool(), contactParameters);
	}else{
		accountParams->setContactParameters(Utils::appStringToCoreString(contactParameters));
	}
	if(data.contains("publishPresence")) {
		newPublishPresence = accountParams->publishEnabled() != data["publishPresence"].toBool();
		accountParams->enablePublish(data["publishPresence"].toBool());
	}else
		newPublishPresence = accountParams->publishEnabled();
	if(data.contains("avpfEnabled"))
		accountParams->setAvpfMode(data["avpfEnabled"].toBool()
			? linphone::AVPFMode::Enabled
			: linphone::AVPFMode::Default
			  );
	if(data.contains("dialPrefix"))
		accountParams->setInternationalPrefix(Utils::appStringToCoreString(data["dialPrefix"].toString()));
	if(data.contains("dialPrefixCallChat"))
		accountParams->setUseInternationalPrefixForCallsAndChats(data["dialPrefixCallChat"].toBool());
	if(data.contains("dialEscapePlus"))
		accountParams->enableDialEscapePlus(data["dialEscapePlus"].toBool());
	if(data.contains("rtpBundleEnabled"))
		accountParams->enableRtpBundle(data["rtpBundleEnabled"].toBool());
	
	
	shared_ptr<linphone::NatPolicy> natPolicy = accountParams->getNatPolicy();
	bool createdNat = !natPolicy;
	if (createdNat)
		natPolicy = CoreManager::getInstance()->getCore()->createNatPolicy();
	if(data.contains("iceEnabled"))
		natPolicy->enableIce(data["iceEnabled"].toBool());
	if(data.contains("iceEnabled"))
		natPolicy->enableStun(data["iceEnabled"].toBool());
	string turnUser, stunServer;
	if(data.contains("turnUser"))
		turnUser = Utils::appStringToCoreString(data["turnUser"].toString());
	if(data.contains("stunServer"))
		stunServer = Utils::appStringToCoreString(data["stunServer"].toString());
	if(data.contains("turnEnabled"))
		natPolicy->enableTurn(data["turnEnabled"].toBool());
	natPolicy->setStunServerUsername(turnUser);
	natPolicy->setStunServer(stunServer);
	
	if( createdNat)
		accountParams->setNatPolicy(natPolicy);
	
	if( turnUser != ""){
		shared_ptr<linphone::Core> core(CoreManager::getInstance()->getCore());
		shared_ptr<const linphone::AuthInfo> authInfo(core->findAuthInfo("", turnUser, stunServer));
		if (authInfo) {
			shared_ptr<linphone::AuthInfo> clonedAuthInfo(authInfo->clone());
			clonedAuthInfo->setUserid(turnUser);
			clonedAuthInfo->setUsername(turnUser);
			clonedAuthInfo->setPassword(Utils::appStringToCoreString(data["turnPassword"].toString()));
			core->addAuthInfo(clonedAuthInfo);
			core->removeAuthInfo(authInfo);
		} else
			core->addAuthInfo(linphone::Factory::get()->createAuthInfo(
								  turnUser,
								  turnUser,
								  Utils::appStringToCoreString(data["turnPassword"].toString()),
							  "",
							  stunServer,
							  ""
		));
	}
	if( newPublishPresence)
		emit publishPresenceChanged();
	return addOrUpdateAccount(account, accountParams);
}

bool AccountSettingsModel::addOrUpdateAccount (
  const QVariantMap &data
) {
	shared_ptr<linphone::Account> account;
	QString sipAddress = data["sipAddress"].toString();
	shared_ptr<linphone::Address> address = Utils::interpretUrl(sipAddress);
	
	for (const auto &databaseAccount : CoreManager::getInstance()->getAccountList())
	  if (databaseAccount->getParams()->getIdentityAddress()->weakEqual(address)) {
		account = databaseAccount;
	  }
	if(!account)
		account = createAccount(data.contains("configFilename") ? data["configFilename"].toString() : "create-app-sip-account.rc" );
	return addOrUpdateAccount(account, data);
}

shared_ptr<linphone::Account> AccountSettingsModel::createAccount(const QString& assistantFile) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	qInfo() << QStringLiteral("Set config on assistant: `%1`.").arg(assistantFile);
	core->getConfig()->loadFromXmlFile(Paths::getAssistantConfigDirPath() + assistantFile.toStdString());
	return core->createAccount(core->createAccountParams());
}

void AccountSettingsModel::addAuthInfo (
		const shared_ptr<linphone::AuthInfo> &authInfo,
		const QString &password,
		const QString &userId
		) {
	authInfo->setPassword(Utils::appStringToCoreString(password));
	authInfo->setUserid(Utils::appStringToCoreString(userId));
	
	CoreManager::getInstance()->getCore()->addAuthInfo(authInfo);
}

void AccountSettingsModel::eraseAllPasswords () {
	CoreManager::getInstance()->getCore()->clearAllAuthInfo();
}

// -----------------------------------------------------------------------------

QString AccountSettingsModel::getUsername () const {
	shared_ptr<const linphone::Address> address = getUsedSipAddress();
	const string displayName = address->getDisplayName();
	
	return Utils::coreStringToAppString(
				displayName.empty() ? address->getUsername() : displayName
									  );
}

void AccountSettingsModel::setUsername (const QString &username) {
	shared_ptr<const linphone::Address> address = getUsedSipAddress();
	shared_ptr<linphone::Address> newAddress = address->clone();
	QString oldUsername = Utils::coreStringToAppString(newAddress->getUsername());
	if( oldUsername != username) {
		if (newAddress->setDisplayName(Utils::appStringToCoreString(username))) {
			qWarning() << QStringLiteral("Unable to set displayName on sip address: `%1`.")
						  .arg(Utils::coreStringToAppString(newAddress->asStringUriOnly()));
		} else {
			setUsedSipAddress(newAddress);
			emit usernameChanged();
		}
	}
}

AccountSettingsModel::RegistrationState AccountSettingsModel::getRegistrationState () const {
	shared_ptr<linphone::Account> account = CoreManager::getInstance()->getCore()->getDefaultAccount();
	return account ? mapLinphoneRegistrationStateToUi(account->getState()) : RegistrationStateNoAccount;
}

// -----------------------------------------------------------------------------

QString AccountSettingsModel::getPrimaryUsername () const {
	return Utils::coreStringToAppString(
				CoreManager::getInstance()->getCore()->createPrimaryContactParsed()->getUsername()
				);
}

void AccountSettingsModel::setPrimaryUsername (const QString &username) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Address> primary = core->createPrimaryContactParsed();
	
	QString oldUsername = Utils::coreStringToAppString(primary->getUsername());
	if(oldUsername != username){
		primary->setUsername(Utils::appStringToCoreString(
								 username.isEmpty() ? APPLICATION_NAME : username
													  ));
		core->setPrimaryContact(primary->asString());
		emit primaryUsernameChanged();
	}
}

QString AccountSettingsModel::getPrimaryDisplayName () const {
	return Utils::coreStringToAppString(CoreManager::getInstance()->getCore()->createPrimaryContactParsed()->getDisplayName());
}

void AccountSettingsModel::setPrimaryDisplayName (const QString &displayName) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Address> primary = core->createPrimaryContactParsed();
	
	QString oldDisplayName = Utils::coreStringToAppString(primary->getDisplayName());
	if(oldDisplayName != displayName){
		primary->setDisplayName(Utils::appStringToCoreString(displayName));
		core->setPrimaryContact(primary->asString());
		emit primaryDisplayNameChanged();
	}
}

QString AccountSettingsModel::getPrimarySipAddress () const {
	return Utils::coreStringToAppString(
				CoreManager::getInstance()->getCore()->createPrimaryContactParsed()->asString()
				);
}

QString AccountSettingsModel::getDefaultAccountDomain() const{
	auto account = CoreManager::getInstance()->getCore()->getDefaultAccount();
	if(account)
		return Utils::coreStringToAppString(account->getParams()->getDomain());
	else
		return "";
}

// -----------------------------------------------------------------------------

QVariantList AccountSettingsModel::getAccounts () const {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	QVariantList accounts;
	auto settingsModel = CoreManager::getInstance()->getSettingsModel();
	if(settingsModel->getShowLocalSipAccount()) {
		QVariantMap account;
		account["sipAddress"] = Utils::coreStringToAppString(core->createPrimaryContactParsed()->asStringUriOnly());
		account["fullSipAddress"] = Utils::coreStringToAppString(core->createPrimaryContactParsed()->asString());
		account["unreadMessageCount"] = settingsModel->getStandardChatEnabled() || settingsModel->getSecureChatEnabled() ?  core->getUnreadChatMessageCount() : 0;
		account["missedCallCount"] = core->getMissedCallsCount();
		account["account"].setValue(nullptr);
		accounts << account;
	}
	
	for (const auto &account : CoreManager::getInstance()->getAccountList()) {
		QVariantMap accountMap;
		auto params = account->getParams();
		accountMap["sipAddress"] = Utils::coreStringToAppString(params->getIdentityAddress()->asStringUriOnly());
		accountMap["fullSipAddress"] = Utils::coreStringToAppString(params->getIdentityAddress()->asString());
		accountMap["account"].setValue(account);
		accountMap["unreadMessageCount"] = settingsModel->getStandardChatEnabled() || settingsModel->getSecureChatEnabled() ? account->getUnreadChatMessageCount() : 0;
		accountMap["missedCallCount"] = account->getMissedCallsCount();
		accountMap["registerEnabled"] = params->registerEnabled();
		accounts << accountMap;
	}
	
	return accounts;
}

// -----------------------------------------------------------------------------

void AccountSettingsModel::handleRegistrationStateChanged (
		const shared_ptr<linphone::Account> & account,
		linphone::RegistrationState state
		) {
	Q_UNUSED(state)
	auto coreManager = CoreManager::getInstance();
	shared_ptr<linphone::Account> defaultAccount = coreManager->getCore()->getDefaultAccount();
	if( state == linphone::RegistrationState::Cleared){
		auto authInfo = account->findAuthInfo();
		if(authInfo)
			QTimer::singleShot(60000, [authInfo](){// 60s is just to be sure. account_update remove deleted account only after 32s
				CoreManager::getInstance()->getCore()->removeAuthInfo(authInfo);
			});
	}else if(mRemovingAccounts.contains(account)){
		mRemovingAccounts.removeAll(account);
		QTimer::singleShot(100, [account, this](){// removeAccount cannot be called from callback
				CoreManager::getInstance()->getCore()->removeAccount(account);
				emit accountsChanged();
		});
	}
	if(defaultAccount == account)
		emit defaultRegistrationChanged();
	emit registrationStateChanged();
}
