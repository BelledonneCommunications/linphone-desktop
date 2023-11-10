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

#ifndef UTILS_H_
#define UTILS_H_

#include <QObject>
#include <QString>

#include "Constants.hpp"

// =============================================================================

/*
 * Define telling g++ that a 'break' statement has been deliberately omitted
 * in switch block.
 */
#ifndef UTILS_NO_BREAK
#if defined(__GNUC__) && __GNUC__ >= 7
#define UTILS_NO_BREAK __attribute__((fallthrough))
#else
#define UTILS_NO_BREAK
#endif // if defined(__GNUC__) && __GNUC__ >= 7
#endif // ifndef UTILS_NO_BREAK

class VariantObject;

class Utils : public QObject {
	Q_OBJECT
public:
	Utils(QObject *parent = nullptr) : QObject(parent) {
	}

	Q_INVOKABLE static VariantObject *getDisplayName(const QString &address);
	Q_INVOKABLE static VariantObject *startAudioCall(const QString &sipAddress,
	                                                 const QString &prepareTransfertAddress = "",
	                                                 const QHash<QString, QString> &headers = {});

	static inline QString coreStringToAppString(const std::string &str) {
		if (Constants::LinphoneLocaleEncoding == QString("UTF-8")) return QString::fromStdString(str);
		else
			return QString::fromLocal8Bit(str.c_str(),
			                              int(str.size())); // When using Locale. Be careful about conversion bijection
			                                                // with UTF-8, you may loss characters
	}

	static inline std::string appStringToCoreString(const QString &str) {
		if (Constants::LinphoneLocaleEncoding == QString("UTF-8")) return str.toStdString();
		else return qPrintable(str);
	}
	// Reverse function of strstr.
	static char *rstrstr(const char *a, const char *b);

	template <typename T, typename... Args>
	static std::shared_ptr<T> makeQObject_ptr(Args &&...args) {
		return std::shared_ptr<T>(new T(args...), [](T *obj) { obj->deleteLater(); });
	}
};

#endif // UTILS_H_
