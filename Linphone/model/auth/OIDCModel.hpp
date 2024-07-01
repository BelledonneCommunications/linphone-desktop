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

#ifndef OIDC_MODEL_H_
#define OIDC_MODEL_H_

#include "tool/AbstractObject.hpp"
#include <QOAuth2AuthorizationCodeFlow>
#include <linphone++/linphone.hh>

// =============================================================================

class OIDCModel : public QObject, public AbstractObject {
	Q_OBJECT

public:
	OIDCModel(const std::shared_ptr<linphone::AuthInfo> &authInfo, QObject *parent = Q_NULLPTR);

	void openIdConfigReceived();
	void setBearers();

signals:
	void authenticated();
	void requestFailed(const QString &error);
	void statusChanged(const QString &status);
	void finished();

private:
	QOAuth2AuthorizationCodeFlow mOidc;
	std::shared_ptr<linphone::AuthInfo> mAuthInfo;

	DECLARE_ABSTRACT_OBJECT
};

#endif
