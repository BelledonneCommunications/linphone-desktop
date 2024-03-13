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

#ifndef PHONE_NUMBER_LIST_H_
#define PHONE_NUMBER_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "tool/AbstractObject.hpp"
#include <QLocale>
// =============================================================================

class PhoneNumberList : public ListProxy, public AbstractObject {
	Q_OBJECT
public:
	PhoneNumberList(QObject *parent = Q_NULLPTR);
	~PhoneNumberList();

	DECLARE_ABSTRACT_OBJECT
};

#endif