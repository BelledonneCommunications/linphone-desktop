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

#include "AccountManager.hpp"

#include <QDebug>
#include <QDesktopServices>
#include <QEventLoop>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QTemporaryFile>
#include <QUrl>

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(AccountManager)

AccountManager::AccountManager(QObject *parent) : QObject(parent) {
	mustBeInLinphoneThread(getClassName());
}

AccountManager::~AccountManager() {
	mustBeInLinphoneThread("~" + getClassName());
}

std::shared_ptr<linphone::Account> AccountManager::createAccount(const QString &assistantFile) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	QString assistantPath = "://data/assistant/" + assistantFile;
	lInfo() << log().arg(QStringLiteral("Set config on assistant: `%1`.")).arg(assistantPath);
	QFile resource(assistantPath);
	auto file = QTemporaryFile::createNativeFile(resource);
	core->getConfig()->loadFromXmlFile(Utils::appStringToCoreString(file->fileName()));
	return core->createAccount(core->createAccountParams());
}

bool AccountManager::login(QString username,
                           QString password,
                           QString displayName,
                           QString domain,
                           linphone::TransportType transportType,
                           QString *errorMessage) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	auto factory = linphone::Factory::get();
	QString assistantFile = (!QString::compare(domain, "sip.linphone.org") || domain.isEmpty())
	                            ? "use-app-sip-account.rc"
	                            : "use-other-sip-account.rc";
	auto account = createAccount(assistantFile);
	auto params = account->getParams()->clone();
	// Sip address.
	auto identity = params->getIdentityAddress()->clone();
	username = Utils::getUsername(username);
	identity->setUsername(Utils::appStringToCoreString(username));

	if (mAccountModel) return false;

	auto otherAccounts = core->getAccountList();
	for (auto otherAccount : otherAccounts) {
		auto otherParams = otherAccount->getParams();
		if (otherParams->getIdentityAddress()->getUsername() == Utils::appStringToCoreString(username) &&
		    otherParams->getDomain() == Utils::appStringToCoreString(domain)) {
			//: "Le compte est déjà connecté"
			*errorMessage = tr("assistant_account_login_already_connected_error");
			return false;
		}
	}

	if (!displayName.isEmpty()) identity->setDisplayName(Utils::appStringToCoreString(displayName));
	if (!domain.isEmpty()) {
		identity->setDomain(Utils::appStringToCoreString(domain));
		if (QString::compare(domain, "sip.linphone.org")) {
			params->setLimeServerUrl("");
			auto serverAddress =
			    factory->createAddress(Utils::appStringToCoreString(QStringLiteral("sip:%1").arg(domain)));
			if (!serverAddress) {
				//: "Impossible de créer l'adresse proxy. Merci de vérifier le nom de domaine."
				*errorMessage = tr("assistant_account_login_proxy_address_error");
				return false;
			}
			serverAddress->setTransport(transportType);
			params->setServerAddress(serverAddress);
		}
	}
	if (params->setIdentityAddress(identity)) {
		qWarning() << log()
		                  .arg(QStringLiteral("Unable to set identity address: `%1`."))
		                  .arg(Utils::coreStringToAppString(identity->asStringUriOnly()));


		//: "Impossible de configurer l'adresse : `%1`."
		*errorMessage =
			tr("assistant_account_login_address_configuration_error").arg(Utils::coreStringToAppString(identity->asStringUriOnly()));
		return false;
	}

	if (account->setParams(params)) {
		//: "Impossible de configurer les paramètres du compte."
		*errorMessage = tr("assistant_account_login_params_configuration_error");
		return false;
	}
	auto authInfo = factory->createAuthInfo(Utils::appStringToCoreString(username), // Username.
	                                        "",                                     // User ID.
	                                        Utils::appStringToCoreString(password), // Password.
	                                        "",                                     // HA1.
	                                        "",                                     // Realm.
	                                        identity->getDomain()                   // Domain.
	);
	core->addAuthInfo(authInfo);
	mAccountModel = Utils::makeQObject_ptr<AccountModel>(account);
	mAccountModel->setSelf(mAccountModel);
	connect(mAccountModel.get(), &AccountModel::registrationStateChanged, this,
	        [this, authInfo, core](const std::shared_ptr<linphone::Account> &account, linphone::RegistrationState state,
								   const std::string &message) {
				QString errorMessage = QString::fromStdString(message);
		        if (mAccountModel && account == mAccountModel->getAccount()) {
			        if (state == linphone::RegistrationState::Failed) {
				        connect(
				            mAccountModel.get(), &AccountModel::removed, this, [this]() { mAccountModel = nullptr; },
				            Qt::SingleShotConnection);
						//: "Le couple identifiant mot de passe ne correspond pas"
						if (account->getError() == linphone::Reason::Forbidden) errorMessage = tr("assistant_account_login_forbidden_error");
						//: "Erreur durant la connexion"
						else errorMessage = tr("assistant_account_login_error");
						mAccountModel->removeAccount();
			        } else if (state == linphone::RegistrationState::Ok) {
				        core->setDefaultAccount(account);
				        emit mAccountModel->removeListener();
				        mAccountModel = nullptr;
			        }
				}
				emit registrationStateChanged(state, errorMessage);
	        });
	auto status = core->addAccount(account);
	if (status == -1) {
		//: "Impossible d'ajouter le compte."
		*errorMessage = tr("assistant_account_add_error");
		core->removeAuthInfo(authInfo);
		return false;
	}
	return true;
}

void AccountManager::registerNewAccount(const QString &username,
                                        const QString &password,
                                        RegisterType type,
                                        const QString &registerAddress,
                                        QString lastToken) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (!mAccountManagerServicesModel) {
		auto core = CoreModel::getInstance()->getCore();
		auto ams = core->createAccountManagerServices();
		mAccountManagerServicesModel = Utils::makeQObject_ptr<AccountManagerServicesModel>(ams);
	}
	connect(
	    mAccountManagerServicesModel.get(), &AccountManagerServicesModel::requestSuccessfull, this,
	    [this, username, password, type, registerAddress](
	        const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request, const std::string &data) {
		    if (request->getType() == linphone::AccountManagerServicesRequest::Type::AccountCreationRequestToken) {
			    QString verifyTokenUrl = Utils::coreStringToAppString(data);
			    qDebug() << "[AccountManager] request token succeed" << verifyTokenUrl;

			    QDesktopServices::openUrl(verifyTokenUrl);
			    auto creationToken = verifyTokenUrl.mid(verifyTokenUrl.lastIndexOf("/") + 1);

			    // QNetworkRequest req;
			    timer.setSingleShot(true);
			    timer.setInterval(2000);
			    QObject::connect(&timer, &QTimer::timeout, this, [this, creationToken]() {
				    mAccountManagerServicesModel->convertCreationRequestTokenIntoCreationToken(
				        Utils::appStringToCoreString(creationToken));
			    });
			    timer.start();
			    // req.setUrl(QUrl(verifyTokenUrl));

		    } else if (request->getType() == linphone::AccountManagerServicesRequest::Type::
		                                         AccountCreationTokenFromAccountCreationRequestToken) {
			    qDebug() << "[AccountManager] request token conversion succeed" << data;
			    emit tokenConversionSucceed(Utils::coreStringToAppString(data));
			    timer.stop();
			    mAccountManagerServicesModel->createAccountUsingToken(Utils::appStringToCoreString(username),
			                                                          Utils::appStringToCoreString(password), data);

		    } else if (request->getType() == linphone::AccountManagerServicesRequest::Type::CreateAccountUsingToken) {
			    auto core = CoreModel::getInstance()->getCore();
			    auto factory = linphone::Factory::get();
			    mCreatedSipAddress = Utils::coreStringToAppString(data);
			    auto createdSipIdentityAddress = ToolModel::interpretUrl(mCreatedSipAddress);
			    core->addAuthInfo(factory->createAuthInfo(Utils::appStringToCoreString(username), // Username.
			                                              "",                                     // User ID.
			                                              Utils::appStringToCoreString(password), // Password.
			                                              "",                                     // HA1.
			                                              "",                                     // Realm.
			                                              createdSipIdentityAddress->getDomain()  // Domain.
			                                              ));
			    if (type == RegisterType::Email) {
				    qDebug() << "[AccountManager] creation succeed, email verification" << registerAddress;
				    mAccountManagerServicesModel->linkEmailByEmail(
				        ToolModel::interpretUrl(Utils::coreStringToAppString(data)),
				        Utils::appStringToCoreString(registerAddress));
			    } else {
				    qDebug() << "[AccountManager] creation succeed, sms verification" << registerAddress;
				    mAccountManagerServicesModel->linkPhoneNumberBySms(
				        ToolModel::interpretUrl(Utils::coreStringToAppString(data)),
				        Utils::appStringToCoreString(registerAddress));
			    }
		    } else if (request->getType() ==
		               linphone::AccountManagerServicesRequest::Type::SendEmailLinkingCodeByEmail) {
			    qDebug() << "[AccountManager] send email succeed, link account using code";
			    emit newAccountCreationSucceed(mCreatedSipAddress, type, registerAddress);
			    mCreatedSipAddress.clear();
		    } else if (request->getType() ==
		               linphone::AccountManagerServicesRequest::Type::SendPhoneNumberLinkingCodeBySms) {
			    qDebug() << "[AccountManager] send phone number succeed, link account using code";
			    emit newAccountCreationSucceed(mCreatedSipAddress, type, registerAddress);
			    mCreatedSipAddress.clear();
		    }
	    });
	connect(
	    mAccountManagerServicesModel.get(), &AccountManagerServicesModel::requestError, this,
	    [this](const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request, int statusCode,
	           const std::string &errorMessage, const std::shared_ptr<const linphone::Dictionary> &parameterErrors) {
		    if (request->getType() == linphone::AccountManagerServicesRequest::Type::AccountCreationRequestToken) {
			    qDebug() << "[AccountManager] error creating request token :" << errorMessage;
			    emit registerNewAccountFailed(Utils::coreStringToAppString(errorMessage));
		    } else if (request->getType() == linphone::AccountManagerServicesRequest::Type::
		                                         AccountCreationTokenFromAccountCreationRequestToken) {
			    qDebug() << "[AccountManager] error converting token into creation token :" << errorMessage;
			    if (parameterErrors) {
				    timer.stop();
				    emit registerNewAccountFailed(Utils::coreStringToAppString(errorMessage));
			    } else {
				    timer.start();
			    }
		    } else if (request->getType() == linphone::AccountManagerServicesRequest::Type::CreateAccountUsingToken) {
			    qDebug() << "[AccountManager] error creating account :" << errorMessage;
			    if (parameterErrors) {
				    for (const std::string &key : parameterErrors->getKeys()) {
					    emit errorInField(Utils::coreStringToAppString(key),
					                      Utils::coreStringToAppString(errorMessage));
				    }
			    } else {
				    emit registerNewAccountFailed(Utils::coreStringToAppString(errorMessage));
			    }
		    } else if (request->getType() ==
		               linphone::AccountManagerServicesRequest::Type::SendEmailLinkingCodeByEmail) {
			    qDebug() << "[AccountManager] error sending code to email" << errorMessage;
			    if (parameterErrors) {
				    for (const std::string &key : parameterErrors->getKeys()) {
					    emit errorInField(Utils::coreStringToAppString(key),
					                      Utils::coreStringToAppString(errorMessage));
				    }
			    } else {
				    emit registerNewAccountFailed(Utils::coreStringToAppString(errorMessage));
			    }
		    } else if (request->getType() ==
		               linphone::AccountManagerServicesRequest::Type::SendPhoneNumberLinkingCodeBySms) {
			    qDebug() << "[AccountManager] error sending code to phone number" << errorMessage;
			    if (parameterErrors) {
				    for (const std::string &key : parameterErrors->getKeys()) {
					    emit errorInField(Utils::coreStringToAppString(key),
					                      Utils::coreStringToAppString(errorMessage));
				    }
			    } else {
				    emit registerNewAccountFailed(Utils::coreStringToAppString(errorMessage));
			    }
		    }
	    });
	if (lastToken.isEmpty()) {
		mAccountManagerServicesModel->requestToken();
	} else {
		emit tokenConversionSucceed(lastToken);
		mAccountManagerServicesModel->createAccountUsingToken(Utils::appStringToCoreString(username),
		                                                      Utils::appStringToCoreString(password),
		                                                      Utils::appStringToCoreString(lastToken));
	}
}

void AccountManager::linkNewAccountUsingCode(const QString &code,
                                             RegisterType registerType,
                                             const QString &sipAddress) {
	auto sipIdentityAddress = ToolModel::interpretUrl(sipAddress);
	if (!mAccountManagerServicesModel) {
		auto core = CoreModel::getInstance()->getCore();
		auto ams = core->createAccountManagerServices();
		mAccountManagerServicesModel = Utils::makeQObject_ptr<AccountManagerServicesModel>(ams);
	}
	connect(
	    mAccountManagerServicesModel.get(), &AccountManagerServicesModel::requestSuccessfull, this,
	    [this](const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request, const std::string &data) {
		    if (request->getType() == linphone::AccountManagerServicesRequest::Type::LinkEmailUsingCode) {
			    qDebug() << "[AccountManager] link email to account succeed" << data;
			    emit linkingNewAccountWithCodeSucceed();
		    } else if (request->getType() == linphone::AccountManagerServicesRequest::Type::LinkPhoneNumberUsingCode) {
			    qDebug() << "[AccountManager] link phone number to account succeed" << data;
			    emit linkingNewAccountWithCodeSucceed();
		    }
	    });
	connect(
	    mAccountManagerServicesModel.get(), &AccountManagerServicesModel::requestError, this,
	    [this](const std::shared_ptr<const linphone::AccountManagerServicesRequest> &request, int statusCode,
	           const std::string &errorMessage, const std::shared_ptr<const linphone::Dictionary> &parameterErrors) {
		    if (request->getType() == linphone::AccountManagerServicesRequest::Type::LinkEmailUsingCode) {
			    qDebug() << "[AccountManager] error linking email to account" << errorMessage;
		    } else if (request->getType() == linphone::AccountManagerServicesRequest::Type::LinkPhoneNumberUsingCode) {
			    qDebug() << "[AccountManager] error linking phone number to account" << errorMessage;
		    }
		    emit linkingNewAccountWithCodeFailed(Utils::coreStringToAppString(errorMessage));
	    });
	if (registerType == RegisterType::Email)
		mAccountManagerServicesModel->linkEmailToAccountUsingCode(sipIdentityAddress,
		                                                          Utils::appStringToCoreString(code));
	else
		mAccountManagerServicesModel->linkPhoneNumberToAccountUsingCode(sipIdentityAddress,
		                                                                Utils::appStringToCoreString(code));
}
