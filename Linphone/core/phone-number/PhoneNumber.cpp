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

#include "PhoneNumber.hpp"
#include "tool/Utils.hpp"
#include <QApplication>

PhoneNumber::PhoneNumber(const std::shared_ptr<linphone::DialPlan> &dialPlan) : QObject(nullptr) {
	// Should be call from model Thread
	mFlag = Utils::coreStringToAppString(dialPlan->getFlag());
	mNationalNumberLength = dialPlan->getNationalNumberLength();
	mCountryCallingCode = Utils::coreStringToAppString(dialPlan->getCountryCallingCode());
	mIsoCountryCode = Utils::coreStringToAppString(dialPlan->getIsoCountryCode());
	mInternationalCallPrefix = Utils::coreStringToAppString(dialPlan->getInternationalCallPrefix());
	mCountry = Utils::coreStringToAppString(dialPlan->getCountry());
}
