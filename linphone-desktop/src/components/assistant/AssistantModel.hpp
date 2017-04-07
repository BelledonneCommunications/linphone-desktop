/*
 * AssistantModel.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
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
 *  Created on: April 6, 2017
 *      Author: Ronan Abhamon
 */

#ifndef ASSISTANT_MODEL_H_
#define ASSISTANT_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class AssistantModel : public QObject {
  class Handlers;

  Q_OBJECT;

public:
  AssistantModel (QObject *parent = Q_NULLPTR);

  Q_INVOKABLE void setUsername (const QString &username);
  Q_INVOKABLE void setPassword (const QString &password);

  Q_INVOKABLE void login ();

signals:
  void usernameChanged (const QString &username, const QString &error);
  void passwordChanged (const QString &password, const QString &error);

  void loginStatusChanged (const QString &error);

private:
  std::shared_ptr<linphone::AccountCreator> m_account_creator;
  std::shared_ptr<Handlers> m_handlers;
};

#endif // ASSISTANT_MODEL_H_
