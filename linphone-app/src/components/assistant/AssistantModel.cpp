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

#include "app/paths/Paths.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"

#include "AssistantModel.hpp"

#include <linphone/FlexiAPIClient.hh>

#include <QtDebug>
#include <QTimer>

// =============================================================================

using namespace std;

class AssistantModel::Handlers : public linphone::AccountCreatorListener {
public:
	Handlers (AssistantModel *assistant) {
		mAssistant = assistant;
	}
	
private:
	void createAccount (const shared_ptr<linphone::AccountCreator> &creator) {
		shared_ptr<linphone::ProxyConfig> proxyConfig = creator->createProxyConfig();
		auto account = CoreManager::getInstance()->getCore()->getAccountByIdkey(proxyConfig->getIdkey());
		if(account){
			CoreManager::getInstance()->getSettingsModel()->configureRlsUri(account);
			CoreManager::getInstance()->getAccountSettingsModel()->setDefaultAccount(account);
		}
	}
	
	void onCreateAccount (
			const shared_ptr<linphone::AccountCreator> & accountCreator,
			linphone::AccountCreator::Status status,
			const string &
			) override {
		if (status == linphone::AccountCreator::Status::AccountCreated){
			emit mAssistant->createStatusChanged(QString(""));
		}else {
			if (status == linphone::AccountCreator::Status::RequestFailed)
				emit mAssistant->createStatusChanged(tr("requestFailed"));
			else if (status == linphone::AccountCreator::Status::ServerError)
				emit mAssistant->createStatusChanged(tr("cannotSendSms"));
			else
				emit mAssistant->createStatusChanged(tr("accountAlreadyExists"));
		}
	}
	
	void onIsAccountExist (
			const shared_ptr<linphone::AccountCreator> &creator,
			linphone::AccountCreator::Status status,
			const string &
			) override {
		if (status == linphone::AccountCreator::Status::AccountExist || status == linphone::AccountCreator::Status::AccountExistWithAlias) {
			createAccount(creator);
			CoreManager::getInstance()->getSipAddressesModel()->reset();
			emit mAssistant->loginStatusChanged(QString(""));
		} else {
			if (status == linphone::AccountCreator::Status::RequestFailed)
				emit mAssistant->loginStatusChanged(tr("requestFailed"));
			else
				emit mAssistant->loginStatusChanged(tr("loginWithUsernameFailed"));
		}
	}
	
	void onActivateAccount (
			const shared_ptr<linphone::AccountCreator> &creator,
			linphone::AccountCreator::Status status,
			const string &
			) override {
		if (
				status == linphone::AccountCreator::Status::AccountActivated ||
				status == linphone::AccountCreator::Status::AccountAlreadyActivated
				) {
			if (creator->getEmail().empty())
				createAccount(creator);
			CoreManager::getInstance()->getSipAddressesModel()->reset();
			emit mAssistant->activateStatusChanged(QString(""));
		} else {
			if (status == linphone::AccountCreator::Status::RequestFailed)
				emit mAssistant->activateStatusChanged(tr("requestFailed"));
			else
				emit mAssistant->activateStatusChanged(tr("smsActivationFailed"));
		}
	}
	
	void onIsAccountActivated (
			const shared_ptr<linphone::AccountCreator> &creator,
			linphone::AccountCreator::Status status,
			const string &
			) override {
		if (status == linphone::AccountCreator::Status::AccountActivated) {
			createAccount(creator);
			CoreManager::getInstance()->getSipAddressesModel()->reset();
			emit mAssistant->activateStatusChanged(QString(""));
		} else {
			if (status == linphone::AccountCreator::Status::RequestFailed)
				emit mAssistant->activateStatusChanged(tr("requestFailed"));
			else
				emit mAssistant->activateStatusChanged(tr("emailActivationFailed"));
		}
	}
	
	void onRecoverAccount (
			const shared_ptr<linphone::AccountCreator> &,
			linphone::AccountCreator::Status status,
			const string &
			) override {
		if (status == linphone::AccountCreator::Status::RequestOk) {
			CoreManager::getInstance()->getSipAddressesModel()->reset();
			emit mAssistant->recoverStatusChanged(QString(""));
		} else {
			if (status == linphone::AccountCreator::Status::RequestFailed)
				emit mAssistant->recoverStatusChanged(tr("requestFailed"));
			else if (status == linphone::AccountCreator::Status::ServerError)
				emit mAssistant->recoverStatusChanged(tr("cannotSendSms"));
			else
				emit mAssistant->recoverStatusChanged(tr("loginWithPhoneNumberFailed"));
		}
	}
	
private:
	AssistantModel *mAssistant;
};

// -----------------------------------------------------------------------------

AssistantModel::AssistantModel (QObject *parent) : QObject(parent) {
	mHandlers = make_shared<AssistantModel::Handlers>(this);
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	connect(CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::foundQRCode, this, &AssistantModel::onQRCodeFound);
	mIsReadingQRCode = false;
	mAccountCreator = core->createAccountCreator(
				core->getConfig()->getString("assistant", "xmlrpc_url", Constants::DefaultXmlrpcUri)
				);
	mAccountCreator->addListener(mHandlers);
	connect(this, &AssistantModel::apiReceived, this, &AssistantModel::onApiReceived);
}

AssistantModel::~AssistantModel(){
	setIsReadingQRCode(false);
}

// -----------------------------------------------------------------------------

void AssistantModel::activate () {
	if (mAccountCreator->getEmail().empty())
		mAccountCreator->activateAccount();
	else
		mAccountCreator->isAccountActivated();
}

void AssistantModel::create () {
	mAccountCreator->createAccount();
}

void AssistantModel::login () {
	if (!mCountryCode.isEmpty()) {
		mAccountCreator->recoverAccount();
		return;
	}
	
	shared_ptr<linphone::Config> config(CoreManager::getInstance()->getCore()->getConfig());
	if (!config->getString("assistant", "xmlrpc_url", "").empty()) {
		mAccountCreator->isAccountExist();
		return;
	}
	
	// No verification if no xmlrpc url. Use addOtherSipAccount directly.
	QVariantMap map;
	map["sipDomain"] = Utils::coreStringToAppString(config->getString("assistant", "domain", ""));
	map["username"] = getUsername();
	map["password"] = getPassword();
	emit loginStatusChanged(addOtherSipAccount(map) ? QString("") : tr("unableToAddAccount"));
}

void AssistantModel::reset () {
	mCountryCode = QString("");
	mAccountCreator->reset();
	
	emit emailChanged(QString(""), QString(""));
	emit passwordChanged(QString(""), QString(""));
	emit phoneNumberChanged(QString(""), QString(""));
	emit usernameChanged(QString(""), QString(""));
}

// -----------------------------------------------------------------------------

bool AssistantModel::addOtherSipAccount (const QVariantMap &map) {
	CoreManager *coreManager = CoreManager::getInstance();
	
	shared_ptr<linphone::Factory> factory = linphone::Factory::get();
	shared_ptr<linphone::Core> core = coreManager->getCore();
	std::shared_ptr<linphone::Account> account;
	std::string accountIdKey = map["accountIdKey"].toString().toStdString();
	if( accountIdKey  != "")
		account = core->getAccountByIdkey(accountIdKey);
	shared_ptr<linphone::AccountParams> accountParams = core->createAccountParams();
	
	
	const QString domain = map["sipDomain"].toString();
	
	QString sipAddress = QStringLiteral("sip:%1@%2")
			.arg(map["username"].toString()).arg(domain);
	{
		// Server address.
		shared_ptr<linphone::Address> address = factory->createAddress(
					Utils::appStringToCoreString(QStringLiteral("sip:%1").arg(domain))
					);
		if(!address) {
			qWarning() << QStringLiteral("Unable to create address from domain `%1`.")
						  .arg(domain);
			return false;
		}
		const QString &transport(map["transport"].toString());
		if (!transport.isEmpty()) {
			LinphoneEnums::TransportType transportType;
			LinphoneEnums::fromString(transport, &transportType);
			address->setTransport(LinphoneEnums::toLinphone(transportType));
		}
		if (accountParams->setServerAddress(address)) {
			qWarning() << QStringLiteral("Unable to add server address: `%1`.")
						  .arg(QString::fromStdString(address->asString()));
			return false;
		}
	}
	
	// Sip Address.
	shared_ptr<linphone::Address> address = factory->createAddress(Utils::appStringToCoreString(sipAddress));
	if (!address) {
		qWarning() << QStringLiteral("Unable to create sip address object from: `%1`.").arg(sipAddress);
		return false;
	}
	
	address->setDisplayName(Utils::appStringToCoreString(map["displayName"].toString()));
	accountParams->setIdentityAddress(address);
	
	// AuthInfo.
	core->addAuthInfo(
				factory->createAuthInfo(
					address->getUsername(), // Username.
					"", // User ID.
					Utils::appStringToCoreString(map["password"].toString()), // Password.
				"", // HA1.
				"", // Realm.
				address->getDomain() // Domain.
				)
			);
	
	AccountSettingsModel *accountSettingsModel = coreManager->getAccountSettingsModel();
	if (accountSettingsModel->addOrUpdateAccount(account, accountParams)) {
		accountSettingsModel->setDefaultAccount(account);
		return true;
	}
	return false;
}
void AssistantModel::createTestAccount(){
}
void AssistantModel::generateQRCode(){
	auto flexiAPIClient = make_shared<FlexiAPIClient>(CoreManager::getInstance()->getCore()->cPtr());
	flexiAPIClient
		->accountProvision()
		->then([this](FlexiAPIClient::Response response){
			emit newQRCodeReceived(response.json()["provisioning_token"].asCString());
		})
		->error([this](FlexiAPIClient::Response response){
			emit newQRCodeNotReceived(Utils::coreStringToAppString(response.body), response.code);
		});
}
void AssistantModel::requestQRCode(){
	auto flexiAPIClient = make_shared<FlexiAPIClient>(CoreManager::getInstance()->getCore()->cPtr());
	
	flexiAPIClient
		->accountAuthTokenCreate()
		->then([this](FlexiAPIClient::Response response) {
			mToken = response.json()["token"].asCString();
			emit newQRCodeReceived(mToken);
			QTimer::singleShot(5000, this, &AssistantModel::checkLinkingAccount);
		})->error([this](FlexiAPIClient::Response response){
			qWarning() << response.code << " => " << response.body.c_str();
			emit newQRCodeNotReceived(Utils::coreStringToAppString(response.body), response.code);
		});
}

void AssistantModel::readQRCode(){
	setIsReadingQRCode(!mIsReadingQRCode);
}
void AssistantModel::newQRCodeNotReceivedTest(){
	emit newQRCodeNotReceived("Cannot generate a provisioning key",0);
}
void AssistantModel::checkLinkingAccount(){
	auto flexiAPIClient = make_shared<FlexiAPIClient>(CoreManager::getInstance()->getCore()->cPtr());
	flexiAPIClient
		->accountApiKeyFromAuthTokenGenerate(mToken.toStdString())
		->then([this](FlexiAPIClient::Response response)mutable{
			emit apiReceived(Utils::coreStringToAppString(response.json()["api_key"].asCString()));
		})->error([this](FlexiAPIClient::Response){
			QTimer::singleShot(5000, this, &AssistantModel::checkLinkingAccount);
	});
}

void AssistantModel::onApiReceived(QString apiKey){
	auto flexiAPIClient = make_shared<FlexiAPIClient>(CoreManager::getInstance()->getCore()->cPtr());
	flexiAPIClient->setApiKey(Utils::appStringToCoreString(apiKey).c_str())
		->accountProvision()
		->then([this](FlexiAPIClient::Response response){
			emit provisioningTokenReceived(response.json()["provisioning_token"].asCString());
		})->error([this](FlexiAPIClient::Response response){
			//it provisioningTokenReceived("token");
			emit this->newQRCodeNotReceived("Cannot generate a provisioning key"+(response.body.empty() ? "" : " : " +Utils::coreStringToAppString(response.body)), response.code);
	});
}
void AssistantModel::onQRCodeFound(const std::string & result){
	setIsReadingQRCode(false);
	emit qRCodeFound(Utils::coreStringToAppString(result));
}

void AssistantModel::attachAccount(const QString& token){
	auto flexiAPIClient = make_shared<FlexiAPIClient>(CoreManager::getInstance()->getCore()->cPtr());
	flexiAPIClient->
	accountAuthTokenAttach(Utils::appStringToCoreString(token))
		->then([this](FlexiAPIClient::Response response){
			qWarning() << "Attached";
			emit qRCodeAttached();
		})
		->error([this](FlexiAPIClient::Response response){
			emit qRCodeNotAttached("Cannot attach"+ (response.body.empty() ? "" : " : " +Utils::coreStringToAppString(response.body)), response.code);
		});
}

// -----------------------------------------------------------------------------

QString AssistantModel::getEmail () const {
	return Utils::coreStringToAppString(mAccountCreator->getEmail());
}

void AssistantModel::setEmail (const QString &email) {
	shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
	QString error;
	
	switch (mAccountCreator->setEmail(Utils::appStringToCoreString(email))) {
		case linphone::AccountCreator::EmailStatus::Ok:
			break;
		case linphone::AccountCreator::EmailStatus::Malformed:
			error = tr("emailStatusMalformed");
			break;
		case linphone::AccountCreator::EmailStatus::InvalidCharacters:
			error = tr("emailStatusMalformedInvalidCharacters");
			break;
	}
	
	emit emailChanged(email, error);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getPassword () const {
	return Utils::coreStringToAppString(mAccountCreator->getPassword());
}

void AssistantModel::setPassword (const QString &password) {
	shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
	QString error;
	
	switch (mAccountCreator->setPassword(Utils::appStringToCoreString(password))) {
		case linphone::AccountCreator::PasswordStatus::Ok:
			break;
		case linphone::AccountCreator::PasswordStatus::TooShort:
			error = tr("passwordStatusTooShort").arg(config->getInt("assistant", "password_min_length", 1));
			break;
		case linphone::AccountCreator::PasswordStatus::TooLong:
			error = tr("passwordStatusTooLong").arg(config->getInt("assistant", "password_max_length", -1));
			break;
		case linphone::AccountCreator::PasswordStatus::InvalidCharacters:
			error = tr("passwordStatusInvalidCharacters")
					.arg(Utils::coreStringToAppString(config->getString("assistant", "password_regex", "")));
			break;
		case linphone::AccountCreator::PasswordStatus::MissingCharacters:
			error = tr("passwordStatusMissingCharacters")
					.arg(Utils::coreStringToAppString(config->getString("assistant", "missing_characters", "")));
			break;
	}
	
	emit passwordChanged(password, error);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getCountryCode () const {
	return mCountryCode;
}

void AssistantModel::setCountryCode (const QString &countryCode) {
	mCountryCode = countryCode;
	emit countryCodeChanged(countryCode);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getPhoneNumber () const {
	return Utils::coreStringToAppString(mAccountCreator->getPhoneNumber());
}

void AssistantModel::setPhoneNumber (const QString &phoneNumber) {
	shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
	QString error;
	
	switch (static_cast<linphone::AccountCreator::PhoneNumberStatus>(
				mAccountCreator->setPhoneNumber(Utils::appStringToCoreString(phoneNumber), Utils::appStringToCoreString(mCountryCode))
				)) {
		case linphone::AccountCreator::PhoneNumberStatus::Ok:
			break;
		case linphone::AccountCreator::PhoneNumberStatus::Invalid:
			error = tr("phoneNumberStatusInvalid");
			break;
		case linphone::AccountCreator::PhoneNumberStatus::TooShort:
			error = tr("phoneNumberStatusTooShort");
			break;
		case linphone::AccountCreator::PhoneNumberStatus::TooLong:
			error = tr("phoneNumberStatusTooLong");
			break;
		case linphone::AccountCreator::PhoneNumberStatus::InvalidCountryCode:
			error = tr("phoneNumberStatusInvalidCountryCode");
			break;
		default:
			break;
	}
	
	emit phoneNumberChanged(phoneNumber, error);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getUsername () const {
	return Utils::coreStringToAppString(mAccountCreator->getUsername());
}

void AssistantModel::setUsername (const QString &username) {
	emit usernameChanged(
				username,
				mapAccountCreatorUsernameStatusToString(
					mAccountCreator->setUsername(Utils::appStringToCoreString(username))
					)
				);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getDisplayName () const {
	return Utils::coreStringToAppString(mAccountCreator->getDisplayName());
}

void AssistantModel::setDisplayName (const QString &displayName) {
	emit displayNameChanged(
				displayName,
				mapAccountCreatorUsernameStatusToString(
					mAccountCreator->setDisplayName(Utils::appStringToCoreString(displayName))
					)
				);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getActivationCode () const {
	return Utils::coreStringToAppString(mAccountCreator->getActivationCode());
}

void AssistantModel::setActivationCode (const QString &activationCode) {
	mAccountCreator->setActivationCode(Utils::appStringToCoreString(activationCode));
	emit activationCodeChanged(activationCode);
}

// -----------------------------------------------------------------------------

QString AssistantModel::getConfigFilename () const {
	return mConfigFilename;
}

void AssistantModel::setConfigFilename (const QString &configFilename) {
	mConfigFilename = configFilename;
	
	QString configPath = Utils::coreStringToAppString(Paths::getAssistantConfigDirPath()) + configFilename;
	qInfo() << QStringLiteral("Set config on assistant: `%1`.").arg(configPath);
	
	CoreManager::getInstance()->getCore()->getConfig()->loadFromXmlFile(
				Utils::appStringToCoreString(configPath)
				);
	
	emit configFilenameChanged(configFilename);
}

bool AssistantModel::getIsReadingQRCode() const{
	return mIsReadingQRCode;
}

void AssistantModel::setIsReadingQRCode(bool isReading){
	if( mIsReadingQRCode != isReading){
		if( CoreManager::getInstance()->getCore()->qrcodeVideoPreviewEnabled() != isReading){
			CoreManager::getInstance()->getCore()->enableQrcodeVideoPreview(isReading);
			//CoreManager::getInstance()->getCore()->enableVideoPreview(isReading);
		}
		mIsReadingQRCode = isReading;
		emit isReadingQRCodeChanged();
	}
}

// -----------------------------------------------------------------------------

QString AssistantModel::mapAccountCreatorUsernameStatusToString (linphone::AccountCreator::UsernameStatus status) const {
	shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
	QString error;
	
	switch (status) {
		case linphone::AccountCreator::UsernameStatus::Ok:
			break;
		case linphone::AccountCreator::UsernameStatus::TooShort:
			error = tr("usernameStatusTooShort").arg(config->getInt("assistant", "username_min_length", 1));
			break;
		case linphone::AccountCreator::UsernameStatus::TooLong:
			error = tr("usernameStatusTooLong").arg(config->getInt("assistant", "username_max_length", -1));
			break;
		case linphone::AccountCreator::UsernameStatus::InvalidCharacters:
			error = tr("usernameStatusInvalidCharacters")
					.arg(Utils::coreStringToAppString(config->getString("assistant", "username_regex", "")));
			break;
		case linphone::AccountCreator::UsernameStatus::Invalid:
			error = tr("usernameStatusInvalid");
			break;
	}
	
	return error;
}
