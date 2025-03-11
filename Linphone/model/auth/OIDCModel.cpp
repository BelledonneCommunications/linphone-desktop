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

	QString scope = OIDCScope;
	;
	if (autorizationUrl.hasQuery()) {
		QUrlQuery query(autorizationUrl);
		if (query.hasQueryItem("scope")) {
			scope = query.queryItemValue("scope");
		}
	}
	mOidc.setScope(scope);
	mTimeout.setInterval(1000 * 60 * 2); // 2minutes

	connect(&mTimeout, &QTimer::timeout, [this]() {
		qWarning() << log().arg("Timeout reached for OpenID connection.");
		dynamic_cast<OAuthHttpServerReplyHandler *>(mOidc.replyHandler())->close();
		CoreModel::getInstance()->getCore()->abortAuthentication(mAuthInfo);
		emit statusChanged(tr("Timeout: Not authenticated"));
		emit finished();
	});
	connect(mOidc.networkAccessManager(), &QNetworkAccessManager::authenticationRequired,
	        [=](QNetworkReply *reply, QAuthenticator *authenticator) {
		        lWarning() << log().arg("authenticationRequired received but not implemented");
	        });

	connect(&mOidc, &QOAuth2AuthorizationCodeFlow::statusChanged, [=](QAbstractOAuth::Status status) {
		switch (status) {
			case QAbstractOAuth::Status::Granted: {
				mTimeout.stop();
				emit statusChanged(tr("Authentication granted"));
				emit authenticated();
				break;
			}
			case QAbstractOAuth::Status::NotAuthenticated: {
				mTimeout.stop();
				emit statusChanged(tr("Not authenticated"));
				emit finished();
				break;
			}
			case QAbstractOAuth::Status::RefreshingToken: {
				emit statusChanged(tr("Refreshing token"));
				break;
			}
			case QAbstractOAuth::Status::TemporaryCredentialsReceived: {
				emit statusChanged(tr("Temporary credentials received"));
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
				emit requestFailed(tr("Network error"));
				break;
			case QAbstractOAuth::Error::ServerError:
				emit requestFailed(tr("Server error"));
				break;
			case QAbstractOAuth::Error::OAuthTokenNotFoundError:
				emit requestFailed(tr("OAuth token not found"));
				break;
			case QAbstractOAuth::Error::OAuthTokenSecretNotFoundError:
				emit requestFailed(tr("OAuth token secret not found"));
				break;
			case QAbstractOAuth::Error::OAuthCallbackNotVerified:
				emit requestFailed(tr("OAuth callback not verified"));
				break;
			default: {
			}
		}
		emit finished();
	});

	connect(&mOidc, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, [this](const QUrl &url) {
		qDebug() << "Browser authentication url : " << url;
		emit statusChanged(tr("Requesting authorization from browser"));
		mTimeout.start();
		QDesktopServices::openUrl(url);
	});

	connect(&mOidc, &QOAuth2AuthorizationCodeFlow::finished, [this](QNetworkReply *reply) {
		connect(reply, &QNetworkReply::errorOccurred,
		        [this, reply](QNetworkReply::NetworkError error) { qDebug() << reply->errorString(); });
	});

	connect(this, &OIDCModel::authenticated, this, &OIDCModel::setBearers);

	// in case we want to add parameters. Needed to override redirect_url
	mOidc.setModifyParametersFunction([&, username = Utils::coreStringToAppString(authInfo->getUsername())](
	                                      QAbstractOAuth::Stage stage, QMultiMap<QString, QVariant> *parameters) {
		parameters->insert("login_hint", username);
		parameters->replace("application_type", "native");
		if (stage == QAbstractOAuth::Stage::RequestingAuthorization) {
			QUrl redirectUri = parameters->value("redirect_uri").toUrl();
			redirectUri.setHost("localhost");
			parameters->replace("redirect_uri", redirectUri);
		}
		switch (stage) {
			case QAbstractOAuth::Stage::RequestingAccessToken: {
				emit statusChanged(tr("Requesting access token"));
				break;
			}
			case QAbstractOAuth::Stage::RefreshingAccessToken: {
				emit statusChanged(tr("Refreshing access token"));
				break;
			}
			case QAbstractOAuth::Stage::RequestingAuthorization: {
				emit statusChanged(tr("Requesting authorization"));
				break;
			}
			case QAbstractOAuth::Stage::RequestingTemporaryCredentials: {
				emit statusChanged(tr("Requesting temporary credentials"));
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
		emit requestFailed(tr("No authorization endpoint found in OpenID configuration"));
		emit finished();
		return;
	}
	if (rootArray.contains("token_endpoint")) {
		mOidc.setAccessTokenUrl(QUrl(rootArray["token_endpoint"].toString()));
		mAuthInfo->setTokenEndpointUri(
		    Utils::appStringToCoreString(QUrl(rootArray["token_endpoint"].toString()).toString()));
	} else {
		qWarning() << "No token endpoint found in OpenID configuration";
		emit requestFailed(tr("No token endpoint found in OpenID configuration"));
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
	auto refreshBearer =
	    linphone::Factory::get()->createBearerToken(Utils::appStringToCoreString(mOidc.refreshToken()), timeT);

	auto accessBearer = linphone::Factory::get()->createBearerToken(Utils::appStringToCoreString(mOidc.token()), timeT);
	mAuthInfo->setRefreshToken(refreshBearer);
	mAuthInfo->setAccessToken(accessBearer);
	CoreModel::getInstance()->getCore()->addAuthInfo(mAuthInfo);
	emit CoreModel::getInstance()->bearerAccountAdded();
	emit finished();
}
