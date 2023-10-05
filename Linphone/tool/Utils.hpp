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

#include <QDateTime>
#include <QImage>
#include <QLocale>
#include <QObject>
#include <QString>

#include "Constants.hpp"

class QAction;
class QWidget;
class DateModel;

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

class ContentModel;

class Utils : public QObject {
	Q_OBJECT
public:
	Utils(QObject *parent = nullptr) : QObject(parent) {
	}
	/*
	    typedef enum{
	        SIP_DISPLAY_USERNAME = 0,
	        SIP_DISPLAY_ALL = -1
	    }SipDisplayMode;
	    Q_ENUM(SipDisplayMode)

	    // Qt interfaces
	    Q_INVOKABLE static bool hasCapability(const QString& address, const LinphoneEnums::FriendCapability& capability,
	bool defaultCapability = true);
	// ***** DATE TIME
	    Q_INVOKABLE static QDateTime addMinutes(QDateTime date, const int& min);
	    static QDateTime getOffsettedUTC(const QDateTime& date);
	    Q_INVOKABLE static QString toDateTimeString(QDateTime date, const QString& format = "yyyy/MM/dd hh:mm:ss");
	    Q_INVOKABLE static QString toTimeString(QDateTime date, const QString& format = "hh:mm:ss");
	    Q_INVOKABLE static QString toDateString(QDateTime date, const QString& format = "");
	    Q_INVOKABLE static QString toDateString(QDate date, const QString& format = "");
	    Q_INVOKABLE static QString toDisplayString(const QString& str, SipDisplayMode displayMode = SIP_DISPLAY_ALL);
	    Q_INVOKABLE static QDate getCurrentDate();
	    Q_INVOKABLE static DateModel* getCurrentDateModel();
	    Q_INVOKABLE static QDate getMinDate();
	    Q_INVOKABLE static DateModel* getMinDateModel();
	    Q_INVOKABLE static QDate toDate(const QString& str, const QString& format = "yyyy/MM/dd");
	    Q_INVOKABLE static QDate getDate(int year, int month, int day);
	    Q_INVOKABLE static DateModel* toDateModel(const QString& str, const QString& format = "yyyy/MM/dd");
	    Q_INVOKABLE static DateModel* getDateModel(int year, int month, int day);
	    Q_INVOKABLE static int getFullYear(const QDate& date);
	    Q_INVOKABLE static int getMonth(const QDate& date);
	    Q_INVOKABLE static int getDay(const QDate& date);
	    Q_INVOKABLE static int getDayOfWeek(const QDate& date);
	    Q_INVOKABLE static bool equals(const QDate& d1, const QDate& d2);	// Override JS '==' operator
	    Q_INVOKABLE static bool isGreatherThan(const QDate& d1, const QDate& d2); // Override JS '>=' operator
	//*****
	    static void cleanDisplayNameCache(const QString& address = "");// if "", clean all cache
	    Q_INVOKABLE static QString getDisplayName(const QString& address);
	    Q_INVOKABLE static QString getInitials(const QString& username);	// Support UTF32
	    Q_INVOKABLE static QString toString(const LinphoneEnums::TunnelMode& mode);
	    Q_INVOKABLE static bool isMe(const QString& address);
	    Q_INVOKABLE static bool isAnimatedImage(const QString& path);
	    Q_INVOKABLE static bool isImage(const QString& path);
	    Q_INVOKABLE static bool isVideo(const QString& path);
	    Q_INVOKABLE static bool isPdf(const QString& path);
	    Q_INVOKABLE static bool isSupportedForDisplay(const QString& path);
	    Q_INVOKABLE static bool canHaveThumbnail(const QString& path);
	    Q_INVOKABLE static bool isPhoneNumber(const QString& txt);
	    Q_INVOKABLE static bool isUsername(const QString& txt);	// Check with Regex
	    Q_INVOKABLE static bool isValidUrl(const QString& url);
	    Q_INVOKABLE QSize getImageSize(const QString& url);
	    Q_INVOKABLE static QPoint getCursorPosition();
	    Q_INVOKABLE static QString getFileChecksum(const QString& filePath);
	    static bool codepointIsEmoji(uint code);
	    static bool codepointIsVisible(uint code);
	    Q_INVOKABLE static bool isOnlyEmojis(const QString& text);
	    Q_INVOKABLE static QString encodeEmojiToQmlRichFormat(const QString &body);
	    Q_INVOKABLE static QString encodeTextToQmlRichFormat(const QString& text, const QVariantMap& options =
	QVariantMap()); Q_INVOKABLE static QString getFileContent(const QString& filePath);

	    Q_INVOKABLE static bool openWithPdfViewer(ContentModel *contentModel, const QString& filePath, const int& width,
	const int& height);	// return true if PDF is enabled

	//----------------------------------------------------------------------------------
	    */
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

	/*
	// Return the path if it is an image else an empty path.
	static QImage getImage(const QString &pUri);
	// Returns the same path given in parameter if `filePath` exists.
	// Otherwise returns a safe path with a unique number before the extension.
	static QString getSafeFilePath (const QString &filePath, bool *soFarSoGood = nullptr);
	static std::shared_ptr<linphone::Address> getMatchingLocalAddress(std::shared_ptr<linphone::Address>
	p_localAddress); static QString cleanSipAddress (const QString &sipAddress);// Return at most : sip:username@domain
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
	static std::shared_ptr<linphone::Address> interpretUrl(const QString& address);


	static QString getCountryName(const QLocale::Country& country);
	static void copyDir(QString from, QString to);// Copy a folder recursively without erasing old file
	static QString getDisplayName(const std::shared_ptr<const linphone::Address>& address);	// Get the displayname from
	addres in this order : Friends, Contact, Display address, Username address static std::shared_ptr<linphone::Config>
	getConfigIfExists (const QString& configPath); static QString getApplicationProduct(); static QString
	getOsProduct(); static QString computeUserAgent(const std::shared_ptr<linphone::Config>& config);

	static bool isMe(const std::shared_ptr<const linphone::Address>& address);

	static void deleteAllUserData();
	static void deleteAllUserDataOffline();// When we are out of all events and core is not running (aka in main())

	static void setFamilyFont(QAction * dest, const QString& family);
	static void setFamilyFont(QWidget * dest, const QString& family);
	static QPixmap getMaskedPixmap(const QString& name, const QColor& color);
*/
};

#endif // UTILS_H_
