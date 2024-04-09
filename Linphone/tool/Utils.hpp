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

#include <QDebug>
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

class CallGui;
class QQuickWindow;
class VariantObject;
class CallGui;
class ConferenceInfoGui;

class Utils : public QObject {
	Q_OBJECT
public:
	Utils(QObject *parent = nullptr) : QObject(parent) {
	}

	Q_INVOKABLE static VariantObject *getDisplayName(const QString &address);
	Q_INVOKABLE static QString getGivenNameFromFullName(const QString &fullName);
	Q_INVOKABLE static QString getFamilyNameFromFullName(const QString &fullName);
	Q_INVOKABLE static QString getInitials(const QString &username); // Support UTF32

	Q_INVOKABLE static VariantObject *createCall(QString sipAddress,
												 QVariantMap options = {},
												 QString prepareTransfertAddress = "",
												 QHash<QString, QString> headers = {});
	Q_INVOKABLE static void openCallsWindow(CallGui *call);
	Q_INVOKABLE static void setupConference(ConferenceInfoGui *confGui);
	Q_INVOKABLE static void setCallsWindowCall(CallGui *call);
	Q_INVOKABLE static void setCallsWindowProperty(const QString &id, const QVariant &property);
	Q_INVOKABLE static QQuickWindow *getMainWindow();
	Q_INVOKABLE static void showInformationPopup(const QString &title,
	                                             const QString &description,
	                                             bool isSuccess = true,
	                                             QQuickWindow *window = nullptr);
	Q_INVOKABLE static QQuickWindow *getCallsWindow(CallGui *callGui);
	Q_INVOKABLE static void closeCallsWindow();
	Q_INVOKABLE static VariantObject *haveAccount();
	Q_INVOKABLE static void smartShowWindow(QQuickWindow *window);
	Q_INVOKABLE static QString createAvatar(const QUrl &fileUrl); // Return the avatar path
	Q_INVOKABLE static QString formatElapsedTime(int seconds,
	                                             bool dotsSeparator = true); // Return the elapsed time formated
	Q_INVOKABLE static QString formatDate(const QDateTime &date, bool includeTime = true); // Return the date formated
	Q_INVOKABLE static QString formatDateElapsedTime(const QDateTime &date);
	Q_INVOKABLE static QStringList generateSecurityLettersArray(int arraySize, int correctIndex, QString correctCode);
	Q_INVOKABLE static int getRandomIndex(int size);
	Q_INVOKABLE static void copyToClipboard(const QString &text);
	Q_INVOKABLE static QString toDateString(QDateTime date, const QString &format = "");
	Q_INVOKABLE static QString toDateString(QDate date, const QString &format = "");
	Q_INVOKABLE static QString toDateDayString(const QDateTime &date);
	Q_INVOKABLE static QString toDateHourString(const QDateTime &date);
	Q_INVOKABLE static QString toDateDayNameString(const QDateTime &date);
	Q_INVOKABLE static QString toDateMonthString(const QDateTime &date);
	Q_INVOKABLE static bool isCurrentDay(QDateTime date);
	Q_INVOKABLE static bool isCurrentDay(QDate date);
	Q_INVOKABLE static bool isCurrentMonth(QDate date);
	Q_INVOKABLE static bool isBeforeToday(QDate date);
	Q_INVOKABLE static bool datesAreEqual(const QDate &a, const QDate &b);
	Q_INVOKABLE static QDateTime createDateTime(const QDate &date, int hour, int min);
	Q_INVOKABLE static int getYear(const QDate &date);
	Q_INVOKABLE static int secsTo(const QString &start, const QString &end);
	Q_INVOKABLE static QDateTime addSecs(QDateTime date, int secs);
	Q_INVOKABLE static QString generateLinphoneSipAddress(const QString &uri);
	Q_INVOKABLE static QString findAvatarByAddress(const QString &address);
	static QString generateSavedFilename(const QString &from, const QString &to);
	Q_INVOKABLE static bool isMe(const QString &address);
	static QString getCountryName(const QLocale::Territory &p_country);

	static QString getApplicationProduct();
	static QString getOsProduct();
	static QString computeUserAgent();

	static inline QString coreStringToAppString(const std::string &str) {
		if (Constants::LinphoneLocaleEncoding == QString("UTF-8")) return QString::fromStdString(str);
		else
			return QString::fromLocal8Bit(str.c_str(),
			                              int(str.size())); // When using Locale. Be careful about conversion
			                                                // bijection with UTF-8, you may loss characters
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

	static inline float computeVu(float volume) {
		constexpr float VuMin = -20.f;
		constexpr float VuMax = 4.f;

		if (volume < VuMin) return 0.f;
		if (volume > VuMax) return 1.f;

		return (volume - VuMin) / (VuMax - VuMin);
	}
};

#define lDebug() qDebug().noquote()
#define lInfo() qInfo().noquote()
#define lWarning() qWarning().noquote()
#define lCritical() qCritical().noquote()
#define lFatal() qFatal().noquote()

#endif // UTILS_H_
