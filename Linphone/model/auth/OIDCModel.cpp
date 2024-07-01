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
static constexpr char OIDCClientId[] = "linphone";
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
	auto replyHandler = new OAuthHttpServerReplyHandler(0, this);
	mAuthInfo = authInfo;
	mOidc.setReplyHandler(replyHandler);
	mOidc.setAuthorizationUrl(QUrl(Utils::coreStringToAppString(authInfo->getAuthorizationServer())));
	mOidc.setNetworkAccessManager(new QNetworkAccessManager(&mOidc));
	mOidc.setClientIdentifier(OIDCClientId);
	mAuthInfo->setClientId(OIDCClientId);
	mOidc.setScope(OIDCScope);

	connect(mOidc.networkAccessManager(), &QNetworkAccessManager::authenticationRequired,
	        [=](QNetworkReply *reply, QAuthenticator *authenticator) {
		        lWarning() << log().arg("authenticationRequired received but not implemented");
	        });

	connect(&mOidc, &QOAuth2AuthorizationCodeFlow::statusChanged, [=](QAbstractOAuth::Status status) {
		switch (status) {
			case QAbstractOAuth::Status::Granted: {
				emit statusChanged("Authentication granted");
				emit authenticated();
				break;
			}
			case QAbstractOAuth::Status::NotAuthenticated: {
				emit statusChanged("Not authenticated");
				emit finished();
				break;
			}
			case QAbstractOAuth::Status::RefreshingToken: {
				emit statusChanged("Refreshing token");
				break;
			}
			case QAbstractOAuth::Status::TemporaryCredentialsReceived: {
				emit statusChanged("Temporary credentials received");
				break;
			}
			default: {
			}
		}
	});

	connect(&mOidc, &QOAuth2AuthorizationCodeFlow::requestFailed, [=](QAbstractOAuth::Error error) {
		qWarning() << "RequestFailed:" << (int)error;
		switch (error) {
			case QAbstractOAuth::Error::NetworkError:
				emit requestFailed("Network error");
				break;
			case QAbstractOAuth::Error::ServerError:
				emit requestFailed("Server error");
				break;
			case QAbstractOAuth::Error::OAuthTokenNotFoundError:
				emit requestFailed("OAuth token not found");
				break;
			case QAbstractOAuth::Error::OAuthTokenSecretNotFoundError:
				emit requestFailed("OAuth token secret not found");
				break;
			case QAbstractOAuth::Error::OAuthCallbackNotVerified:
				emit requestFailed("OAuth callback not verified");
				break;
			default: {
			}
		}
		emit finished();
	});

	connect(&mOidc, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, [this](const QUrl &url) {
		qDebug() << "Browser authentication url : " << url;
		emit statusChanged("Requesting authorization from browser");
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
		switch (stage) {
			case QAbstractOAuth::Stage::RequestingAccessToken: {
				emit statusChanged("Requesting access token");
				break;
			}
			case QAbstractOAuth::Stage::RefreshingAccessToken: {
				emit statusChanged("Refreshing access token");
				break;
			}
			case QAbstractOAuth::Stage::RequestingAuthorization: {
				emit statusChanged("Requesting authorization");
				break;
			}
			case QAbstractOAuth::Stage::RequestingTemporaryCredentials: {
				emit statusChanged("Requesting temporary credentials");
				break;
			}
			default: {
			}
		}
	});

	connect(this, &OIDCModel::finished, this, &OIDCModel::deleteLater);

	QNetworkRequest request(QUrl(Utils::coreStringToAppString(authInfo->getAuthorizationServer()) + OIDCWellKnown));
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
	}
	if (rootArray.contains("token_endpoint")) {
		mOidc.setAccessTokenUrl(QUrl(rootArray["token_endpoint"].toString()));
		mAuthInfo->setTokenEndpointUri(
		    Utils::appStringToCoreString(QUrl(rootArray["token_endpoint"].toString()).toString()));
	}
	mOidc.grant();
	reply->deleteLater();
}

void OIDCModel::setBearers() {
	auto expiration = QDateTime::currentDateTime().secsTo(mOidc.expirationAt());
	qDebug() << "Authenticated for " << expiration << "s";
	auto refreshBearer =
	    linphone::Factory::get()->createBearerToken(Utils::appStringToCoreString(mOidc.refreshToken()), expiration);

	auto accessBearer =
	    linphone::Factory::get()->createBearerToken(Utils::appStringToCoreString(mOidc.token()), expiration);
	mAuthInfo->setRefreshToken(refreshBearer);
	mAuthInfo->setAccessToken(accessBearer);
	CoreModel::getInstance()->getCore()->addAuthInfo(mAuthInfo);
	emit finished();
}
