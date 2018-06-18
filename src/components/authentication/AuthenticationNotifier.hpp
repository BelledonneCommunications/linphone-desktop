/*
 * AuthenticationNotifier.hpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: April 13, 2017
 *      Author: Ronan Abhamon
 */

#ifndef AUTHENTICATION_NOTIFIER_H_
#define AUTHENTICATION_NOTIFIER_H_

#include <memory>

#include <QObject>

// =============================================================================

namespace linphone {
  class AuthInfo;
}

class AuthenticationNotifier : public QObject {
  Q_OBJECT;

public:
  AuthenticationNotifier (QObject *parent = Q_NULLPTR);

signals:
  void authenticationRequested (const QVariant &authInfo, const QString &realm, const QString &sipAddress, const QString &userId);

private:
  void handleAuthenticationRequested (const std::shared_ptr<linphone::AuthInfo> &authInfo);
};

Q_DECLARE_METATYPE(std::shared_ptr<linphone::AuthInfo>);

#endif // AUTHENTICATION_NOTIFIER_H_
