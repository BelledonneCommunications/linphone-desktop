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
#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"

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
class ConferenceCore;
class ParticipantDeviceCore;
class DownloadablePayloadTypeCore;
class ChatGui;

class Utils : public QObject, public AbstractObject {
	Q_OBJECT
public:
	Utils(QObject *parent = nullptr) : QObject(parent) {
	}

	Q_INVOKABLE static VariantObject *getDisplayName(const QString &address);
	Q_INVOKABLE static QString getUsername(const QString &address);
	Q_INVOKABLE static QString getGivenNameFromFullName(const QString &fullName);
	Q_INVOKABLE static QString getFamilyNameFromFullName(const QString &fullName);
	Q_INVOKABLE static QString getInitials(const QString &username); // Support UTF32
	Q_INVOKABLE static VariantObject *findLocalAccountByAddress(const QString &address);

	Q_INVOKABLE static void
	createCall(const QString &sipAddress,
	           QVariantMap options = {},
	           LinphoneEnums::MediaEncryption mediaEncryption = LinphoneEnums::MediaEncryption::None,
	           const QString &prepareTransfertAddress = "",
	           const QHash<QString, QString> &headers = {});
	Q_INVOKABLE static void createGroupCall(QString subject, const std::list<QString> &participantAddresses);
	Q_INVOKABLE static void setupConference(ConferenceInfoGui *confGui);
	Q_INVOKABLE static QQuickWindow *getMainWindow();
	Q_INVOKABLE static void openCallsWindow(CallGui *call);
	Q_INVOKABLE static QQuickWindow *getLastActiveWindow();
	Q_INVOKABLE static void setLastActiveWindow(QQuickWindow *data);
	Q_INVOKABLE static void showInformationPopup(const QString &title,
	                                             const QString &description,
	                                             bool isSuccess = true,
	                                             QQuickWindow *window = nullptr);
	Q_INVOKABLE static QQuickWindow *getCallsWindow(CallGui *callGui = nullptr);
	Q_INVOKABLE static void closeCallsWindow();
	Q_INVOKABLE static VariantObject *haveAccount();
	Q_INVOKABLE static void smartShowWindow(QQuickWindow *window);
	Q_INVOKABLE static QString createAvatar(const QUrl &fileUrl); // Return the avatar path
	Q_INVOKABLE static QString formatElapsedTime(int seconds,
	                                             bool dotsSeparator = true); // Return the elapsed time formated
	Q_INVOKABLE static QString formatDate(const QDateTime &date,
	                                      bool includeTime = true,
	                                      bool includeDateIfToday = true,
	                                      QString format = ""); // Return the date formated
	Q_INVOKABLE static QString formatDateElapsedTime(const QDateTime &date);
	Q_INVOKABLE static QString formatTime(const QDateTime &date); // Return the time formated
	Q_INVOKABLE static QStringList generateSecurityLettersArray(int arraySize, int correctIndex, QString correctCode);
	Q_INVOKABLE static int getRandomIndex(int size);
	Q_INVOKABLE static bool copyToClipboard(const QString &text);
	Q_INVOKABLE static QString createVCardFile(const QString &username, const QString &vcardAsString);
	Q_INVOKABLE static void shareByEmail(const QString &subject,
	                                     const QString &body = QString(),
	                                     const QString &attachment = QString(),
	                                     const QString &receiver = QString());
	Q_INVOKABLE static QString getClipboardText();
	Q_INVOKABLE static QString toDateString(QDateTime date, const QString &format = "");
	Q_INVOKABLE static QString toDateString(QDate date, const QString &format = "");
	Q_INVOKABLE static QString toDateDayString(const QDateTime &date);
	Q_INVOKABLE static QString toDateHourString(const QDateTime &date);
	Q_INVOKABLE static QString toDateDayNameString(const QDateTime &date);
	Q_INVOKABLE static QString toDateMonthString(const QDateTime &date);
	Q_INVOKABLE static QString toDateMonthAndYearString(const QDateTime &date);
	Q_INVOKABLE static bool isCurrentDay(QDateTime date);
	Q_INVOKABLE static bool isCurrentDay(QDate date);
	Q_INVOKABLE static bool isCurrentMonth(QDate date);
	Q_INVOKABLE static bool datesAreEqual(const QDate &a, const QDate &b);
	Q_INVOKABLE static bool dateisInMonth(const QDate &a, int month, int year);
	Q_INVOKABLE static QDateTime createDateTime(const QDate &date, int hour, int min);
	Q_INVOKABLE static QDateTime getCurrentDateTime();
	Q_INVOKABLE static QDateTime getCurrentDateTimeUtc();
	Q_INVOKABLE static int getYear(const QDate &date);
	Q_INVOKABLE static int secsTo(const QString &start, const QString &end);
	Q_INVOKABLE static QDateTime addSecs(QDateTime date, int secs);
	Q_INVOKABLE static QDateTime addYears(QDateTime date, int years);
	Q_INVOKABLE static int timeOffset(QDateTime start, QDateTime end);
	Q_INVOKABLE static int daysOffset(QDateTime start, QDateTime end);
	Q_INVOKABLE static VariantObject *interpretUrl(QString uri);
	Q_INVOKABLE static bool isValidURL(const QString &url);
	Q_INVOKABLE static VariantObject *findAvatarByAddress(const QString &address);
	Q_INVOKABLE static VariantObject *findFriendByAddress(const QString &address);
	Q_INVOKABLE static VariantObject *getFriendAddressSecurityLevel(const QString &address);
	static QString generateSavedFilename(const QString &from, const QString &to);
	Q_INVOKABLE static VariantObject *isMe(const QString &address);
	Q_INVOKABLE static VariantObject *isLocal(const QString &address);
	Q_INVOKABLE static bool isUsername(const QString &txt); // Regex check
	static QString getCountryName(const QLocale::Territory &p_country);
	Q_INVOKABLE static void useFetchConfig(const QString &configUrl);
	Q_INVOKABLE void playDtmf(const QString &dtmf);
	Q_INVOKABLE bool isInteger(const QString &text);
	Q_INVOKABLE QString boldTextPart(const QString &text, const QString &regex);
	Q_INVOKABLE static QString getFileChecksum(const QString &filePath);
	Q_INVOKABLE QList<QVariant> append(const QList<QVariant> a, const QList<QVariant> b);
	Q_INVOKABLE QString getAddressToDisplay(QVariantList addressList, QString filter, QString defaultAddress);

	Q_INVOKABLE static VariantObject *getCurrentCallChat(CallGui *call);
	Q_INVOKABLE static VariantObject *getChatForAddress(QString address);
	//	QDir findDirectoryByName(QString startPath, QString name);

	static QString getApplicationProduct();
	static QString getOsProduct();

	static QList<QSharedPointer<DownloadablePayloadTypeCore>> getDownloadableVideoPayloadTypes();
	static void checkDownloadedCodecsUpdates();

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

	// Variant creators:

	static QVariantMap createDeviceVariant(const QString &id, const QString &name);
	static QVariantMap createDialPlanVariant(QString flag, QString text);
	static QVariantMap createFriendAddressVariant(const QString &label, const QString &address);
	static QVariantMap
	createFriendDeviceVariant(const QString &name, const QString &address, LinphoneEnums::SecurityLevel level);

	// CLI

	static void runCommandLine(QString command);

private:
	DECLARE_ABSTRACT_OBJECT
};

#define lDebug() qDebug().noquote()
#define lInfo() qInfo().noquote()
#define lWarning() qWarning().noquote()
#define lCritical() qCritical().noquote()
#define lFatal() qFatal().noquote()

#endif // UTILS_H_
