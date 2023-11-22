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

#ifndef ENUMSTOSTRING_H_
#define ENUMSTOSTRING_H_

#include <QObject>
#include <QString>

#include "LinphoneEnums.hpp"

// =============================================================================

/***
 * Class to make the link between qml and LinphoneEnums functions
 * TODO : transform LinphoneEnums into a class so we can delete this one
 */

class EnumsToString : public QObject {
	Q_OBJECT
public:
	EnumsToString(QObject *parent = nullptr) : QObject(parent) {
	}

	Q_INVOKABLE QString dirToString(const LinphoneEnums::CallDir &data) {
		return LinphoneEnums::toString(data);
	}
	Q_INVOKABLE QString statusToString(const LinphoneEnums::CallStatus &data) {
		return LinphoneEnums::toString(data);
	}
};

#endif // ENUMSTOSTRING_H_
