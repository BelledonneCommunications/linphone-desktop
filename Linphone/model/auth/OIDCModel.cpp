/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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

#include "OIDCModel.hpp"

#include <QDesktopServices>
#include <QtNetworkAuth>

#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"

// =============================================================================

static constexpr char OIDCScope[] = "offline_access";
static constexpr char OIDCWellKnown[] = "/.well-known/openid-configuration";

DEFINE_ABSTRACT_OBJECT(OIDCModel)

class OAuthHttpServerReplyHandler : public QOAuthHttpServerReplyHandler {
public:
	OAuthHttpServerReplyHandler(const int &port, QObject *parent = nullptr)
	    : QOAuthHttpServerReplyHandler(port, parent) {
	}
	QString callback() const override;
};

QString OAuthHttpServerReplyHandler::callback() const {
	QString uri;
	if (uri != "") return QUrl::toPercentEncoding(uri);
	else return QOAuthHttpServerReplyHandler::callback(); // Return default
}

OIDCModel::OIDCModel(const std::shared_ptr<linphone::AuthInfo> &authInfo, QObject *parent) {
	auto port = CoreModel::getInstance()->getCore()->getConfig()->getInt("app", "oidc_redirect_uri_port", 0);
	qDebug() << "OIDC Redirect URI Port set to [" << port << "]";
	auto replyHandler = new OAuthHttpServerReplyHandler(port, this);
	if (!replyHandler->isListening()) {
		qWarning() << "OAuthHttpServerReplyHandler is not listening on port" << port;
		emit requestFailed(tr("OAuthHttpServerReplyHandler is not listening"));
		emit finished();
		return;
	}
	mAuthInfo = authInfo;
	mOidc.setReplyHandler(replyHandler);
	auto autorizationUrl = QUrl(Utils::coreStringToAppString(authInfo->getAuthorizationServer()));
	mOidc.setAuthorizationUrl(autorizationUrl);
	mOidc.setNetworkAccessManager(new QNetworkAccessManager(&mOidc));
	QString clientid = QString::fromStdString(CoreModel::getInstance()->getCore()->getConfig()->getString(
	    "app", "oidc_client_id", QCoreApplication::applicationName().toStdString()));
	if (autorizationUrl.hasQuery()) {
		QUrlQuery query(autorizationUrl);
		if (query.hasQueryItem("client_id")) {
			clientid = query.queryItemValue("client_id");
		}
	}
	mOidc.setClientIdentifier(clientid);
	mAuthInfo->setClientId(clientid.toStdString());
	qDebug() << "OIDC Client ID set to [" << clientid << "]";

	// find an auth info from LinphoneCore where username = clientid
	auto clientSecret = CoreModel::getInstance()->getCore()->findAuthInfo("", clientid.toStdString(), "");
	if (clientSecret != nullptr) {
		qDebug() << "client secret found for client id [" << clientid << "]";
		mOidc.setClientIdentifierSharedKey(clientSecret->getPassword().c_str());
	}

	QSet<QByteArray> scopeTokens = {OIDCScope};
	if (autorizationUrl.hasQuery()) {
		QUrlQuery query(autorizationUrl);
		if (query.hasQueryItem("scope")) {
			auto scopeList = query.queryItemValue("scope").split(' ');
			for (const auto &scopeItem : scopeList) {
				scopeTokens.insert(scopeItem.toUtf8());
			}
		}
	}
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
	mOidc.setRequestedScopeTokens(scopeTokens);
#else
	mOidc.setScope(QStringList(scopeTokens.begin(), scopeTokens.end()).join(' '));
#endif
	mTimeout.setInterval(1000 * 60 * 2); // 2minutes

	connect(&mTimeout, &QTimer::timeout, [this]() {
		qWarning() << log().arg("Timeout reached for OpenID connection.");
		dynamic_cast<OAuthHttpServerReplyHandler *>(mOidc.replyHandler())->close();
		CoreModel::getInstance()->getCore()->abortAuthentication(mAuthInfo);
		//: Timeout: Not authenticated
		emit statusChanged(tr("oidc_authentication_timeout_message"));
		emit finished();
	});
	connect(mOidc.networkAccessManager(), &QNetworkAccessManager::authenticationRequired,
	        [=](QNetworkReply *reply, QAuthenticator *authenticator) {
		        lDebug() << "authenticationRequired  url [" << reply->url() << "]";
		        if (mOidc.clientIdentifierSharedKey().isEmpty() == false) {
			        authenticator->setUser(mOidc.clientIdentifier());
			        authenticator->setPassword(mOidc.clientIdentifierSharedKey());
		        } else lWarning() << "client secret not found for client id [" << mOidc.clientIdentifier() << "]";
	        });

	connect(&mOidc, &QOAuth2AuthorizationCodeFlow::statusChanged, [=](QAbstractOAuth::Status status) {
		switch (status) {
			case QAbstractOAuth::Status::Granted: {
				mTimeout.stop();
				//: Authentication granted
				emit statusChanged(tr("oidc_authentication_granted_message"));
				emit authenticated();
				break;
			}
			case QAbstractOAuth::Status::NotAuthenticated: {
				mTimeout.stop();
				//: Not authenticated
				emit statusChanged(tr("oidc_authentication_not_authenticated_message"));
				emit finished();
				break;
			}
			case QAbstractOAuth::Status::RefreshingToken: {
				//: Refreshing token
				emit statusChanged(tr("oidc_authentication_refresh_message"));
				break;
			}
			case QAbstractOAuth::Status::TemporaryCredentialsReceived: {
				//: Temporary credentials received
				emit statusChanged(tr("oidc_authentication_temporary_credentials_message"));
				break;
			}
			default: {
			}
		}
	});

	connect(&mOidc, &QOAuth2AuthorizationCodeFlow::requestFailed, [=](QAbstractOAuth::Error error) {
		mTimeout.stop();

		const QMetaObject metaObject = QAbstractOAuth::staticMetaObject;
		int index = metaObject.indexOfEnumerator("Error");
		QMetaEnum metaEnum = metaObject.enumerator(index);
		qWarning() << "RequestFailed:" << metaEnum.valueToKey(static_cast<int>(error));
		switch (error) {
			case QAbstractOAuth::Error::NetworkError:
				//: Network error
				emit requestFailed(tr("oidc_authentication_network_error"));
				break;
			case QAbstractOAuth::Error::ServerError:
				//: Server error
				emit requestFailed(tr("oidc_authentication_server_error"));
				break;
			case QAbstractOAuth::Error::OAuthTokenNotFoundError:
				//: OAuth token not found
				emit requestFailed(tr("oidc_authentication_token_not_found_error"));
				break;
			case QAbstractOAuth::Error::OAuthTokenSecretNotFoundError:
				//: OAuth token secret not found
				emit requestFailed(tr("oidc_authentication_token_secret_not_found_error"));
				break;
			case QAbstractOAuth::Error::OAuthCallbackNotVerified:
				//: OAuth callback not verified
				emit requestFailed(tr("oidc_authentication_callback_not_verified_error"));
				break;
			default: {
			}
		}
		emit finished();
	});

	connect(&mOidc, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, [this](const QUrl &url) {
		qDebug() << "Browser authentication url : " << url;
		//: Requesting authorization from browser
		emit statusChanged(tr("oidc_authentication_request_auth_message"));
		mTimeout.start();
		QDesktopServices::openUrl(url);
	});

	connect(&mOidc, &QOAuth2AuthorizationCodeFlow::finished, [this](QNetworkReply *reply) {
		connect(reply, &QNetworkReply::errorOccurred,
		        [this, reply](QNetworkReply::NetworkError error) { qDebug() << reply->errorString(); });
	});

	connect(this, &OIDCModel::authenticated, this, &OIDCModel::setBearers);

#if QT_VERSION < QT_VERSION_CHECK(6, 9, 0)
	// Connect the signal to the tokensReceived handler to get id_token
	connect(mOidc.replyHandler(), &QOAuthHttpServerReplyHandler::tokensReceived, this,
	        [this](const QVariantMap &tokens) {
		        //		for (auto it = tokens.cbegin(); it != tokens.cend(); ++it) {
		        //			qDebug() << "Token key:" << it.key() << ", value:" << it.value().toString();
		        //		}
		        if (tokens.contains("id_token")) {
			        auto idToken = tokens["id_token"].toString();
			        qDebug() << "ID Token received:" << idToken.left(3) + "..." + idToken.right(3);
			        mIdToken = idToken;
		        } else if (tokens.contains("access_token")) {
			        auto accessToken = tokens["access_token"].toString();
			        qDebug() << "Access Token received:" << accessToken.left(3) + "..." + accessToken.right(3);
			        mIdToken = accessToken;

		        } else {
			        mIdToken.clear();
			        qWarning() << "No ID Token or Access Token found in the tokens.";
			        emit requestFailed(tr("oidc_authentication_no_token_found_error"));
			        emit finished();
		        }
	        });
#endif
	// in case we want to add parameters. Needed to override redirect_url
	mOidc.setModifyParametersFunction([&, username = Utils::coreStringToAppString(authInfo->getUsername())](
	                                      QAbstractOAuth::Stage stage, QMultiMap<QString, QVariant> *parameters) {
		parameters->insert("login_hint", username);
		parameters->replace("application_type", "native");
		switch (stage) {
			case QAbstractOAuth::Stage::RequestingAccessToken: {
				//: Requesting access token
				emit statusChanged(tr("oidc_authentication_request_token_message"));
				break;
			}
			case QAbstractOAuth::Stage::RefreshingAccessToken: {
				//: Refreshing access token
				emit statusChanged(tr("oidc_authentication_refresh_token_message"));
				break;
			}
			case QAbstractOAuth::Stage::RequestingAuthorization: {
				//: Requesting authorization
				emit statusChanged(tr("oidc_authentication_request_authorization_message"));
				break;
			}
			case QAbstractOAuth::Stage::RequestingTemporaryCredentials: {
				//: Requesting temporary credentials
				emit statusChanged(tr("oidc_authentication_request_temporary_credentials_message"));
				break;
			}
			default: {
			}
		}
	});

	connect(this, &OIDCModel::finished, this, &OIDCModel::deleteLater);

	auto url = QUrl(Utils::coreStringToAppString(authInfo->getAuthorizationServer()));
	url.setPath(url.path() + OIDCWellKnown);
	QNetworkRequest request(url);
	auto reply = mOidc.networkAccessManager()->get(request);
	connect(reply, &QNetworkReply::finished, this, &OIDCModel::openIdConfigReceived);
}

void OIDCModel::openIdConfigReceived() {
	auto reply = dynamic_cast<QNetworkReply *>(sender());
	auto document = QJsonDocument::fromJson(reply->readAll());
	if (document.isNull()) return;
	auto rootArray = document.toVariant().toMap();
	if (rootArray.contains("authorization_endpoint")) {
		mOidc.setAuthorizationUrl(QUrl(rootArray["authorization_endpoint"].toString()));
	} else {
		qWarning() << "No authorization endpoint found in OpenID configuration";
		//: No authorization endpoint found in OpenID configuration
		emit requestFailed(tr("oidc_authentication_no_auth_found_in_config_error"));
		emit finished();
		return;
	}
	if (rootArray.contains("token_endpoint")) {
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
		mOidc.setTokenUrl(QUrl(rootArray["token_endpoint"].toString()));
#else
		mOidc.setAccessTokenUrl(QUrl(rootArray["token_endpoint"].toString()));
#endif
		mAuthInfo->setTokenEndpointUri(
		    Utils::appStringToCoreString(QUrl(rootArray["token_endpoint"].toString()).toString()));
	} else {
		qWarning() << "No token endpoint found in OpenID configuration";
		//: No token endpoint found in OpenID configuration
		emit requestFailed(tr("oidc_authentication_no_token_found_in_config_error"));
		emit finished();
		return;
	}
	mOidc.grant();
	reply->deleteLater();
}

void OIDCModel::setBearers() {
	auto expiration = QDateTime::currentDateTime().secsTo(mOidc.expirationAt());
	auto timeT = mOidc.expirationAt().toSecsSinceEpoch();
	qDebug() << "Authenticated for " << expiration << "s";

	auto accessBearer = linphone::Factory::get()->createBearerToken(Utils::appStringToCoreString(idToken()), timeT);
	mAuthInfo->setAccessToken(accessBearer);

	if (mOidc.refreshToken() != nullptr) {

		auto refreshBearer =
		    linphone::Factory::get()->createBearerToken(Utils::appStringToCoreString(mOidc.refreshToken()), timeT);
		mAuthInfo->setRefreshToken(refreshBearer);

	} else {
		qWarning() << "No refresh token found";
	}
	CoreModel::getInstance()->getCore()->addAuthInfo(mAuthInfo);
	emit CoreModel::getInstance() -> bearerAccountAdded();
	emit finished();
}
QString OIDCModel::idToken() const {
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
	return mOidc.idToken().isEmpty() ? mOidc.token() : mOidc.idToken();
#else
	return mIdToken;
#endif
}