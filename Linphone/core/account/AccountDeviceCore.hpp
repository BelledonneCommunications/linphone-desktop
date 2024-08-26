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

#ifndef ACCOUNT_DEVICE_CORE_H_
#define ACCOUNT_DEVICE_CORE_H_

#include "model/account/AccountDeviceModel.hpp"
#include "tool/AbstractObject.hpp"
#include <QDateTime>
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class AccountDeviceCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString deviceName MEMBER mDeviceName CONSTANT)
	Q_PROPERTY(QString userAgent MEMBER mUserAgent CONSTANT)
	Q_PROPERTY(QDateTime lastUpdateTimestamp MEMBER mLastUpdateTimestamp CONSTANT)

public:
	static QSharedPointer<AccountDeviceCore> create(const std::shared_ptr<linphone::AccountDevice> &device);
	AccountDeviceCore(const std::shared_ptr<linphone::AccountDevice> &device);
	AccountDeviceCore(QString name, QString userAgent, QDateTime last);
	static QSharedPointer<AccountDeviceCore> createDummy(QString name, QString userAgent, QDateTime last);

	~AccountDeviceCore();

	const std::shared_ptr<AccountDeviceModel> &getModel() const;

private:
	QString mDeviceName;
	QString mUserAgent;
	QDateTime mLastUpdateTimestamp;
	std::shared_ptr<AccountDeviceModel> mAccountDeviceModel;

	DECLARE_ABSTRACT_OBJECT
};

#endif
