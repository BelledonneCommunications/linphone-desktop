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
	QObject::connect(
				coreManager->getHandlers().get(), &CoreHandlers::registrationStateChanged,
				this, &AccountSettingsModel::handleRegistrationStateChanged
				);
	//QObject::connect(coreManager, &CoreManager::eventCountChanged, this, [this]() { emit accountSettingsUpdated(); });
	
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::usernameChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::sipAddressChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::fullSipAddressChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::registrationStateChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::conferenceURIChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::primaryDisplayNameChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::primaryUsernameChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::primarySipAddressChanged);
	QObject::connect(this, &AccountSettingsModel::accountSettingsUpdated, this, &AccountSettingsModel::accountsChanged);
}

// -----------------------------------------------------------------------------

shared_ptr<const linphone::Address> AccountSettingsModel::getUsedSipAddress () const {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::ProxyConfig> proxyConfig = core->getDefaultProxyConfig();
	
	return proxyConfig?proxyConfig->getIdentityAddress():core->createPrimaryContactParsed();
}

void AccountSettingsModel::setUsedSipAddress (const shared_ptr<const linphone::Address> &address) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::ProxyConfig> proxyConfig = core->getDefaultProxyConfig();
	
	proxyConfig ? proxyConfig->setIdentityAddress(address) : core->setPrimaryContact(address->asString());
	emit sipAddressChanged();
}

QString AccountSettingsModel::getUsedSipAddressAsStringUriOnly () const {
	return Utils::coreStringToAppString(getUsedSipAddress()->asStringUriOnly());
}

QString AccountSettingsModel::getUsedSipAddressAsString () const {
	return Utils::coreStringToAppString(getUsedSipAddress()->asString());
}
// -----------------------------------------------------------------------------

bool AccountSettingsModel::addOrUpdateProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
	Q_CHECK_PTR(proxyConfig);
	
	CoreManager *coreManager = CoreManager::getInstance();
	shared_ptr<linphone::Core> core = coreManager->getCore();
	
	list<shared_ptr<linphone::ProxyConfig>> proxyConfigs = core->getProxyConfigList();
	if (find(proxyConfigs.cbegin(), proxyConfigs.cend(), proxyConfig) != proxyConfigs.cend()) {
		if (proxyConfig->done() == -1) {
			qWarning() << QStringLiteral("Unable to update proxy config: `%1`.")
						  .arg(QString::fromStdString(proxyConfig->getIdentityAddress()->asString()));
			return false;
		}
		coreManager->getSettingsModel()->configureRlsUri();
	} else {
		if (core->addProxyConfig(proxyConfig) == -1) {
			qWarning() << QStringLiteral("Unable to add proxy config: `%1`.")
						  .arg(QString::fromStdString(proxyConfig->getIdentityAddress()->asString()));
			return false;
		}
		coreManager->getSettingsModel()->configureRlsUri(proxyConfig);
	}
	emit accountSettingsUpdated();
	
	return true;
}

QVariantMap AccountSettingsModel::getProxyConfigDescription (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
	Q_CHECK_PTR(proxyConfig);
	
	QVariantMap map;
	
	{
		const shared_ptr<const linphone::Address> address = proxyConfig->getIdentityAddress();
		map["sipAddress"] = address
				? Utils::coreStringToAppString(proxyConfig->getIdentityAddress()->asString())
				: QString("");
	}
	map["serverAddress"] = Utils::coreStringToAppString(proxyConfig->getServerAddr());
	map["registrationDuration"] = proxyConfig->getPublishExpires();
	
	if( map["serverAddress"].toString().toUpper().contains("TRANSPORT="))// transport has been specified : let the RFC select the transport
		map["transport"] = Utils::coreStringToAppString(proxyConfig->getTransport());
	else// Set to TLS as default
		map["transport"] = "tls";
	if( proxyConfig->getRoutes().size() > 0)
		map["route"] = Utils::coreStringToAppString(proxyConfig->getRoutes().front());
	else
		map["route"] = "";
	map["conferenceUri"] = Utils::coreStringToAppString(proxyConfig->getConferenceFactoryUri());
	map["contactParams"] = Utils::coreStringToAppString(proxyConfig->getContactParameters());
	map["avpfInterval"] = proxyConfig->getAvpfRrInterval();
	map["registerEnabled"] = proxyConfig->registerEnabled();
	map["publishPresence"] = proxyConfig->publishEnabled();
	map["avpfEnabled"] = proxyConfig->getAvpfMode() == linphone::AVPFMode::Enabled;
	map["registrationState"] = mapLinphoneRegistrationStateToUi(proxyConfig->getState());
	
	shared_ptr<linphone::NatPolicy> natPolicy = proxyConfig->getNatPolicy();
	bool createdNat = !natPolicy;
	if (createdNat)
		natPolicy = proxyConfig->getCore()->createNatPolicy();
	map["iceEnabled"] = natPolicy->iceEnabled();
	map["turnEnabled"] = natPolicy->turnEnabled();
	
	const string &turnUser(natPolicy->getStunServerUsername());
	const string &stunServer(natPolicy->getStunServer());
	
	map["turnUser"] = Utils::coreStringToAppString(turnUser);
	map["stunServer"] = Utils::coreStringToAppString(stunServer);
	
	if (createdNat)
		proxyConfig->setNatPolicy(natPolicy);
	
	shared_ptr<const linphone::AuthInfo> authInfo = CoreManager::getInstance()->getCore()->findAuthInfo(
				"", turnUser, stunServer
				);
	map["turnPassword"] = authInfo ? Utils::coreStringToAppString(authInfo->getPassword()) : QString("");
	
	return map;
}

QString AccountSettingsModel::getConferenceURI() const{
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::ProxyConfig> proxyConfig = core->getDefaultProxyConfig();
	return proxyConfig ? Utils::coreStringToAppString(proxyConfig->getConferenceFactoryUri()) : "";
}

void AccountSettingsModel::setDefaultProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	if (core->getDefaultProxyConfig() != proxyConfig) {
		core->setDefaultProxyConfig(proxyConfig);
		emit accountSettingsUpdated();
		emit defaultProxyChanged();
	}
}

void AccountSettingsModel::setDefaultProxyConfigFromSipAddress (const QString &sipAddress) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	auto address = Utils::interpretUrl(sipAddress);
	if ( core->createPrimaryContactParsed()->weakEqual(address)) {
		setDefaultProxyConfig(nullptr);
		return;
	}
	
	for (const auto &proxyConfig : core->getProxyConfigList())
		if (proxyConfig->getIdentityAddress()->weakEqual(address)) {
			setDefaultProxyConfig(proxyConfig);
			return;
		}
	
	qWarning() << "Unable to set default proxy config from:" << sipAddress;
}
void AccountSettingsModel::removeProxyConfig (const shared_ptr<linphone::ProxyConfig> &proxyConfig) {
	Q_CHECK_PTR(proxyConfig);
	
	CoreManager *coreManager = CoreManager::getInstance();
	std::shared_ptr<linphone::ProxyConfig> newProxy = nullptr;
	std::list<std::shared_ptr<linphone::ProxyConfig>> allProxies = coreManager->getCore()->getProxyConfigList();
	if( proxyConfig == coreManager->getCore()->getDefaultProxyConfig()){
		for(auto proxy : allProxies){
			if( proxy != proxyConfig ){
				newProxy = proxy;
				break;
			}
		}
		setDefaultProxyConfig(newProxy);
	}
// "message-expires" is used to keep contact for messages. Setting to 0 will remove the contact for messages too.
// Check if a "message-expires" exists and set it to 0
	QStringList parameters = Utils::coreStringToAppString(proxyConfig->getContactParameters()).split(";");
	for(int i = 0 ; i < parameters.size() ; ++i){
		QStringList fields = parameters[i].split("=");
		if( fields.size() > 1 && fields[0].simplified() == "message-expires"){
			parameters[i] = Constants::DefaultContactParametersOnRemove;
		}
	}
	proxyConfig->edit();
	proxyConfig->setContactParameters(Utils::appStringToCoreString(parameters.join(";")));
	if (proxyConfig->done() == -1) {
		qWarning() << QStringLiteral("Unable to reset message-expiry property before removing proxy config: `%1`.")
				  .arg(QString::fromStdString(proxyConfig->getIdentityAddress()->asString()));
	}else if(proxyConfig->registerEnabled()) { // Wait for update
		mRemovingProxies.push_back(proxyConfig);
	}else{// Registration is not enabled : Removing without wait.
		CoreManager::getInstance()->getCore()->removeProxyConfig(proxyConfig);
	}
	
	emit accountSettingsUpdated();
}

bool AccountSettingsModel::addOrUpdateProxyConfig (
		const shared_ptr<linphone::ProxyConfig> &proxyConfig,
		const QVariantMap &data
		) {
	Q_CHECK_PTR(proxyConfig);
	bool newPublishPresence = false;
	
	proxyConfig->edit();
	
	QString literal = data["sipAddress"].toString();
	
	// Sip address.
	{
		
		shared_ptr<linphone::Address> address = Utils::interpretUrl(literal);
		if (!address) {
			qWarning() << QStringLiteral("Unable to create sip address object from: `%1`.").arg(literal);
			return false;
		}
		
		if (proxyConfig->setIdentityAddress(address)) {
			qWarning() << QStringLiteral("Unable to set identity address: `%1`.")
						  .arg(Utils::coreStringToAppString(address->asStringUriOnly()));
			return false;
		}
	}
	
	// Server address.
	{
		QString serverAddress = data["serverAddress"].toString();
		
		if (proxyConfig->setServerAddr(Utils::appStringToCoreString(serverAddress))) {
			qWarning() << QStringLiteral("Unable to add server address: `%1`.").arg(serverAddress);
			return false;
		}
	}
	
	if(data.contains("registrationDuration"))
		proxyConfig->setPublishExpires(data["registrationDuration"].toInt());
	if(data.contains("route"))
		proxyConfig->setRoute(Utils::appStringToCoreString(data["route"].toString()));
	QString conferenceURI = data["conferenceUri"].toString();
	if(!conferenceURI.isEmpty())
		proxyConfig->setConferenceFactoryUri(Utils::appStringToCoreString(conferenceURI));
	if(data.contains("contactParams"))
		proxyConfig->setContactParameters(Utils::appStringToCoreString(data["contactParams"].toString()));
	if(data.contains("avpfInterval"))
		proxyConfig->setAvpfRrInterval(uint8_t(data["avpfInterval"].toInt()));
	if(data.contains("registerEnabled"))
		proxyConfig->enableRegister(data.contains("registerEnabled") ? data["registerEnabled"].toBool() : true);
	if(data.contains("publishPresence")) {
		newPublishPresence = proxyConfig->publishEnabled() != data["publishPresence"].toBool();
		proxyConfig->enablePublish(data["publishPresence"].toBool());
	}else
		newPublishPresence = proxyConfig->publishEnabled();
	if(data.contains("avpfEnabled"))
		proxyConfig->setAvpfMode(data["avpfEnabled"].toBool()
			? linphone::AVPFMode::Enabled
			: linphone::AVPFMode::Default
			  );
	
	shared_ptr<linphone::NatPolicy> natPolicy = proxyConfig->getNatPolicy();
	bool createdNat = !natPolicy;
	if (createdNat)
		natPolicy = proxyConfig->getCore()->createNatPolicy();
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
		proxyConfig->setNatPolicy(natPolicy);
	
	shared_ptr<linphone::Core> core(proxyConfig->getCore());
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
	if( newPublishPresence)
		emit publishPresenceChanged();
	return addOrUpdateProxyConfig(proxyConfig);
}

bool AccountSettingsModel::addOrUpdateProxyConfig (
  const QVariantMap &data
) {
	shared_ptr<linphone::ProxyConfig> proxyConfig;
	QString sipAddress = data["sipAddress"].toString();
	shared_ptr<linphone::Address> address = CoreManager::getInstance()->getCore()->interpretUrl(sipAddress.toStdString());
	
	for (const auto &databaseProxyConfig : CoreManager::getInstance()->getCore()->getProxyConfigList())
	  if (databaseProxyConfig->getIdentityAddress()->weakEqual(address)) {
		proxyConfig = databaseProxyConfig;
	  }
	if(!proxyConfig)
		proxyConfig = createProxyConfig(data.contains("configFilename") ? data["configFilename"].toString() : "create-app-sip-account.rc" );
	return addOrUpdateProxyConfig(proxyConfig, data);
}

shared_ptr<linphone::ProxyConfig> AccountSettingsModel::createProxyConfig (const QString& assistantFile) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	qInfo() << QStringLiteral("Set config on assistant: `%1`.").arg(assistantFile);
	core->getConfig()->loadFromXmlFile(Paths::getAssistantConfigDirPath() + assistantFile.toStdString());
	core->enableLimeX3Dh(core->getLimeX3DhServerUrl() != "");
	return core->createProxyConfig();
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
	shared_ptr<linphone::ProxyConfig> proxyConfig = CoreManager::getInstance()->getCore()->getDefaultProxyConfig();
	return proxyConfig ? mapLinphoneRegistrationStateToUi(proxyConfig->getState()) : RegistrationStateNoProxy;
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

// -----------------------------------------------------------------------------

QVariantList AccountSettingsModel::getAccounts () const {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	QVariantList accounts;
	
	if(CoreManager::getInstance()->getSettingsModel()->getShowLocalSipAccount()) {
		QVariantMap account;
		auto address = core->createPrimaryContactParsed();
		int unreadChatMessageCount = CoreManager::getInstance()->getUnreadChatMessage(address);
		
		account["sipAddress"] = Utils::coreStringToAppString(address->asStringUriOnly());
		account["fullSipAddress"] = Utils::coreStringToAppString(address->asString());
		account["unreadMessageCount"] = unreadChatMessageCount;
		account["missedCallCount"] = CoreManager::getInstance()->getMissedCallCountFromLocal(account["sipAddress"].toString());
		account["proxyConfig"].setValue(nullptr);
		accounts << account;
	}
	
	for (const auto &proxyConfig : core->getProxyConfigList()) {
		QVariantMap account;
		
		auto proxyAddress = proxyConfig->getIdentityAddress();
		int unreadChatMessageCount = CoreManager::getInstance()->getUnreadChatMessage(proxyAddress);
		account["sipAddress"] = Utils::coreStringToAppString(proxyAddress->asStringUriOnly());
		account["fullSipAddress"] = Utils::coreStringToAppString(proxyAddress->asString());
		account["proxyConfig"].setValue(proxyConfig);
		account["unreadMessageCount"] = unreadChatMessageCount;
		account["missedCallCount"] = CoreManager::getInstance()->getMissedCallCountFromLocal(account["sipAddress"].toString());
		accounts << account;
	}
	
	return accounts;
}

// -----------------------------------------------------------------------------

void AccountSettingsModel::handleRegistrationStateChanged (
		const shared_ptr<linphone::ProxyConfig> & proxy,
		linphone::RegistrationState state
		) {
	Q_UNUSED(proxy)
	Q_UNUSED(state)
	auto coreManager = CoreManager::getInstance();
	shared_ptr<linphone::ProxyConfig> defaultProxyConfig = coreManager->getCore()->getDefaultProxyConfig();
	if( state == linphone::RegistrationState::Cleared){
		auto authInfo = proxy->findAuthInfo();
		if(authInfo)
			QTimer::singleShot(60000, [authInfo](){// 60s is just to be sure. proxy_update remove deleted proxy only after 32s
				CoreManager::getInstance()->getCore()->removeAuthInfo(authInfo);
			});
		coreManager->getSettingsModel()->configureRlsUri();
	}else if(mRemovingProxies.contains(proxy)){
		mRemovingProxies.removeAll(proxy);
		QTimer::singleShot(100, [proxy, this](){// removeProxyConfig cannot be called from callback
				CoreManager::getInstance()->getCore()->removeProxyConfig(proxy);
				emit accountsChanged();
		});
	}
	if(defaultProxyConfig == proxy)
		emit defaultRegistrationChanged();
	emit registrationStateChanged();
}
