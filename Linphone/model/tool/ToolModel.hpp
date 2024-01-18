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

#ifndef TOOL_MODEL_H_
#define TOOL_MODEL_H_

#include "core/call/CallCore.hpp"
#include "tool/AbstractObject.hpp"

#include <QHash>
#include <QObject>
#include <linphone++/linphone.hh>

class ToolModel : public QObject, public AbstractObject {
	Q_OBJECT
public:
	ToolModel(QObject *parent = nullptr);
	~ToolModel();

	static std::shared_ptr<linphone::Address> interpretUrl(const QString &address);
	static std::shared_ptr<linphone::FriendPhoneNumber> makeLinphoneNumber(const QString &label, const QString &number);

	static QString getDisplayName(const std::shared_ptr<const linphone::Address> &address);
	static QString getDisplayName(QString address);

	static QSharedPointer<CallCore> createCall(const QString &sipAddress,
	                                           const QString &prepareTransfertAddress = "",
	                                           const QHash<QString, QString> &headers = {},
	                                           linphone::MediaEncryption = linphone::MediaEncryption::None);

private:
	DECLARE_ABSTRACT_OBJECT
};

#endif
