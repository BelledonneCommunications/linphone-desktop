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

#include "OAuth2Model.hpp"

#include <QtNetworkAuth>
#include <QDesktopServices>

#include "components/core/CoreManager.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/Utils.hpp"

// =============================================================================
// Goal : override the default redirect url which is "http://localhost:0"
class OAuthHttpServerReplyHandler : public QOAuthHttpServerReplyHandler{
public:
	OAuthHttpServerReplyHandler(const int& port, QObject * parent = nullptr ) : QOAuthHttpServerReplyHandler(port, parent){
	}
	QString callback() const override{
		QString uri = CoreManager::getInstance()->getSettingsModel()->getOAuth2RedirectUri();
		if( uri!= "")
			return uri;
		else
			return QOAuthHttpServerReplyHandler::callback();// Return default
	}
};

OAuth2Model::OAuth2Model (QObject *parent){
	QUrl url(CoreManager::getInstance()->getSettingsModel()->getOAuth2RedirectUri());
	auto replyHandler = new OAuthHttpServerReplyHandler(url.port(0), this);
	oauth2.setReplyHandler(replyHandler);
	oauth2.setAuthorizationUrl(QUrl(CoreManager::getInstance()->getSettingsModel()->getOAuth2AuthorizationUrl()));
	oauth2.setAccessTokenUrl(QUrl(CoreManager::getInstance()->getSettingsModel()->getOAuth2AccessTokenUrl()));
	oauth2.setNetworkAccessManager(new QNetworkAccessManager(&oauth2));
	oauth2.setClientIdentifier(CoreManager::getInstance()->getSettingsModel()->getOAuth2Identifier());
	oauth2.setClientIdentifierSharedKey(CoreManager::getInstance()->getSettingsModel()->getOAuth2Password());
	oauth2.setScope(CoreManager::getInstance()->getSettingsModel()->getOAuth2Scope());
	
	connect(oauth2.networkAccessManager(), &QNetworkAccessManager::authenticationRequired, [=](QNetworkReply *reply, QAuthenticator *authenticator){
		qWarning() << "authenticationRequired received but not implemented";
	});
	connect(&oauth2, &QOAuth2AuthorizationCodeFlow::statusChanged, [=](QAbstractOAuth::Status status) {
		qWarning() << (int)status;
		switch(status){
			case QAbstractOAuth::Status::Granted : {
				emit statusChanged("Authentication granted");
				emit authenticated();
				break;
			}
			case QAbstractOAuth::Status::NotAuthenticated : {
				emit statusChanged("Not authenticated");
				break;
			}
			case QAbstractOAuth::Status::RefreshingToken : {
				emit statusChanged("Refreshing token");
				break;
			}
			case QAbstractOAuth::Status::TemporaryCredentialsReceived : {
				emit statusChanged("Temporary credentials received");
				break;
			}
			default:{}
		}
	});
	connect(&oauth2, &QOAuth2AuthorizationCodeFlow::requestFailed, [=](QAbstractOAuth::Error error){
		qWarning() << (int)error;
		switch(error){
			case QAbstractOAuth::Error::NetworkError : emit requestFailed("Network error"); break;
			case QAbstractOAuth::Error::ServerError : emit requestFailed("Server error"); break;
			case QAbstractOAuth::Error::OAuthTokenNotFoundError : emit requestFailed("OAuth token not found"); break;
			case QAbstractOAuth::Error::OAuthTokenSecretNotFoundError : emit requestFailed("OAuth token secret not found"); break;
			case QAbstractOAuth::Error::OAuthCallbackNotVerified: emit requestFailed("OAuth callback not verified"); break;
			default:{
			}
		}
	});
	
	// in case we want to add parameters.
	oauth2.setModifyParametersFunction([&](QAbstractOAuth::Stage stage, QVariantMap *parameters) {
		qWarning() << (int)stage;
		switch(stage){
			case QAbstractOAuth::Stage::RequestingAccessToken : {
				emit statusChanged("Requesting access token");
				break;
			}
			case QAbstractOAuth::Stage::RefreshingAccessToken : {
				emit statusChanged("Refreshing access token");
				break;
			}
			case QAbstractOAuth::Stage::RequestingAuthorization : {
				emit statusChanged("Requesting authorization");
				break;
			}
			case QAbstractOAuth::Stage::RequestingTemporaryCredentials : {
				emit statusChanged("Requesting temporary credentials");
				break;
			}
			default:{}
		}
	});
	
	//
	connect(&oauth2, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, [this](const QUrl & url){
		qDebug() << "Browser authentication url : " << url;
		emit statusChanged("Requesting authorization from browser");
		QDesktopServices::openUrl(url);
	});
	connect(&oauth2, &QOAuth2AuthorizationCodeFlow::finished, [this](QNetworkReply * reply){
		qDebug() << "Finished " << reply->errorString();
		connect(reply, &QNetworkReply::errorOccurred, [this, reply](QNetworkReply::NetworkError error){
			qDebug() << reply->errorString();
			
		});
	});
	connect(this, &OAuth2Model::authenticated, this, &OAuth2Model::getRemoteProvisioning);
}

bool OAuth2Model::isAvailable(){
	return !CoreManager::getInstance()->getSettingsModel()->getOAuth2AuthorizationUrl().isEmpty()
		&& !CoreManager::getInstance()->getSettingsModel()->getOAuth2AccessTokenUrl().isEmpty();
}

void OAuth2Model::grant(){
	oauth2.grant();
}

void OAuth2Model::getRemoteProvisioning() {
	qDebug() << "getRemoteProvisioning " << oauth2.extraTokens() << oauth2.token();
	QString basicAuthentication(CoreManager::getInstance()->getSettingsModel()->getOAuth2RemoteProvisioningBasicAuth());
	QUrl url(CoreManager::getInstance()->getSettingsModel()->getRemoteProvisioningRootUrl());
	std::vector<std::pair<std::string, std::string> > headers;
	auto header = CoreManager::getInstance()->getSettingsModel()->getOAuth2RemoteProvisioningHeader();
	if( !header.isEmpty())
		headers.push_back(std::pair<std::string, std::string>(Utils::appStringToCoreString(header), Utils::appStringToCoreString(oauth2.token())));
	headers.push_back(std::pair<std::string, std::string>("accept", "application/xml"));
	if(!basicAuthentication.isEmpty()){
		headers.push_back(std::pair<std::string, std::string>("authorization", Utils::appStringToCoreString("Basic "+basicAuthentication)));
	}
	CoreManager::getInstance()->getCore()->clearProvisioningHeaders();
	for(int i = 0 ; i < headers.size() ; ++i)
		CoreManager::getInstance()->getCore()->addProvisioningHeader(headers[i].first, headers[i].second);
	CoreManager::getInstance()->getSettingsModel()->setRemoteProvisioning(url.toString());
}
