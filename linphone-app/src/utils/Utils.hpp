/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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
#include <QLocale>
#include <QImage>
#include <QDateTime>

#include <linphone++/address.hh>

#include "LinphoneEnums.hpp"


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


class Utils : public QObject{
	Q_OBJECT
public:
	Utils(QObject * parent = nullptr) : QObject(parent){}
	// Qt interfaces	
	Q_INVOKABLE static bool hasCapability(const QString& address, const LinphoneEnums::FriendCapability& capability);
	Q_INVOKABLE static QString toDateTimeString(QDateTime date);
	Q_INVOKABLE static QString toTimeString(QDateTime date);
	Q_INVOKABLE static QString toDateString(QDateTime date);
	Q_INVOKABLE static QString getDisplayName(const QString& address);
	Q_INVOKABLE static QString toString(const LinphoneEnums::TunnelMode& mode);
//----------------------------------------------------------------------------------
	
	static inline QString coreStringToAppString (const std::string &str) {
		return QString::fromLocal8Bit(str.c_str(), int(str.size()));
	}
	
	static inline std::string appStringToCoreString (const QString &str) {
		return qPrintable(str);
	}
	
	// Reverse function of strstr.
	static char *rstrstr (const char *a, const char *b);
	// Return the path if it is an image else an empty path.
	static QImage getImage(const QString &pUri);
	// Returns the same path given in parameter if `filePath` exists.
	// Otherwise returns a safe path with a unique number before the extension.
	static QString getSafeFilePath (const QString &filePath, bool *soFarSoGood = nullptr);
	static std::shared_ptr<linphone::Address> getMatchingLocalAddress(std::shared_ptr<linphone::Address> p_localAddress);
	static QString cleanSipAddress (const QString &sipAddress);// Return at most : sip:username@domain
	// Test if the process exists
	static bool processExists(const quint64& p_processId);
	
	// Connect once to a member function.
	template<typename Func1, typename Func2>
	static inline QMetaObject::Connection connectOnce (
			typename QtPrivate::FunctionPointer<Func1>::Object *sender,
			Func1 signal,
			typename QtPrivate::FunctionPointer<Func2>::Object *receiver,
			Func2 slot
			) {
		QMetaObject::Connection connection = QObject::connect(sender, signal, receiver, slot);
		QMetaObject::Connection *deleter = new QMetaObject::Connection();
		
		*deleter = QObject::connect(sender, signal, [connection, deleter] {
			QObject::disconnect(connection);
			QObject::disconnect(*deleter);
			delete deleter;
		});
		
		return connection;
	}
	
	// Connect once to a function.
	template<typename Func1, typename Func2>
	static inline QMetaObject::Connection connectOnce (
			typename QtPrivate::FunctionPointer<Func1>::Object *sender,
			Func1 signal,
			const QObject *receiver,
			Func2 slot
			) {
		QMetaObject::Connection connection = QObject::connect(sender, signal, receiver, slot);
		QMetaObject::Connection *deleter = new QMetaObject::Connection();
		
		*deleter = QObject::connect(sender, signal, [connection, deleter] {
			QObject::disconnect(connection);
			QObject::disconnect(*deleter);
			delete deleter;
		});
		
		return connection;
	}
	static linphone::TransportType stringToTransportType (const QString &transport);
	static std::shared_ptr<linphone::Address> interpretUrl(const QString& address);
	
	
	static QString getCountryName(const QLocale::Country& country);
	static void copyDir(QString from, QString to);// Copy a folder recursively without erasing old file
	static QString getDisplayName(const std::shared_ptr<const linphone::Address>& address);	// Get the displayname from addres in this order : Friends, Contact, Display address, Username address
	static std::shared_ptr<linphone::Config> getConfigIfExists (const QString& configPath);
	static QString computeUserAgent(const std::shared_ptr<linphone::Config>& config);
};

#endif // UTILS_H_
