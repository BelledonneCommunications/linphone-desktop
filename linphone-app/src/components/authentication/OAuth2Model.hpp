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

#ifndef O_AUTH_2_MODEL_H_
#define O_AUTH_2_MODEL_H_

#include <memory>

#include <QObject>
#include <QOAuth2AuthorizationCodeFlow>
// =============================================================================


class OAuth2Model : public QObject {
	Q_OBJECT

public:
	OAuth2Model (QObject *parent = Q_NULLPTR);
	
	void grant();	//Start authentication
	void getRemoteProvisioning();
	
	static bool isAvailable();
	
signals:
	void authenticated();
	void requestFailed(const QString& error);
	void statusChanged(const QString& status);
	void remoteProvisioningReceived(const QString& url);

private:
	QOAuth2AuthorizationCodeFlow oauth2;
};

#endif
