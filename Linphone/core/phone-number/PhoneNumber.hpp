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

#ifndef PHONE_NUMBER_H_
#define PHONE_NUMBER_H_

#include "tool/AbstractObject.hpp"
#include <QObject>
#include <linphone++/linphone.hh>

class PhoneNumber : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString flag MEMBER mFlag CONSTANT)
	Q_PROPERTY(int nationalNumberLength MEMBER mNationalNumberLength CONSTANT)
	Q_PROPERTY(QString countryCallingCode MEMBER mCountryCallingCode CONSTANT)
	Q_PROPERTY(QString isoCountryCode MEMBER mIsoCountryCode CONSTANT)
	Q_PROPERTY(QString internationalCallPrefix MEMBER mInternationalCallPrefix CONSTANT)
	Q_PROPERTY(QString country MEMBER mCountry CONSTANT)

public:
	static QSharedPointer<PhoneNumber> create(const std::shared_ptr<linphone::DialPlan> &dialPlan);
	PhoneNumber(const std::shared_ptr<linphone::DialPlan> &dialPlan);
	~PhoneNumber();

	QString mFlag;
	int mNationalNumberLength;
	QString mCountryCallingCode;
	QString mIsoCountryCode;
	QString mInternationalCallPrefix;
	QString mCountry;

private:
	DECLARE_ABSTRACT_OBJECT
};

#endif
