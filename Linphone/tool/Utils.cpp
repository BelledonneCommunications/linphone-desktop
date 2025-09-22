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

#include "Utils.hpp"

#include "UriTools.hpp"
#include "core/App.hpp"
#include "core/call/CallGui.hpp"
#include "core/chat/ChatCore.hpp"
#include "core/chat/ChatGui.hpp"
#include "core/chat/message/ChatMessageGui.hpp"
#include "core/conference/ConferenceCore.hpp"
#include "core/conference/ConferenceInfoCore.hpp"
#include "core/conference/ConferenceInfoGui.hpp"
#include "core/friend/FriendGui.hpp"
#include "core/participant/ParticipantDeviceCore.hpp"
#include "core/path/Paths.hpp"
#include "core/payload-type/DownloadablePayloadTypeCore.hpp"
#include "core/recorder/RecorderGui.hpp"
#include "model/object/VariantObject.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/providers/AvatarProvider.hpp"

#include <limits.h>

#include <QClipboard>
#include <QCryptographicHash>
#include <QDesktopServices>
#include <QHostAddress>
#include <QImageReader>
#include <QMimeDatabase>
#include <QProcess>
#include <QQmlComponent>
#include <QQmlProperty>
#include <QQuickWindow>
#include <QRandomGenerator>
#include <QRegularExpression>

#ifdef Q_OS_WIN
#ifndef NOMINMAX
#define NOMINMAX 1
#endif
#include <windows.h>
#endif

DEFINE_ABSTRACT_OBJECT(Utils)

namespace {
constexpr int SafeFilePathLimit = 100;
}

// =============================================================================

char *Utils::rstrstr(const char *a, const char *b) {
	size_t a_len = strlen(a);
	size_t b_len = strlen(b);

	if (b_len > a_len) return nullptr;

	for (const char *s = a + a_len - b_len; s >= a; --s) {
		if (!strncmp(s, b, b_len)) return const_cast<char *>(s);
	}

	return nullptr;
}

VariantObject *Utils::getDisplayName(const QString &address) {
	QStringList splitted = address.split(":");
	if (splitted.size() > 0 && splitted[0] == "sip") splitted.removeFirst();
	VariantObject *data = nullptr;
	if (splitted.size() != 0)
		data = new VariantObject("getDisplayName", splitted.first().split("@").first()); // Scope : GUI
	if (!data) return nullptr;
	data->makeRequest([address]() {
		QString displayName = ToolModel::getDisplayName(address);
		return displayName;
	});
	data->requestValue();
	return data;
}

QString Utils::getUsername(const QString &address) {
	QString res = address;
	if (res.startsWith("sip:")) res.remove("sip:");
	int splitIndex = res.lastIndexOf('@');
	if (splitIndex != -1) res.truncate(splitIndex);
	return res;
}

QString Utils::getGivenNameFromFullName(const QString &fullName) {
	if (fullName.isEmpty()) return QString();
	auto nameSplitted = fullName.split(" ");
	return nameSplitted[0];
}

QString Utils::getFamilyNameFromFullName(const QString &fullName) {
	if (fullName.isEmpty()) return QString();
	auto nameSplitted = fullName.split(" ");
	nameSplitted.removeFirst();
	return nameSplitted.join(" ");
}

inline std::string u32_to_ascii(std::u32string const &s) {
	std::string out;
	std::transform(begin(s), end(s), back_inserter(out),
	               [](char32_t c) { return c < 128 ? static_cast<char>(c) : '?'; });
	return out;
}

QString Utils::getInitials(const QString &username) {
	if (username.isEmpty()) return "";

	QRegularExpression regex("[\\s\\.]+");
	QStringList words = username.split(regex); // Qt 5.14: Qt::SkipEmptyParts
	std::u32string char32;
	auto str32 = words[0].toStdU32String();
	char32 += str32[0];

	// if name starts by an emoji, only return this one
	QVector<uint> utf32_string = username.toUcs4();
	auto code = utf32_string[0];
	if (Utils::codepointIsEmoji(code)) return QString::fromStdU32String(char32);

	QStringList initials;
	initials << QString::fromStdU32String(char32);
	for (int i = 1; i < words.size() && initials.size() <= 1; ++i) {
		if (words[i].size() > 0) {
			str32 = words[i].toStdU32String();
			char32[0] = str32[0];
			initials << QString::fromStdU32String(char32);
			std::string converted = u32_to_ascii(char32);
			if (Utils::codepointIsEmoji(atoi(converted.c_str()))) {
				break;
			}
		}
	}
	return QLocale().toUpper(initials.join(""));
}

VariantObject *Utils::findLocalAccountByAddress(const QString &address) {
	VariantObject *data = new VariantObject("findLocalAccountByAddress");
	if (!data) return nullptr;
	data->makeRequest([address]() {
		auto linAccount = ToolModel::findAccount(address);
		if (linAccount) {
			auto accountCore = AccountCore::create(linAccount);
			return QVariant::fromValue(new AccountGui(accountCore));
		}
		return QVariant();
	});
	data->requestValue();
	return data;
}

void Utils::createCall(const QString &sipAddress,
                       QVariantMap options,
                       LinphoneEnums::MediaEncryption mediaEncryption,
                       const QString &prepareTransfertAddress,
                       const QHash<QString, QString> &headers) {
	// if default value use the settings' value
	if (mediaEncryption == LinphoneEnums::MediaEncryption::None)
		mediaEncryption =
		    App::getInstance()->getSettings()->getMediaEncryption()["id"].value<LinphoneEnums::MediaEncryption>();
	lDebug() << "[Utils] create call with uri :" << sipAddress << mediaEncryption;
	App::postModelAsync([sipAddress, options, mediaEncryption, prepareTransfertAddress, headers]() {
		QString errorMessage;
		bool success = ToolModel::createCall(sipAddress, options, prepareTransfertAddress, headers,
		                                     LinphoneEnums::toLinphone(mediaEncryption), &errorMessage);
		if (!success) {
			//: "L'appel n'a pas pu être créé"
			if (errorMessage.isEmpty()) errorMessage = tr("information_popup_call_not_created_message");
			showInformationPopup(tr("information_popup_error_title"), errorMessage, false);
		}
	});
}

void Utils::createGroupCall(QString subject, const std::list<QString> &participantAddresses) {
	App::postModelAsync([subject, participantAddresses]() {
		QString errorMessage;
		bool success = ToolModel::createGroupCall(subject, participantAddresses, &errorMessage);
		if (!success) {
			if (errorMessage.isEmpty()) errorMessage = tr("information_popup_group_call_not_created_message");
			showInformationPopup(tr("information_popup_error_title"), errorMessage, false);
		}
	});
}

// TODO : change conf info only from qml
//  (bug si on est déjà en appel et qu'on lance une conf)
// demander à jonhatan pour le design : quand on est déjà en appel
// et qu'on join une conf on retourne donc sur la waiting room
// Comment on annule ? Si on ferme la fenêtre ça va finir l'appel en cours
void Utils::setupConference(ConferenceInfoGui *confGui) {
	if (!confGui) return;
	auto window = App::getInstance()->getCallsWindow(QVariant());
	window->setProperty("conferenceInfo", QVariant::fromValue(confGui));
	window->show();
}

void Utils::openCallsWindow(CallGui *call) {
	if (call) {
		auto window = App::getInstance()->getCallsWindow(QVariant::fromValue(call));
		window->show();
		window->raise();
	}
}

QQuickWindow *Utils::getCallsWindow(CallGui *callGui) {
	auto app = App::getInstance();
	auto window = app->getCallsWindow(QVariant::fromValue(callGui));
	return window;
}

void Utils::closeCallsWindow() {
	App::getInstance()->closeCallsWindow();
}

QQuickWindow *Utils::getMainWindow() {
	auto win = App::getInstance()->getMainWindow();
	return win;
}

QQuickWindow *Utils::getLastActiveWindow() {
	return App::getInstance()->getLastActiveWindow();
}
void Utils::setLastActiveWindow(QQuickWindow *data) {
	App::getInstance()->setLastActiveWindow(data);
}

void Utils::showInformationPopup(const QString &title,
                                 const QString &description,
                                 bool isSuccess,
                                 QQuickWindow *window) {
	if (!window) window = App::getInstance()->getMainWindow();
	QMetaObject::invokeMethod(window, "showInformationPopup", Q_ARG(QVariant, title), Q_ARG(QVariant, description),
	                          Q_ARG(QVariant, isSuccess));
}

VariantObject *Utils::haveAccount() {
	VariantObject *result = new VariantObject("haveAccount");
	if (!result) return nullptr;
	// Using connect ensure to have sender() and receiver() alive.
	result->makeRequest([]() {
		// Model
		return CoreModel::getInstance()->getCore()->getAccountList().size() > 0;
	});
	result->makeUpdate(CoreModel::getInstance().get(), &CoreModel::accountAdded);
	result->makeUpdate(CoreModel::getInstance().get(), &CoreModel::accountRemoved);

	result->requestValue();
	return result;
}

void Utils::smartShowWindow(QQuickWindow *window) {
	if (!window) return;
	if (window->visibility() == QWindow::Maximized) // Avoid to change visibility mode
		window->showMaximized();
	else window->show();
	App::getInstance()->setLastActiveWindow(window);
	window->raise(); // Raise ensure to get focus on Mac
	window->requestActivate();
}

QString Utils::createAvatar(const QUrl &fileUrl) {
	QString filePath = fileUrl.toLocalFile();
	QString fileId;  // uuid.ext
	QString fileUri; // image://avatar/filename.ext
	QFile file;
	if (!filePath.isEmpty()) {
		if (filePath.startsWith("image:")) { // No need to copy
			fileUri = filePath;
		} else {
			file.setFileName(filePath);
			if (!file.exists()) {
				qWarning() << "[Utils] Avatar not found at " << filePath;
				return "";
			}
			if (QImageReader::imageFormat(filePath).size() == 0) {
				qWarning() << "[Utils] Avatar extension not supported by QImageReader for " << filePath;
				return "";
			}
			QFileInfo info(file);
			QString uuid = QUuid::createUuid().toString();
			fileId = QStringLiteral("%1.%2")
			             .arg(uuid.mid(1, uuid.length() - 2)) // Remove `{}`.
			             .arg(info.suffix());
			fileUri = QStringLiteral("image://%1/%2").arg(AvatarProvider::ProviderId).arg(fileId);
			QString dest = Paths::getAvatarsDirPath() + fileId;
			if (!file.copy(dest)) {
				qWarning() << "[Utils] Avatar couldn't be created to " << dest;
				return "";
			}
		}
	}
	return fileUri;
}

QString Utils::formatElapsedTime(int seconds, bool dotsSeparator) {
	// s,	m,	h,		d,		W,		M,			Y
	// 1,	60,	3600,	86400,	604800,	2592000,	31104000
	auto y = floor(seconds / 31104000);
	//: %n an(s)
	if (y > 0) return tr("number_of_years", "", y);
	auto M = floor(seconds / 2592000);
	//: "%n mois"
	if (M > 0) return tr("number_of_month", "", M);
	auto w = floor(seconds / 604800);
	//: %n semaine(s)
	if (w > 0) return tr("number_of_weeks", "", w);
	auto d = floor(seconds / 86400);
	//: %n jour(s)
	if (d > 0) return tr("number_of_days", "", d);

	auto h = floor(seconds / 3600);
	auto m = floor((seconds - h * 3600) / 60);
	auto s = seconds - h * 3600 - m * 60;

	QString hours, min, sec;

	if (dotsSeparator && h < 10 && h > 0) hours = "0";
	hours.append(QString::number(h));

	if (dotsSeparator && m < 10) min = "0";
	min.append(QString::number(m));

	if (dotsSeparator && s < 10) sec = "0";
	sec.append(QString::number(s));

	if (dotsSeparator) return (h == 0 ? "" : hours + ":") + min + ":" + sec;
	else return (h == 0 ? "" : hours + "h ") + (m == 0 ? "" : min + "min ") + sec + "s";
}

QString Utils::formatDate(QDateTime date, bool includeTime, bool includeDateIfToday, QString format) {
	if (!date.isValid()) return QString();
	date = getOffsettedUTC(date);
	QString dateDay;
	//: "Aujourd'hui"
	if (date.date() == QDate::currentDate()) dateDay = tr("today");
	//: "Hier
	else if (date.date() == QDate::currentDate().addDays(-1)) dateDay = tr("yesterday");
	else {
		if (format.isEmpty())
			format = date.date().year() == QDateTime::currentDateTime(date.timeZone()).date().year() ? "dd MMMM"
			                                                                                         : "dd MMMM yyyy";
		dateDay = App::getInstance()->getLocale().toString(date.date(), format);
	}
	if (!includeTime) return dateDay;

	auto time = date.time().toString("hh:mm");
	if (!includeDateIfToday && date.date() == QDate::currentDate()) return time;

	return dateDay + " | " + time;
}

QString Utils::formatTime(const QDateTime &date) {
	return date.time().toString("hh:mm");
}

QString Utils::formatDuration(int durationMs) {
	auto now = QDateTime::currentDateTime();
	auto end = now.addMSecs(durationMs);
	auto daysTo = now.daysTo(end);
	if (daysTo > 0) {
		//: Tomorrow
		if (daysTo == 1) return tr("duration_tomorrow");
		else {
			//: %1 jour(s)
			return tr("duration_number_of_days", "", daysTo);
		}
	} else {
		QTime duration(0, 0);
		duration = duration.addMSecs(durationMs);
		return duration.hour() > 0 ? duration.toString("hh:mm:ss") : duration.toString("mm:ss");
	}
}

QString Utils::formatDateElapsedTime(const QDateTime &date) {
	// auto y = floor(seconds / 31104000);
	// if (y > 0) return QString::number(y) + " years";
	// auto M = floor(seconds / 2592000);
	// if (M > 0) return QString::number(M) + " months";
	// auto w = floor(seconds / 604800);
	// if (w > 0) return QString::number(w) + " week";
	auto dateSec = date.secsTo(QDateTime::currentDateTime(date.timeZone()));

	auto d = floor(dateSec / 86400);
	if (d > 7) {
		return formatDate(date, false);
	} else if (d > 0) {
		return tr(date.date().toString("dddd").toLocal8Bit().data());
	}

	auto h = floor(dateSec / 3600);
	if (h > 0) return QString::number(h) + " h";

	auto m = floor((dateSec - h * 3600) / 60);
	if (m > 0) return QString::number(m) + " m";

	auto s = dateSec - h * 3600 - m * 60;
	return QString::number(s) + " s";
}

VariantObject *Utils::interpretUrl(QString uri) {
	VariantObject *data = new VariantObject("interpretUrl", uri);
	if (!data) return nullptr;
	data->makeRequest([uri]() -> QVariant {
		QString address = uri;
		auto addr = ToolModel::interpretUrl(uri);
		if (addr) address = Utils::coreStringToAppString(addr->asStringUriOnly());
		return QVariant(address);
	});
	if (!uri.contains('@')) {
		data->requestValue();
	} else if (!uri.startsWith("sip:")) {
		uri.prepend("sip:");
		data->setDefaultValue(uri);
	}
	return data;
}

bool Utils::isValidURL(const QString &url) {
	return QUrl(url).isValid();
}

VariantObject *Utils::findAvatarByAddress(const QString &address) {
	VariantObject *data = new VariantObject("findAvatarByAddress", "");
	if (!data) return nullptr;
	data->makeRequest([address]() -> QVariant {
		QString avatar;
		auto defaultFriendList = ToolModel::getAppFriendList();
		if (!defaultFriendList) return QVariant();
		auto linphoneAddr = ToolModel::interpretUrl(address);
		auto linFriend = CoreModel::getInstance()->getCore()->findFriend(linphoneAddr);
		if (linFriend) avatar = Utils::coreStringToAppString(linFriend->getPhoto());
		return QVariant(avatar);
	});
	// Rebuild avatar if needed
	auto updateValue = [data, address](const std::shared_ptr<linphone::Friend> &f) -> void {
		if (f && f->getAddress() && f->getAddress()->weakEqual(ToolModel::interpretUrl(address)))
			data->invokeRequestValue();
	};
	data->makeUpdateCond(CoreModel::getInstance().get(), &CoreModel::friendCreated, updateValue);
	data->makeUpdateCond(CoreModel::getInstance().get(), &CoreModel::friendRemoved, updateValue);
	data->makeUpdateCond(CoreModel::getInstance().get(), &CoreModel::friendUpdated, updateValue);
	data->requestValue();
	return data;
}

VariantObject *Utils::findFriendByAddress(const QString &address) {
	VariantObject *data = new VariantObject("findFriendByAddress");
	if (!data) return nullptr;
	data->makeRequest([address]() {
		auto linFriend = ToolModel::findFriendByAddress(address);
		if (!linFriend) return QVariant();
		auto friendCore = FriendCore::create(linFriend);
		return QVariant::fromValue(new FriendGui(friendCore));
	});
	// Rebuild friend if needed
	auto updateValue = [data, address](const std::shared_ptr<linphone::Friend> &f) -> void {
		if (f && f->getAddress() && f->getAddress()->weakEqual(ToolModel::interpretUrl(address)))
			data->invokeRequestValue();
	};
	data->makeUpdateCond(CoreModel::getInstance().get(), &CoreModel::friendCreated, updateValue); // New Friend
	data->makeUpdateCond(CoreModel::getInstance().get(), &CoreModel::friendRemoved, updateValue); // New Friend
	data->makeUpdateCond(CoreModel::getInstance().get(), &CoreModel::friendUpdated, updateValue);
	data->requestValue();
	return data;
}

VariantObject *Utils::getFriendSecurityLevel(const QString &address) {
	VariantObject *data = new VariantObject("getFriendAddressSecurityLevel");
	if (!data) return nullptr;
	data->makeRequest([address]() {
		auto defaultFriendList = ToolModel::getAppFriendList();
		if (!defaultFriendList) return QVariant();
		auto linphoneAddr = ToolModel::interpretUrl(address);
		auto linFriend = CoreModel::getInstance()->getCore()->findFriend(linphoneAddr);
		if (!linFriend) return QVariant();
		auto linAddr = ToolModel::interpretUrl(address);
		if (!linAddr) return QVariant();
		auto devices = linFriend->getDevicesForAddress(linphoneAddr);
		int verified = 0;
		return QVariant::fromValue(LinphoneEnums::fromLinphone(linFriend->getSecurityLevel()));
	});
	data->requestValue();
	return data;
}

VariantObject *Utils::getFriendAddressSecurityLevel(const QString &address) {
	VariantObject *data = new VariantObject("getFriendAddressSecurityLevel");
	if (!data) return nullptr;
	data->makeRequest([address]() {
		auto defaultFriendList = ToolModel::getAppFriendList();
		if (!defaultFriendList) return QVariant();
		auto linphoneAddr = ToolModel::interpretUrl(address);
		auto linFriend = CoreModel::getInstance()->getCore()->findFriend(linphoneAddr);
		if (!linFriend) return QVariant();
		auto linAddr = ToolModel::interpretUrl(address);
		if (!linAddr) return QVariant();
		auto secuLevel = linFriend->getSecurityLevelForAddress(linAddr);
		return QVariant::fromValue(LinphoneEnums::fromLinphone(secuLevel));
	});
	data->requestValue();
	return data;
}

QString Utils::generateSavedFilename(const QString &from, const QString &to) {
	auto escape = [](const QString &str) {
		constexpr char ReservedCharacters[] = "[<|>|:|\"|/|\\\\|\\?|\\*|\\+|\\||_|-]+";
		static QRegularExpression regexp(ReservedCharacters);
		return QString(str).replace(regexp, "");
	};
	return QStringLiteral("%1_%2_%3")
	    .arg(QDateTime::currentDateTime(QTimeZone::systemTimeZone()).toString("yyyy-MM-dd_hh-mm-ss"))
	    .arg(escape(from))
	    .arg(escape(to));
}

QStringList Utils::generateSecurityLettersArray(int arraySize, int correctIndex, QString correctCode) {
	QStringList vec;
	//: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	const QString possibleCharacters(tr("call_zrtp_token_verification_possible_characters"));
	const int n = 2;
	for (int i = 0; i < arraySize; ++i) {
		QString randomString;
		if (i == correctIndex) randomString = correctCode;
		else {
			do {
				randomString.clear();
				for (int j = 0; j < n; ++j) {
					int index = rand() % possibleCharacters.length();
					QChar nextChar = possibleCharacters.at(index);
					randomString.append(nextChar);
				}
			} while (vec.contains(randomString) || randomString == correctCode);
		}
		vec.append(randomString);
	}
	return vec;
}

int Utils::getRandomIndex(int size) {
	return QRandomGenerator::global()->bounded(size);
}

bool Utils::copyToClipboard(const QString &text) {
	QClipboard *clipboard = QApplication::clipboard();
	clipboard->clear();
	clipboard->setText(text);

	QString clipboardText = clipboard->text();
	if (clipboardText.isEmpty()) {
		lDebug() << "[Utils] Clipboard is empty!";
	}
	return !clipboardText.isEmpty();
}

QString Utils::createVCardFile(const QString &username, const QString &vcardAsString) {
	auto filepath = Paths::getVCardsPath() + username + ".vcf";
	QFile file(filepath);
	if (file.open(QIODevice::ReadWrite)) {
		QTextStream stream(&file);
		stream << vcardAsString;
		return filepath;
	}
	return QString();
}

void Utils::shareByEmail(const QString &subject,
                         const QString &body,
                         const QString &attachment,
                         const QString &receiver) {
	// QString attach = attachment;
	// attach.prepend("file:///");
	QUrl url(QString("mailto:?to=%1&subject=%2&body=%3").arg(receiver).arg(subject).arg(body));
	QDesktopServices::openUrl(url);
}

QString Utils::getClipboardText() {
	QClipboard *clipboard = QApplication::clipboard();
	return clipboard->text();
}

QString Utils::getApplicationProduct() {
	// Note: Keep '-' as a separator between application name and application type
	return QString(APPLICATION_NAME "-Desktop").remove(' ') + "/" + QCoreApplication::applicationVersion();
}

QString Utils::getOsProduct() {
	QString version =
	    QSysInfo::productVersion().remove(' '); // A version can be "Server 2016" (for Windows Server 2016)
	QString product = QSysInfo::productType().replace(' ', '-'); // Just in case
	return product + "/" + version;
}

QString Utils::getCountryName(const QLocale::Territory &p_country) {
	QString countryName;
	switch (p_country) {
		case QLocale::Afghanistan:
			if ((countryName = QCoreApplication::translate("country", "Afghanistan")) == "Afghanistan")
				countryName = "";
			break;
		case QLocale::Albania:
			if ((countryName = QCoreApplication::translate("country", "Albania")) == "Albania") countryName = "";
			break;
		case QLocale::Algeria:
			if ((countryName = QCoreApplication::translate("country", "Algeria")) == "Algeria") countryName = "";
			break;
		case QLocale::AmericanSamoa:
			if ((countryName = QCoreApplication::translate("country", "AmericanSamoa")) == "AmericanSamoa")
				countryName = "";
			break;
		case QLocale::Andorra:
			if ((countryName = QCoreApplication::translate("country", "Andorra")) == "Andorra") countryName = "";
			break;
		case QLocale::Angola:
			if ((countryName = QCoreApplication::translate("country", "Angola")) == "Angola") countryName = "";
			break;
		case QLocale::Anguilla:
			if ((countryName = QCoreApplication::translate("country", "Anguilla")) == "Anguilla") countryName = "";
			break;
		case QLocale::AntiguaAndBarbuda:
			if ((countryName = QCoreApplication::translate("country", "AntiguaAndBarbuda")) == "AntiguaAndBarbuda")
				countryName = "";
			break;
		case QLocale::Argentina:
			if ((countryName = QCoreApplication::translate("country", "Argentina")) == "Argentina") countryName = "";
			break;
		case QLocale::Armenia:
			if ((countryName = QCoreApplication::translate("country", "Armenia")) == "Armenia") countryName = "";
			break;
		case QLocale::Aruba:
			if ((countryName = QCoreApplication::translate("country", "Aruba")) == "Aruba") countryName = "";
			break;
		case QLocale::Australia:
			if ((countryName = QCoreApplication::translate("country", "Australia")) == "Australia") countryName = "";
			break;
		case QLocale::Austria:
			if ((countryName = QCoreApplication::translate("country", "Austria")) == "Austria") countryName = "";
			break;
		case QLocale::Azerbaijan:
			if ((countryName = QCoreApplication::translate("country", "Azerbaijan")) == "Azerbaijan") countryName = "";
			break;
		case QLocale::Bahamas:
			if ((countryName = QCoreApplication::translate("country", "Bahamas")) == "Bahamas") countryName = "";
			break;
		case QLocale::Bahrain:
			if ((countryName = QCoreApplication::translate("country", "Bahrain")) == "Bahrain") countryName = "";
			break;
		case QLocale::Bangladesh:
			if ((countryName = QCoreApplication::translate("country", "Bangladesh")) == "Bangladesh") countryName = "";
			break;
		case QLocale::Barbados:
			if ((countryName = QCoreApplication::translate("country", "Barbados")) == "Barbados") countryName = "";
			break;
		case QLocale::Belarus:
			if ((countryName = QCoreApplication::translate("country", "Belarus")) == "Belarus") countryName = "";
			break;
		case QLocale::Belgium:
			if ((countryName = QCoreApplication::translate("country", "Belgium")) == "Belgium") countryName = "";
			break;
		case QLocale::Belize:
			if ((countryName = QCoreApplication::translate("country", "Belize")) == "Belize") countryName = "";
			break;
		case QLocale::Benin:
			if ((countryName = QCoreApplication::translate("country", "Benin")) == "Benin") countryName = "";
			break;
		case QLocale::Bermuda:
			if ((countryName = QCoreApplication::translate("country", "Bermuda")) == "Bermuda") countryName = "";
			break;
		case QLocale::Bhutan:
			if ((countryName = QCoreApplication::translate("country", "Bhutan")) == "Bhutan") countryName = "";
			break;
		case QLocale::Bolivia:
			if ((countryName = QCoreApplication::translate("country", "Bolivia")) == "Bolivia") countryName = "";
			break;
		case QLocale::BosniaAndHerzegowina:
			if ((countryName = QCoreApplication::translate("country", "BosniaAndHerzegowina")) ==
			    "BosniaAndHerzegowina")
				countryName = "";
			break;
		case QLocale::Botswana:
			if ((countryName = QCoreApplication::translate("country", "Botswana")) == "Botswana") countryName = "";
			break;
		case QLocale::Brazil:
			if ((countryName = QCoreApplication::translate("country", "Brazil")) == "Brazil") countryName = "";
			break;
		case QLocale::Brunei:
			if ((countryName = QCoreApplication::translate("country", "Brunei")) == "Brunei") countryName = "";
			break;
		case QLocale::Bulgaria:
			if ((countryName = QCoreApplication::translate("country", "Bulgaria")) == "Bulgaria") countryName = "";
			break;
		case QLocale::BurkinaFaso:
			if ((countryName = QCoreApplication::translate("country", "BurkinaFaso")) == "BurkinaFaso")
				countryName = "";
			break;
		case QLocale::Burundi:
			if ((countryName = QCoreApplication::translate("country", "Burundi")) == "Burundi") countryName = "";
			break;
		case QLocale::Cambodia:
			if ((countryName = QCoreApplication::translate("country", "Cambodia")) == "Cambodia") countryName = "";
			break;
		case QLocale::Cameroon:
			if ((countryName = QCoreApplication::translate("country", "Cameroon")) == "Cameroon") countryName = "";
			break;
		case QLocale::Canada:
			if ((countryName = QCoreApplication::translate("country", "Canada")) == "Canada") countryName = "";
			break;
		case QLocale::CapeVerde:
			if ((countryName = QCoreApplication::translate("country", "CapeVerde")) == "CapeVerde") countryName = "";
			break;
		case QLocale::CaymanIslands:
			if ((countryName = QCoreApplication::translate("country", "CaymanIslands")) == "CaymanIslands")
				countryName = "";
			break;
		case QLocale::CentralAfricanRepublic:
			if ((countryName = QCoreApplication::translate("country", "CentralAfricanRepublic")) ==
			    "CentralAfricanRepublic")
				countryName = "";
			break;
		case QLocale::Chad:
			if ((countryName = QCoreApplication::translate("country", "Chad")) == "Chad") countryName = "";
			break;
		case QLocale::Chile:
			if ((countryName = QCoreApplication::translate("country", "Chile")) == "Chile") countryName = "";
			break;
		case QLocale::China:
			if ((countryName = QCoreApplication::translate("country", "China")) == "China") countryName = "";
			break;
		case QLocale::Colombia:
			if ((countryName = QCoreApplication::translate("country", "Colombia")) == "Colombia") countryName = "";
			break;
		case QLocale::Comoros:
			if ((countryName = QCoreApplication::translate("country", "Comoros")) == "Comoros") countryName = "";
			break;
		case QLocale::PeoplesRepublicOfCongo:
			if ((countryName = QCoreApplication::translate("country", "PeoplesRepublicOfCongo")) ==
			    "PeoplesRepublicOfCongo")
				countryName = "";
			break;
		case QLocale::DemocraticRepublicOfCongo:
			if ((countryName = QCoreApplication::translate("country", "DemocraticRepublicOfCongo")) ==
			    "DemocraticRepublicOfCongo")
				countryName = "";
			break;
		case QLocale::CookIslands:
			if ((countryName = QCoreApplication::translate("country", "CookIslands")) == "CookIslands")
				countryName = "";
			break;
		case QLocale::CostaRica:
			if ((countryName = QCoreApplication::translate("country", "CostaRica")) == "CostaRica") countryName = "";
			break;
		case QLocale::IvoryCoast:
			if ((countryName = QCoreApplication::translate("country", "IvoryCoast")) == "IvoryCoast") countryName = "";
			break;
		case QLocale::Croatia:
			if ((countryName = QCoreApplication::translate("country", "Croatia")) == "Croatia") countryName = "";
			break;
		case QLocale::Cuba:
			if ((countryName = QCoreApplication::translate("country", "Cuba")) == "Cuba") countryName = "";
			break;
		case QLocale::Cyprus:
			if ((countryName = QCoreApplication::translate("country", "Cyprus")) == "Cyprus") countryName = "";
			break;
		case QLocale::CzechRepublic:
			if ((countryName = QCoreApplication::translate("country", "CzechRepublic")) == "CzechRepublic")
				countryName = "";
			break;
		case QLocale::Denmark:
			if ((countryName = QCoreApplication::translate("country", "Denmark")) == "Denmark") countryName = "";
			break;
		case QLocale::Djibouti:
			if ((countryName = QCoreApplication::translate("country", "Djibouti")) == "Djibouti") countryName = "";
			break;
		case QLocale::Dominica:
			if ((countryName = QCoreApplication::translate("country", "Dominica")) == "Dominica") countryName = "";
			break;
		case QLocale::DominicanRepublic:
			if ((countryName = QCoreApplication::translate("country", "DominicanRepublic")) == "DominicanRepublic")
				countryName = "";
			break;
		case QLocale::Ecuador:
			if ((countryName = QCoreApplication::translate("country", "Ecuador")) == "Ecuador") countryName = "";
			break;
		case QLocale::Egypt:
			if ((countryName = QCoreApplication::translate("country", "Egypt")) == "Egypt") countryName = "";
			break;
		case QLocale::ElSalvador:
			if ((countryName = QCoreApplication::translate("country", "ElSalvador")) == "ElSalvador") countryName = "";
			break;
		case QLocale::EquatorialGuinea:
			if ((countryName = QCoreApplication::translate("country", "EquatorialGuinea")) == "EquatorialGuinea")
				countryName = "";
			break;
		case QLocale::Eritrea:
			if ((countryName = QCoreApplication::translate("country", "Eritrea")) == "Eritrea") countryName = "";
			break;
		case QLocale::Estonia:
			if ((countryName = QCoreApplication::translate("country", "Estonia")) == "Estonia") countryName = "";
			break;
		case QLocale::Ethiopia:
			if ((countryName = QCoreApplication::translate("country", "Ethiopia")) == "Ethiopia") countryName = "";
			break;
		case QLocale::FalklandIslands:
			if ((countryName = QCoreApplication::translate("country", "FalklandIslands")) == "FalklandIslands")
				countryName = "";
			break;
		case QLocale::FaroeIslands:
			if ((countryName = QCoreApplication::translate("country", "FaroeIslands")) == "FaroeIslands")
				countryName = "";
			break;
		case QLocale::Fiji:
			if ((countryName = QCoreApplication::translate("country", "Fiji")) == "Fiji") countryName = "";
			break;
		case QLocale::Finland:
			if ((countryName = QCoreApplication::translate("country", "Finland")) == "Finland") countryName = "";
			break;
		case QLocale::France:
			if ((countryName = QCoreApplication::translate("country", "France")) == "France") countryName = "";
			break;
		case QLocale::FrenchGuiana:
			if ((countryName = QCoreApplication::translate("country", "FrenchGuiana")) == "FrenchGuiana")
				countryName = "";
			break;
		case QLocale::FrenchPolynesia:
			if ((countryName = QCoreApplication::translate("country", "FrenchPolynesia")) == "FrenchPolynesia")
				countryName = "";
			break;
		case QLocale::Gabon:
			if ((countryName = QCoreApplication::translate("country", "Gabon")) == "Gabon") countryName = "";
			break;
		case QLocale::Gambia:
			if ((countryName = QCoreApplication::translate("country", "Gambia")) == "Gambia") countryName = "";
			break;
		case QLocale::Georgia:
			if ((countryName = QCoreApplication::translate("country", "Georgia")) == "Georgia") countryName = "";
			break;
		case QLocale::Germany:
			if ((countryName = QCoreApplication::translate("country", "Germany")) == "Germany") countryName = "";
			break;
		case QLocale::Ghana:
			if ((countryName = QCoreApplication::translate("country", "Ghana")) == "Ghana") countryName = "";
			break;
		case QLocale::Gibraltar:
			if ((countryName = QCoreApplication::translate("country", "Gibraltar")) == "Gibraltar") countryName = "";
			break;
		case QLocale::Greece:
			if ((countryName = QCoreApplication::translate("country", "Greece")) == "Greece") countryName = "";
			break;
		case QLocale::Greenland:
			if ((countryName = QCoreApplication::translate("country", "Greenland")) == "Greenland") countryName = "";
			break;
		case QLocale::Grenada:
			if ((countryName = QCoreApplication::translate("country", "Grenada")) == "Grenada") countryName = "";
			break;
		case QLocale::Guadeloupe:
			if ((countryName = QCoreApplication::translate("country", "Guadeloupe")) == "Guadeloupe") countryName = "";
			break;
		case QLocale::Guam:
			if ((countryName = QCoreApplication::translate("country", "Guam")) == "Guam") countryName = "";
			break;
		case QLocale::Guatemala:
			if ((countryName = QCoreApplication::translate("country", "Guatemala")) == "Guatemala") countryName = "";
			break;
		case QLocale::Guinea:
			if ((countryName = QCoreApplication::translate("country", "Guinea")) == "Guinea") countryName = "";
			break;
		case QLocale::GuineaBissau:
			if ((countryName = QCoreApplication::translate("country", "GuineaBissau")) == "GuineaBissau")
				countryName = "";
			break;
		case QLocale::Guyana:
			if ((countryName = QCoreApplication::translate("country", "Guyana")) == "Guyana") countryName = "";
			break;
		case QLocale::Haiti:
			if ((countryName = QCoreApplication::translate("country", "Haiti")) == "Haiti") countryName = "";
			break;
		case QLocale::Honduras:
			if ((countryName = QCoreApplication::translate("country", "Honduras")) == "Honduras") countryName = "";
			break;
		case QLocale::HongKong:
			if ((countryName = QCoreApplication::translate("country", "HongKong")) == "HongKong") countryName = "";
			break;
		case QLocale::Hungary:
			if ((countryName = QCoreApplication::translate("country", "Hungary")) == "Hungary") countryName = "";
			break;
		case QLocale::Iceland:
			if ((countryName = QCoreApplication::translate("country", "Iceland")) == "Iceland") countryName = "";
			break;
		case QLocale::India:
			if ((countryName = QCoreApplication::translate("country", "India")) == "India") countryName = "";
			break;
		case QLocale::Indonesia:
			if ((countryName = QCoreApplication::translate("country", "Indonesia")) == "Indonesia") countryName = "";
			break;
		case QLocale::Iran:
			if ((countryName = QCoreApplication::translate("country", "Iran")) == "Iran") countryName = "";
			break;
		case QLocale::Iraq:
			if ((countryName = QCoreApplication::translate("country", "Iraq")) == "Iraq") countryName = "";
			break;
		case QLocale::Ireland:
			if ((countryName = QCoreApplication::translate("country", "Ireland")) == "Ireland") countryName = "";
			break;
		case QLocale::Israel:
			if ((countryName = QCoreApplication::translate("country", "Israel")) == "Israel") countryName = "";
			break;
		case QLocale::Italy:
			if ((countryName = QCoreApplication::translate("country", "Italy")) == "Italy") countryName = "";
			break;
		case QLocale::Jamaica:
			if ((countryName = QCoreApplication::translate("country", "Jamaica")) == "Jamaica") countryName = "";
			break;
		case QLocale::Japan:
			if ((countryName = QCoreApplication::translate("country", "Japan")) == "Japan") countryName = "";
			break;
		case QLocale::Jordan:
			if ((countryName = QCoreApplication::translate("country", "Jordan")) == "Jordan") countryName = "";
			break;
		case QLocale::Kazakhstan:
			if ((countryName = QCoreApplication::translate("country", "Kazakhstan")) == "Kazakhstan") countryName = "";
			break;
		case QLocale::Kenya:
			if ((countryName = QCoreApplication::translate("country", "Kenya")) == "Kenya") countryName = "";
			break;
		case QLocale::Kiribati:
			if ((countryName = QCoreApplication::translate("country", "Kiribati")) == "Kiribati") countryName = "";
			break;
		case QLocale::DemocraticRepublicOfKorea:
			if ((countryName = QCoreApplication::translate("country", "DemocraticRepublicOfKorea")) ==
			    "DemocraticRepublicOfKorea")
				countryName = "";
			break;
		case QLocale::RepublicOfKorea:
			if ((countryName = QCoreApplication::translate("country", "RepublicOfKorea")) == "RepublicOfKorea")
				countryName = "";
			break;
		case QLocale::Kuwait:
			if ((countryName = QCoreApplication::translate("country", "Kuwait")) == "Kuwait") countryName = "";
			break;
		case QLocale::Kyrgyzstan:
			if ((countryName = QCoreApplication::translate("country", "Kyrgyzstan")) == "Kyrgyzstan") countryName = "";
			break;
		case QLocale::Laos:
			if ((countryName = QCoreApplication::translate("country", "Laos")) == "Laos") countryName = "";
			break;
		case QLocale::Latvia:
			if ((countryName = QCoreApplication::translate("country", "Latvia")) == "Latvia") countryName = "";
			break;
		case QLocale::Lebanon:
			if ((countryName = QCoreApplication::translate("country", "Lebanon")) == "Lebanon") countryName = "";
			break;
		case QLocale::Lesotho:
			if ((countryName = QCoreApplication::translate("country", "Lesotho")) == "Lesotho") countryName = "";
			break;
		case QLocale::Liberia:
			if ((countryName = QCoreApplication::translate("country", "Liberia")) == "Liberia") countryName = "";
			break;
		case QLocale::Libya:
			if ((countryName = QCoreApplication::translate("country", "Libya")) == "Libya") countryName = "";
			break;
		case QLocale::Liechtenstein:
			if ((countryName = QCoreApplication::translate("country", "Liechtenstein")) == "Liechtenstein")
				countryName = "";
			break;
		case QLocale::Lithuania:
			if ((countryName = QCoreApplication::translate("country", "Lithuania")) == "Lithuania") countryName = "";
			break;
		case QLocale::Luxembourg:
			if ((countryName = QCoreApplication::translate("country", "Luxembourg")) == "Luxembourg") countryName = "";
			break;
		case QLocale::Macau:
			if ((countryName = QCoreApplication::translate("country", "Macau")) == "Macau") countryName = "";
			break;
		case QLocale::Macedonia:
			if ((countryName = QCoreApplication::translate("country", "Macedonia")) == "Macedonia") countryName = "";
			break;
		case QLocale::Madagascar:
			if ((countryName = QCoreApplication::translate("country", "Madagascar")) == "Madagascar") countryName = "";
			break;
		case QLocale::Malawi:
			if ((countryName = QCoreApplication::translate("country", "Malawi")) == "Malawi") countryName = "";
			break;
		case QLocale::Malaysia:
			if ((countryName = QCoreApplication::translate("country", "Malaysia")) == "Malaysia") countryName = "";
			break;
		case QLocale::Maldives:
			if ((countryName = QCoreApplication::translate("country", "Maldives")) == "Maldives") countryName = "";
			break;
		case QLocale::Mali:
			if ((countryName = QCoreApplication::translate("country", "Mali")) == "Mali") countryName = "";
			break;
		case QLocale::Malta:
			if ((countryName = QCoreApplication::translate("country", "Malta")) == "Malta") countryName = "";
			break;
		case QLocale::MarshallIslands:
			if ((countryName = QCoreApplication::translate("country", "MarshallIslands")) == "MarshallIslands")
				countryName = "";
			break;
		case QLocale::Martinique:
			if ((countryName = QCoreApplication::translate("country", "Martinique")) == "Martinique") countryName = "";
			break;
		case QLocale::Mauritania:
			if ((countryName = QCoreApplication::translate("country", "Mauritania")) == "Mauritania") countryName = "";
			break;
		case QLocale::Mauritius:
			if ((countryName = QCoreApplication::translate("country", "Mauritius")) == "Mauritius") countryName = "";
			break;
		case QLocale::Mayotte:
			if ((countryName = QCoreApplication::translate("country", "Mayotte")) == "Mayotte") countryName = "";
			break;
		case QLocale::Mexico:
			if ((countryName = QCoreApplication::translate("country", "Mexico")) == "Mexico") countryName = "";
			break;
		case QLocale::Micronesia:
			if ((countryName = QCoreApplication::translate("country", "Micronesia")) == "Micronesia") countryName = "";
			break;
		case QLocale::Moldova:
			if ((countryName = QCoreApplication::translate("country", "Moldova")) == "Moldova") countryName = "";
			break;
		case QLocale::Monaco:
			if ((countryName = QCoreApplication::translate("country", "Monaco")) == "Monaco") countryName = "";
			break;
		case QLocale::Mongolia:
			if ((countryName = QCoreApplication::translate("country", "Mongolia")) == "Mongolia") countryName = "";
			break;
		case QLocale::Montenegro:
			if ((countryName = QCoreApplication::translate("country", "Montenegro")) == "Montenegro") countryName = "";
			break;
		case QLocale::Montserrat:
			if ((countryName = QCoreApplication::translate("country", "Montserrat")) == "Montserrat") countryName = "";
			break;
		case QLocale::Morocco:
			if ((countryName = QCoreApplication::translate("country", "Morocco")) == "Morocco") countryName = "";
			break;
		case QLocale::Mozambique:
			if ((countryName = QCoreApplication::translate("country", "Mozambique")) == "Mozambique") countryName = "";
			break;
		case QLocale::Myanmar:
			if ((countryName = QCoreApplication::translate("country", "Myanmar")) == "Myanmar") countryName = "";
			break;
		case QLocale::Namibia:
			if ((countryName = QCoreApplication::translate("country", "Namibia")) == "Namibia") countryName = "";
			break;
		case QLocale::NauruCountry:
			if ((countryName = QCoreApplication::translate("country", "NauruCountry")) == "NauruCountry")
				countryName = "";
			break;
		case QLocale::Nepal:
			if ((countryName = QCoreApplication::translate("country", "Nepal")) == "Nepal") countryName = "";
			break;
		case QLocale::Netherlands:
			if ((countryName = QCoreApplication::translate("country", "Netherlands")) == "Netherlands")
				countryName = "";
			break;
		case QLocale::NewCaledonia:
			if ((countryName = QCoreApplication::translate("country", "NewCaledonia")) == "NewCaledonia")
				countryName = "";
			break;
		case QLocale::NewZealand:
			if ((countryName = QCoreApplication::translate("country", "NewZealand")) == "NewZealand") countryName = "";
			break;
		case QLocale::Nicaragua:
			if ((countryName = QCoreApplication::translate("country", "Nicaragua")) == "Nicaragua") countryName = "";
			break;
		case QLocale::Niger:
			if ((countryName = QCoreApplication::translate("country", "Niger")) == "Niger") countryName = "";
			break;
		case QLocale::Nigeria:
			if ((countryName = QCoreApplication::translate("country", "Nigeria")) == "Nigeria") countryName = "";
			break;
		case QLocale::Niue:
			if ((countryName = QCoreApplication::translate("country", "Niue")) == "Niue") countryName = "";
			break;
		case QLocale::NorfolkIsland:
			if ((countryName = QCoreApplication::translate("country", "NorfolkIsland")) == "NorfolkIsland")
				countryName = "";
			break;
		case QLocale::NorthernMarianaIslands:
			if ((countryName = QCoreApplication::translate("country", "NorthernMarianaIslands")) ==
			    "NorthernMarianaIslands")
				countryName = "";
			break;
		case QLocale::Norway:
			if ((countryName = QCoreApplication::translate("country", "Norway")) == "Norway") countryName = "";
			break;
		case QLocale::Oman:
			if ((countryName = QCoreApplication::translate("country", "Oman")) == "Oman") countryName = "";
			break;
		case QLocale::Pakistan:
			if ((countryName = QCoreApplication::translate("country", "Pakistan")) == "Pakistan") countryName = "";
			break;
		case QLocale::Palau:
			if ((countryName = QCoreApplication::translate("country", "Palau")) == "Palau") countryName = "";
			break;
		case QLocale::PalestinianTerritories:
			if ((countryName = QCoreApplication::translate("country", "PalestinianTerritories")) ==
			    "PalestinianTerritories")
				countryName = "";
			break;
		case QLocale::Panama:
			if ((countryName = QCoreApplication::translate("country", "Panama")) == "Panama") countryName = "";
			break;
		case QLocale::PapuaNewGuinea:
			if ((countryName = QCoreApplication::translate("country", "PapuaNewGuinea")) == "PapuaNewGuinea")
				countryName = "";
			break;
		case QLocale::Paraguay:
			if ((countryName = QCoreApplication::translate("country", "Paraguay")) == "Paraguay") countryName = "";
			break;
		case QLocale::Peru:
			if ((countryName = QCoreApplication::translate("country", "Peru")) == "Peru") countryName = "";
			break;
		case QLocale::Philippines:
			if ((countryName = QCoreApplication::translate("country", "Philippines")) == "Philippines")
				countryName = "";
			break;
		case QLocale::Poland:
			if ((countryName = QCoreApplication::translate("country", "Poland")) == "Poland") countryName = "";
			break;
		case QLocale::Portugal:
			if ((countryName = QCoreApplication::translate("country", "Portugal")) == "Portugal") countryName = "";
			break;
		case QLocale::PuertoRico:
			if ((countryName = QCoreApplication::translate("country", "PuertoRico")) == "PuertoRico") countryName = "";
			break;
		case QLocale::Qatar:
			if ((countryName = QCoreApplication::translate("country", "Qatar")) == "Qatar") countryName = "";
			break;
		case QLocale::Reunion:
			if ((countryName = QCoreApplication::translate("country", "Reunion")) == "Reunion") countryName = "";
			break;
		case QLocale::Romania:
			if ((countryName = QCoreApplication::translate("country", "Romania")) == "Romania") countryName = "";
			break;
		case QLocale::RussianFederation:
			if ((countryName = QCoreApplication::translate("country", "RussianFederation")) == "RussianFederation")
				countryName = "";
			break;
		case QLocale::Rwanda:
			if ((countryName = QCoreApplication::translate("country", "Rwanda")) == "Rwanda") countryName = "";
			break;
		case QLocale::SaintHelena:
			if ((countryName = QCoreApplication::translate("country", "SaintHelena")) == "SaintHelena")
				countryName = "";
			break;
		case QLocale::SaintKittsAndNevis:
			if ((countryName = QCoreApplication::translate("country", "SaintKittsAndNevis")) == "SaintKittsAndNevis")
				countryName = "";
			break;
		case QLocale::SaintLucia:
			if ((countryName = QCoreApplication::translate("country", "SaintLucia")) == "SaintLucia") countryName = "";
			break;
		case QLocale::SaintPierreAndMiquelon:
			if ((countryName = QCoreApplication::translate("country", "SaintPierreAndMiquelon")) ==
			    "SaintPierreAndMiquelon")
				countryName = "";
			break;
		case QLocale::SaintVincentAndTheGrenadines:
			if ((countryName = QCoreApplication::translate("country", "SaintVincentAndTheGrenadines")) ==
			    "SaintVincentAndTheGrenadines")
				countryName = "";
			break;
		case QLocale::Samoa:
			if ((countryName = QCoreApplication::translate("country", "Samoa")) == "Samoa") countryName = "";
			break;
		case QLocale::SanMarino:
			if ((countryName = QCoreApplication::translate("country", "SanMarino")) == "SanMarino") countryName = "";
			break;
		case QLocale::SaoTomeAndPrincipe:
			if ((countryName = QCoreApplication::translate("country", "SaoTomeAndPrincipe")) == "SaoTomeAndPrincipe")
				countryName = "";
			break;
		case QLocale::SaudiArabia:
			if ((countryName = QCoreApplication::translate("country", "SaudiArabia")) == "SaudiArabia")
				countryName = "";
			break;
		case QLocale::Senegal:
			if ((countryName = QCoreApplication::translate("country", "Senegal")) == "Senegal") countryName = "";
			break;
		case QLocale::Serbia:
			if ((countryName = QCoreApplication::translate("country", "Serbia")) == "Serbia") countryName = "";
			break;
		case QLocale::Seychelles:
			if ((countryName = QCoreApplication::translate("country", "Seychelles")) == "Seychelles") countryName = "";
			break;
		case QLocale::SierraLeone:
			if ((countryName = QCoreApplication::translate("country", "SierraLeone")) == "SierraLeone")
				countryName = "";
			break;
		case QLocale::Singapore:
			if ((countryName = QCoreApplication::translate("country", "Singapore")) == "Singapore") countryName = "";
			break;
		case QLocale::Slovakia:
			if ((countryName = QCoreApplication::translate("country", "Slovakia")) == "Slovakia") countryName = "";
			break;
		case QLocale::Slovenia:
			if ((countryName = QCoreApplication::translate("country", "Slovenia")) == "Slovenia") countryName = "";
			break;
		case QLocale::SolomonIslands:
			if ((countryName = QCoreApplication::translate("country", "SolomonIslands")) == "SolomonIslands")
				countryName = "";
			break;
		case QLocale::Somalia:
			if ((countryName = QCoreApplication::translate("country", "Somalia")) == "Somalia") countryName = "";
			break;
		case QLocale::SouthAfrica:
			if ((countryName = QCoreApplication::translate("country", "SouthAfrica")) == "SouthAfrica")
				countryName = "";
			break;
		case QLocale::Spain:
			if ((countryName = QCoreApplication::translate("country", "Spain")) == "Spain") countryName = "";
			break;
		case QLocale::SriLanka:
			if ((countryName = QCoreApplication::translate("country", "SriLanka")) == "SriLanka") countryName = "";
			break;
		case QLocale::Sudan:
			if ((countryName = QCoreApplication::translate("country", "Sudan")) == "Sudan") countryName = "";
			break;
		case QLocale::Suriname:
			if ((countryName = QCoreApplication::translate("country", "Suriname")) == "Suriname") countryName = "";
			break;
		case QLocale::Swaziland:
			if ((countryName = QCoreApplication::translate("country", "Swaziland")) == "Swaziland") countryName = "";
			break;
		case QLocale::Sweden:
			if ((countryName = QCoreApplication::translate("country", "Sweden")) == "Sweden") countryName = "";
			break;
		case QLocale::Switzerland:
			if ((countryName = QCoreApplication::translate("country", "Switzerland")) == "Switzerland")
				countryName = "";
			break;
		case QLocale::Syria:
			if ((countryName = QCoreApplication::translate("country", "Syria")) == "Syria") countryName = "";
			break;
		case QLocale::Taiwan:
			if ((countryName = QCoreApplication::translate("country", "Taiwan")) == "Taiwan") countryName = "";
			break;
		case QLocale::Tajikistan:
			if ((countryName = QCoreApplication::translate("country", "Tajikistan")) == "Tajikistan") countryName = "";
			break;
		case QLocale::Tanzania:
			if ((countryName = QCoreApplication::translate("country", "Tanzania")) == "Tanzania") countryName = "";
			break;
		case QLocale::Thailand:
			if ((countryName = QCoreApplication::translate("country", "Thailand")) == "Thailand") countryName = "";
			break;
		case QLocale::Togo:
			if ((countryName = QCoreApplication::translate("country", "Togo")) == "Togo") countryName = "";
			break;
		case QLocale::TokelauCountry:
			if ((countryName = QCoreApplication::translate("country", "Tokelau")) == "Tokelau") countryName = "";
			break;
		case QLocale::Tonga:
			if ((countryName = QCoreApplication::translate("country", "Tonga")) == "Tonga") countryName = "";
			break;
		case QLocale::TrinidadAndTobago:
			if ((countryName = QCoreApplication::translate("country", "TrinidadAndTobago")) == "TrinidadAndTobago")
				countryName = "";
			break;
		case QLocale::Tunisia:
			if ((countryName = QCoreApplication::translate("country", "Tunisia")) == "Tunisia") countryName = "";
			break;
		case QLocale::Turkey:
			if ((countryName = QCoreApplication::translate("country", "Turkey")) == "Turkey") countryName = "";
			break;
		case QLocale::Turkmenistan:
			if ((countryName = QCoreApplication::translate("country", "Turkmenistan")) == "Turkmenistan")
				countryName = "";
			break;
		case QLocale::TurksAndCaicosIslands:
			if ((countryName = QCoreApplication::translate("country", "TurksAndCaicosIslands")) ==
			    "TurksAndCaicosIslands")
				countryName = "";
			break;
		case QLocale::TuvaluCountry:
			if ((countryName = QCoreApplication::translate("country", "Tuvalu")) == "Tuvalu") countryName = "";
			break;
		case QLocale::Uganda:
			if ((countryName = QCoreApplication::translate("country", "Uganda")) == "Uganda") countryName = "";
			break;
		case QLocale::Ukraine:
			if ((countryName = QCoreApplication::translate("country", "Ukraine")) == "Ukraine") countryName = "";
			break;
		case QLocale::UnitedArabEmirates:
			if ((countryName = QCoreApplication::translate("country", "UnitedArabEmirates")) == "UnitedArabEmirates")
				countryName = "";
			break;
		case QLocale::UnitedKingdom:
			if ((countryName = QCoreApplication::translate("country", "UnitedKingdom")) == "UnitedKingdom")
				countryName = "";
			break;
		case QLocale::UnitedStates:
			if ((countryName = QCoreApplication::translate("country", "UnitedStates")) == "UnitedStates")
				countryName = "";
			break;
		case QLocale::Uruguay:
			if ((countryName = QCoreApplication::translate("country", "Uruguay")) == "Uruguay") countryName = "";
			break;
		case QLocale::Uzbekistan:
			if ((countryName = QCoreApplication::translate("country", "Uzbekistan")) == "Uzbekistan") countryName = "";
			break;
		case QLocale::Vanuatu:
			if ((countryName = QCoreApplication::translate("country", "Vanuatu")) == "Vanuatu") countryName = "";
			break;
		case QLocale::Venezuela:
			if ((countryName = QCoreApplication::translate("country", "Venezuela")) == "Venezuela") countryName = "";
			break;
		case QLocale::Vietnam:
			if ((countryName = QCoreApplication::translate("country", "Vietnam")) == "Vietnam") countryName = "";
			break;
		case QLocale::WallisAndFutunaIslands:
			if ((countryName = QCoreApplication::translate("country", "WallisAndFutunaIslands")) ==
			    "WallisAndFutunaIslands")
				countryName = "";
			break;
		case QLocale::Yemen:
			if ((countryName = QCoreApplication::translate("country", "Yemen")) == "Yemen") countryName = "";
			break;
		case QLocale::Zambia:
			if ((countryName = QCoreApplication::translate("country", "Zambia")) == "Zambia") countryName = "";
			break;
		case QLocale::Zimbabwe:
			if ((countryName = QCoreApplication::translate("country", "Zimbabwe")) == "Zimbabwe") countryName = "";
			break;
		default: {
			countryName = QLocale::territoryToString(p_country);
		}
	}
	if (countryName == "") countryName = QLocale::territoryToString(p_country);
	return countryName;
}
QString Utils::toDateString(QDateTime date, const QString &format) {
	return QLocale().toString(date, (!format.isEmpty() ? format : "ddd d MMMM yyyy"));
}

QString Utils::toDateString(QDate date, const QString &format) {
	return QLocale().toString(date, (!format.isEmpty() ? format : "ddd d, MMMM"));
}

QString Utils::toDateDayString(const QDateTime &date) {
	auto res = QLocale().toString(date, "d");
	return res;
}

QString Utils::toDateHourString(const QDateTime &date) {
	return QLocale().toString(date, "hh:mm");
}

QString Utils::toDateDayNameString(const QDateTime &date) {
	return QLocale().toString(date, "ddd");
}

QString Utils::toDateMonthString(const QDateTime &date) {
	return QLocale().toString(date, "MMMM");
}

QString Utils::toDateMonthAndYearString(const QDateTime &date) {
	return QLocale().toString(date, "MMMM yyyy");
}

bool Utils::isCurrentDay(QDateTime date) {
	auto dateDayNum = date.date().day();
	auto currentDate = QDateTime::currentDateTime(date.timeZone());
	auto currentDayNum = currentDate.date().day();
	auto daysTo = date.daysTo(currentDate);
	return (dateDayNum == currentDayNum && daysTo == 0);
}

bool Utils::isCurrentDay(QDate date) {
	auto currentDate = QDate::currentDate();
	return date.month() == currentDate.month() && date.year() == currentDate.year() && date.day() == currentDate.day();
}

bool Utils::isCurrentMonth(QDate date) {
	auto currentDate = QDate::currentDate();
	return date.month() == currentDate.month() && date.year() == currentDate.year();
}

bool Utils::datesAreEqual(const QDate &a, const QDate &b) {
	return a.month() == b.month() && a.year() == b.year() && a.day() == b.day();
}

bool Utils::dateisInMonth(const QDate &a, int month, int year) {
	return a.month() == month && a.year() == year;
}

QDateTime Utils::createDateTime(const QDate &date, int hour, int min) {
	QTime time(hour, min);
	return QDateTime(date, time, QTimeZone::systemTimeZone());
}

QDateTime Utils::getCurrentDateTime() {
	return QDateTime::currentDateTime(QTimeZone::systemTimeZone());
}

QDateTime Utils::getCurrentDateTimeUtc() {
	return QDateTime::currentDateTimeUtc();
}

int Utils::secsTo(const QString &startTime, const QString &endTime) {
	QDateTime startDate(QDateTime::fromString(startTime, "hh:mm"));
	QDateTime endDate(QDateTime::fromString(endTime, "hh:mm"));
	auto res = startDate.secsTo(endDate);
	return res;
}

QDateTime Utils::addSecs(QDateTime date, int secs) {
	date = date.addSecs(secs);
	return date;
}

QDateTime Utils::addYears(QDateTime date, int years) {
	date = date.addYears(years);
	return date;
}

int Utils::timeOffset(QDateTime start, QDateTime end) {
	int offset = start.secsTo(end);
	return std::min(offset, INT_MAX);
}

int Utils::daysOffset(QDateTime start, QDateTime end) {
	int offset = start.daysTo(end);
	return std::min(offset, INT_MAX);
}

int Utils::getYear(const QDate &date) {
	return date.year();
}

VariantObject *Utils::isMe(const QString &address) {
	VariantObject *data = new VariantObject("isMe", QVariant(false));
	if (!data) return nullptr;
	data->makeRequest([address]() { return QVariant::fromValue(ToolModel::isMe(address)); });
	data->requestValue();
	return data;
}
VariantObject *Utils::isLocal(const QString &address) {
	VariantObject *data = new VariantObject("isLocal", QVariant(false));
	data->makeRequest([address]() { return QVariant(ToolModel::isLocal(address)); });
	data->requestValue();
	return data;
}

bool Utils::isUsername(const QString &txt) {
	QRegularExpression regex("^(<?sips?:)?[a-zA-Z0-9+_.\\-]+>?$");
	QRegularExpressionMatch match = regex.match(txt);
	return match.hasMatch(); // true
}
// QDateTime dateTime(QDateTime::fromString(date, "yyyy-MM-dd hh:mm:ss"));

// bool Utils::isMe(const QString &address) {
// 	return !address.isEmpty() ? isMe(ToolModel::interpretUrl(address)) : false;
// }
void Utils::useFetchConfig(const QString &configUrl) {
	App::getInstance()->receivedMessage(0, ("fetch-config=" + configUrl).toLocal8Bit());
}

void Utils::playDtmf(const QString &dtmf) {
	const char key = dtmf.constData()[0].toLatin1();
	App::postModelSync([key]() { CoreModel::getInstance()->getCore()->playDtmf(key, 200); });
}

bool Utils::isInteger(const QString &text) {
	QRegularExpression re(QRegularExpression::anchoredPattern("\\d+"));
	if (re.match(text).hasMatch()) {
		return true;
	}
	return false;
}

QString Utils::boldTextPart(const QString &text, const QString &regex) {
	int regexIndex = text.indexOf(regex, 0, Qt::CaseInsensitive);
	if (regex.isEmpty() || regexIndex == -1) return text;
	QString result;
	QStringList splittedText = text.split(regex, Qt::KeepEmptyParts, Qt::CaseInsensitive);
	for (int i = 0; i < splittedText.size() - 1; ++i) {
		result.append(splittedText[i]);
		result.append("<b>" + regex + "</b>");
	}
	if (splittedText.size() > 0) result.append(splittedText[splittedText.size() - 1]);
	return result;
}

QString Utils::getFileChecksum(const QString &filePath) {
	QFile file(filePath);
	if (file.open(QFile::ReadOnly)) {
		QCryptographicHash hash(QCryptographicHash::Sha256);
		if (hash.addData(&file)) {
			return hash.result().toHex();
		}
	}
	return QString();
}

QList<QVariant> Utils::append(const QList<QVariant> a, const QList<QVariant> b) {
	return a + b;
}

QString Utils::getAddressToDisplay(QVariantList addressList, QString filter, QString defaultAddress) {
	if (filter.isEmpty()) return defaultAddress;
	for (auto &item : addressList) {
		QString address = item.toMap()["address"].toString();
		if (address.contains(filter)) return address;
	}
	return defaultAddress;
}

// Codecs download

QList<QSharedPointer<DownloadablePayloadTypeCore>> Utils::getDownloadableVideoPayloadTypes() {
	QList<QSharedPointer<DownloadablePayloadTypeCore>> payloadTypes;
#if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
	auto ciscoH264 = DownloadablePayloadTypeCore::create(PayloadTypeCore::Family::Video, "H264",
	                                                     Constants::H264Description, Constants::PluginUrlH264,
	                                                     Constants::H264InstallName, Constants::PluginH264Check);
	payloadTypes.push_back(ciscoH264);
#endif
	return payloadTypes;
}

void Utils::checkDownloadedCodecsUpdates() {
	for (auto codec : getDownloadableVideoPayloadTypes()) {
		if (codec->shouldDownloadUpdate()) App::postCoreAsync([codec]() { codec->downloadAndExtract(true); });
	}
}

// VARIANT CREATORS

QVariantMap Utils::createDeviceVariant(const QString &id, const QString &name) {
	QVariantMap map;
	map.insert("id", id);
	map.insert("name", name);
	return map;
}

QVariantMap Utils::createDialPlanVariant(QString flag, QString text) {
	QVariantMap m;
	m["flag"] = flag;
	m["text"] = text;
	return m;
}

QVariantMap Utils::createFriendAddressVariant(const QString &label, const QString &address) {
	QVariantMap map;
	map.insert("label", label);
	map.insert("address", address);
	return map;
}

QVariantMap
Utils::createFriendDeviceVariant(const QString &name, const QString &address, LinphoneEnums::SecurityLevel level) {
	QVariantMap map;
	map.insert("name", name);
	map.insert("address", address);
	map.insert("securityLevel", QVariant::fromValue(level));
	return map;
}

VariantObject *Utils::getCurrentCallChat(CallGui *call) {
	VariantObject *data = new VariantObject("lookupCurrentCallChat");
	if (!data) return nullptr;
	if (!call || !call->mCore) return nullptr;
	data->makeRequest([callModel = call->mCore->getModel(), data]() {
		if (!callModel) return QVariant();
		auto linphoneChatRoom = ToolModel::lookupCurrentCallChat(callModel);
		if (linphoneChatRoom) {
			auto chatCore = ChatCore::create(linphoneChatRoom);
			return QVariant::fromValue(new ChatGui(chatCore));
		} else {
			qDebug() << "Did not find existing chat room, create one";
			linphoneChatRoom = ToolModel::createCurrentCallChat(callModel);
			if (linphoneChatRoom != nullptr) {
				qDebug() << "Chatroom created with" << callModel->getRemoteAddress()->asStringUriOnly();
				auto id = linphoneChatRoom->getIdentifier();
				auto chatCore = ChatCore::create(linphoneChatRoom);
				return QVariant::fromValue(new ChatGui(chatCore));
			} else {
				qWarning() << "Failed to create 1-1 conversation with"
				           << callModel->getRemoteAddress()->asStringUriOnly() << "!";
				data->mConnection->invokeToCore([] {
					//: Error
					showInformationPopup(tr("information_popup_error_title"),
					                     //: Failed to create 1-1 conversation with %1 !
					                     tr("information_popup_chatroom_creation_error_message"), false,
					                     getCallsWindow());
				});
				return QVariant();
			}
		}
	});
	data->requestValue();
	return data;
}

VariantObject *Utils::getChatForAddress(QString address) {
	VariantObject *data = new VariantObject("lookupCurrentCallChat");
	if (!data) return nullptr;
	data->makeRequest([address, data]() {
		auto linAddr = ToolModel::interpretUrl(address);
		if (!linAddr) return QVariant();
		linAddr->clean();
		auto linphoneChatRoom = ToolModel::lookupChatForAddress(linAddr);
		if (linphoneChatRoom) {
			auto chatCore = ChatCore::create(linphoneChatRoom);
			return QVariant::fromValue(new ChatGui(chatCore));
		} else {
			qDebug() << "Did not find existing chat room, create one";
			linphoneChatRoom = ToolModel::createChatForAddress(linAddr);
			if (linphoneChatRoom != nullptr) {
				qDebug() << "Chatroom created with" << linAddr->asStringUriOnly();
				auto chatCore = ChatCore::create(linphoneChatRoom);
				return QVariant::fromValue(new ChatGui(chatCore));
			} else {
				qWarning() << "Failed to create 1-1 conversation with" << linAddr->asStringUriOnly() << "!";
				//: Failed to create 1-1 conversation with %1 !
				data->mConnection->invokeToCore([] {
					showInformationPopup(tr("information_popup_error_title"),
					                     tr("information_popup_chatroom_creation_error_message"), false,
					                     getCallsWindow());
				});
				return QVariant();
			}
		}
	});
	data->requestValue();
	return data;
}

VariantObject *Utils::createGroupChat(QString subject, QStringList participantAddresses) {
	VariantObject *data = new VariantObject("lookupCurrentCallChat");
	if (!data) return nullptr;
	data->makeRequest([subject, participantAddresses, data]() {
		std::list<std::shared_ptr<linphone::Address>> addresses;
		for (auto &addr : participantAddresses) {
			auto linAddr = ToolModel::interpretUrl(addr);
			if (linAddr) addresses.push_back(linAddr);
			else lWarning() << "Could not interpret address" << addr;
		}
		auto linphoneChatRoom = ToolModel::createGroupChatRoom(subject, addresses);
		if (linphoneChatRoom) {
			auto chatCore = ChatCore::create(linphoneChatRoom);
			return QVariant::fromValue(new ChatGui(chatCore));
		} else {
			return QVariant();
		}
	});
	data->requestValue();
	return data;
}

void Utils::openChat(ChatGui *chat) {
	auto mainWindow = getMainWindow();
	smartShowWindow(mainWindow);
	if (mainWindow && chat) {
		emit chat->mCore->messageOpen();
		auto localChatAccount = chat->mCore->getLocalAccount();
		auto accountList = App::getInstance()->getAccountList();
		auto defaultAccount = accountList->getDefaultAccountCore();
		// If multiple accounts, we must switch to the correct account before opening the chatroom, otherwise,
		// a chat room corresponding to the wrong account could be added in the chat list
		if (localChatAccount && localChatAccount->getIdentityAddress() != defaultAccount->getIdentityAddress()) {
			connect(accountList.get(), &AccountList::defaultAccountChanged, accountList.get(),
			        [localChatAccount, accountList, chat] {
				        auto defaultAccount = accountList->getDefaultAccountCore();
				        if (defaultAccount->getIdentityAddress() == localChatAccount->getIdentityAddress()) {
					        disconnect(accountList.get(), &AccountList::defaultAccountChanged, accountList.get(),
					                   nullptr);
					        QMetaObject::invokeMethod(getMainWindow(), "openChat",
					                                  Q_ARG(QVariant, QVariant::fromValue(chat)));
				        }
			        });
			localChatAccount->lSetDefaultAccount();
		} else QMetaObject::invokeMethod(mainWindow, "openChat", Q_ARG(QVariant, QVariant::fromValue(chat)));
	}
}

bool Utils::isEmptyMessage(QString message) {
	return message.trimmed().isEmpty();
}

// CLI

void Utils::runCommandLine(const QString command) {
	QStringList arguments;
	QString program;

#ifdef Q_OS_WIN
	std::wstring fullCommand = std::wstring(L"cmd.exe /C ") + command.toStdWString();
	STARTUPINFOW si;
	PROCESS_INFORMATION pi;
	ZeroMemory(&si, sizeof(si));
	ZeroMemory(&pi, sizeof(pi));
	si.cb = sizeof(si);
	si.dwFlags = STARTF_USESHOWWINDOW;
	si.wShowWindow = SW_HIDE;

	BOOL success = CreateProcessW(nullptr,            // Application name
	                              fullCommand.data(), // Command line (mutable)
	                              nullptr,            // Process security attributes
	                              nullptr,            // Primary thread security attributes
	                              FALSE,              // Inherit handles
	                              CREATE_NO_WINDOW,   // Creation flags (hide window)
	                              nullptr,            // Environment
	                              nullptr,            // Current directory
	                              &si,                // STARTUPINFO
	                              &pi                 // PROCESS_INFORMATION
	);

	if (success) {
		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
	} else {
		lWarning() << "Failed to start process. GetLastError() =" << (int)GetLastError();
	}
#elif defined(Q_OS_MACOS) || defined(Q_OS_LINUX)
	QProcess::startDetached("/bin/sh", {"-c", command});
#else
	lWarning() << "Unsupported OS!";
#endif
}

// Presence

QColor Utils::getDefaultStyleColor(const QString &colorName) {
	mustBeInMainThread(sLog().arg(Q_FUNC_INFO));
	static QObject *defaultStyleSingleton = nullptr;
	if (!defaultStyleSingleton) {
		QQmlComponent component(App::getInstance()->mEngine, QUrl("qrc:/qt/qml/Linphone/view/Style/DefaultStyle.qml"));
		defaultStyleSingleton = component.create();
	}
	return QQmlProperty::read(defaultStyleSingleton, colorName).value<QColor>();
}

QUrl Utils::getAppIcon(const QString &iconName) {
	static QObject *appIconsSingleton = nullptr;
	if (!appIconsSingleton) {
		QQmlComponent component(App::getInstance()->mEngine, QUrl("qrc:/qt/qml/Linphone/view/Style/AppIcons.qml"));
		appIconsSingleton = component.create();
	}
	return QQmlProperty::read(appIconsSingleton, iconName).value<QUrl>();
}

QColor Utils::getPresenceColor(LinphoneEnums::Presence presence) {
	mustBeInMainThread(sLog().arg(Q_FUNC_INFO));
	QColor presenceColor = QColorConstants::Transparent;
	switch (presence) {
		case LinphoneEnums::Presence::Online:
			presenceColor = Utils::getDefaultStyleColor("success_500_main");
			break;
		case LinphoneEnums::Presence::Away:
			presenceColor = Utils::getDefaultStyleColor("warning_500_main");
			break;
		case LinphoneEnums::Presence::Busy:
			presenceColor = Utils::getDefaultStyleColor("danger_500_main");
			break;
		case LinphoneEnums::Presence::DoNotDisturb:
			presenceColor = Utils::getDefaultStyleColor("danger_500_main");
			break;
		case LinphoneEnums::Presence::Offline:
			presenceColor = Utils::getDefaultStyleColor("main2_600");
			break;
		case LinphoneEnums::Presence::Undefined:
			presenceColor = Utils::getDefaultStyleColor("transparent");
			break;
	}
	return presenceColor;
}

QUrl Utils::getPresenceIcon(LinphoneEnums::Presence presence) {
	mustBeInMainThread(sLog().arg(Q_FUNC_INFO));
	QUrl presenceIcon;
	switch (presence) {
		case LinphoneEnums::Presence::Online:
			presenceIcon = Utils::getAppIcon("presenceOnline");
			break;
		case LinphoneEnums::Presence::Away:
			presenceIcon = Utils::getAppIcon("presenceAway");
			break;
		case LinphoneEnums::Presence::Busy:
			presenceIcon = Utils::getAppIcon("presenceBusy");
			break;
		case LinphoneEnums::Presence::DoNotDisturb:
			presenceIcon = Utils::getAppIcon("presenceDoNotDisturb");
			break;
		case LinphoneEnums::Presence::Offline:
			presenceIcon = Utils::getAppIcon("presenceOffline");
			break;
		case LinphoneEnums::Presence::Undefined:
			presenceIcon = QUrl("");
			break;
	}
	return presenceIcon;
}

QUrl Utils::getRegistrationStateIcon(LinphoneEnums::RegistrationState state) {
	mustBeInMainThread(sLog().arg(Q_FUNC_INFO));
	QUrl registrationStateIcon;
	switch (state) {
		case LinphoneEnums::RegistrationState::Refreshing:
			registrationStateIcon = Utils::getAppIcon("registrationProgress");
			break;
		case LinphoneEnums::RegistrationState::Progress:
			registrationStateIcon = Utils::getAppIcon("registrationProgress");
			break;
		case LinphoneEnums::RegistrationState::Failed:
			registrationStateIcon = Utils::getAppIcon("registrationError");
			break;
		case LinphoneEnums::RegistrationState::Cleared:
			registrationStateIcon = Utils::getAppIcon("registrationDeactivated");
			break;
		case LinphoneEnums::RegistrationState::None:
			registrationStateIcon = Utils::getAppIcon("registrationDeactivated");
			break;
		default:
			registrationStateIcon = QUrl();
	}
	return registrationStateIcon;
}

QString Utils::getPresenceStatus(LinphoneEnums::Presence presence) {
	mustBeInMainThread(sLog().arg(Q_FUNC_INFO));
	QString presenceStatus = "";
	switch (presence) {
		case LinphoneEnums::Presence::Online:
			presenceStatus = tr("contact_presence_status_available");
			break;
		case LinphoneEnums::Presence::Away:
			presenceStatus = tr("contact_presence_status_away");
			break;
		case LinphoneEnums::Presence::Busy:
			presenceStatus = tr("contact_presence_status_busy");
			break;
		case LinphoneEnums::Presence::DoNotDisturb:
			presenceStatus = tr("contact_presence_status_do_not_disturb");
			break;
		case LinphoneEnums::Presence::Offline:
			presenceStatus = tr("contact_presence_status_offline");
			break;
		case LinphoneEnums::Presence::Undefined:
			presenceStatus = "";
			break;
	}
	return presenceStatus;
}

VariantObject *Utils::encodeTextToQmlRichFormat(const QString &text, const QVariantMap &options, ChatGui *chat) {
	/*QString images;
	QStringList imageFormat;
	for(auto format : QImageReader::supportedImageFormats())
	    imageFormat.append(QString::fromLatin1(format).toUpper());
	    */
	VariantObject *data = new VariantObject("encodeTextToQmlRichFormat");
	if (!data) return nullptr;
	auto primaryColor = getDefaultStyleColor("info_500_main");
	data->makeRequest([text, options, chat, primaryColor] {
		QStringList formattedText;
		bool lastWasUrl = false;

		if (options.contains("noLink") && options["noLink"].toBool()) {
			formattedText.append(encodeEmojiToQmlRichFormat(text));
		} else {

			auto iriParsed = UriTools::parseIri(text);

			for (int i = 0; i < iriParsed.size(); ++i) {
				QString iri = iriParsed[i]
				                  .second.replace('&', "&amp;")
				                  .replace('<', "\u2063&lt;")
				                  .replace('>', "\u2063&gt;")
				                  .replace('"', "&quot;")
				                  .replace('\'', "&#039;");
				if (!iriParsed[i].first) {
					if (lastWasUrl) {
						lastWasUrl = false;
						if (iri.front() != ' ') iri.push_front(' ');
					}
					formattedText.append(encodeEmojiToQmlRichFormat(iri));
				} else {
					QString uri =
					    iriParsed[i].second.left(3) == "www" ? "http://" + iriParsed[i].second : iriParsed[i].second;
					/* TODO : preview from link
					int extIndex = iriParsed[i].second.lastIndexOf('.');
					QString ext;
					if( extIndex >= 0)
					    ext = iriParsed[i].second.mid(extIndex+1).toUpper();
					if(imageFormat.contains(ext.toLatin1())){// imagesHeight is not used because of bugs on display
					(blank image if set without width) images += "<a href=\"" + uri + "\"><img" + (
					options.contains("imagesWidth") ? QString(" width='") + options["imagesWidth"].toString() + "'" : ""
					        ) + (
					            options.contains("imagesWidth")
					            ? QString(" height='auto'")
					            : ""
					        ) + " src=\"" + iriParsed[i].second + "\" />"+uri+"</a>";
					}else{
					*/
					formattedText.append("<a style=\"color:" + primaryColor.name() + ";\" href=\"" + uri + "\">" + iri +
					                     "</a>");
					lastWasUrl = true;
					/*}*/
				}
			}
		}
		if (lastWasUrl && formattedText.last().back() != ' ') {
			formattedText.push_back(" ");
		}
		if (chat && chat->mCore) {
			auto participants = chat->mCore->getParticipants();
			auto mentionsParsed = UriTools::parseMention(formattedText.join(""));
			formattedText.clear();

			for (int i = 0; i < mentionsParsed.size(); ++i) {
				QString mention = mentionsParsed[i].second;

				if (mentionsParsed[i].first) {
					QString mentions = mentionsParsed[i].second;
					QStringList finalMentions;
					QStringList parts = mentions.split(" ");
					for (auto part : parts) {
						if (part.startsWith("@")) { // mention
							QString username = part;
							username.removeFirst();
							auto it = std::find_if(
							    participants.begin(), participants.end(),
							    [username](QSharedPointer<ParticipantCore> p) { return username == p->getUsername(); });
							if (it != participants.end()) {
								auto foundParticipant = participants.at(std::distance(participants.begin(), it));
								auto address = foundParticipant->getSipAddress();
								auto isFriend = ToolModel::findFriendByAddress(address);
								if (isFriend)
									part = "@" + Utils::coreStringToAppString(isFriend->getAddress()->getDisplayName());
								QString participantLink = "<a style=\"color:" + primaryColor.name() +
								                          ";\" href=\"mention:" + address + "\">" + part + "</a>";
								finalMentions.append(participantLink);
							} else {
								finalMentions.append(part);
							}
						} else {
							finalMentions.append(part);
						}
					}
					formattedText.push_back(finalMentions.join(" "));
				} else {
					formattedText.push_back(mentionsParsed[i].second);
				}
			}
		}
		return "<p style=\"white-space:pre-wrap;\">" + formattedText.join("");
	});
	data->requestValue();
	return data;
}

QString Utils::encodeEmojiToQmlRichFormat(const QString &body) {
	QString fmtBody = "";
	QVector<uint> utf32_string = body.toUcs4();

	bool insideFontBlock = false;
	for (auto &code : utf32_string) {
		if (Utils::codepointIsEmoji(code)) {
			if (!insideFontBlock) {
				auto font = App::getInstance()->getSettings()->getEmojiFont().family();
				fmtBody += QString("<font face=\"" + font + "\">");
				insideFontBlock = true;
			}
		} else {
			if (insideFontBlock) {
				fmtBody += "</font>";
				insideFontBlock = false;
			}
		}
		fmtBody += QString::fromUcs4(reinterpret_cast<const char32_t *>(&code), 1);
	}
	if (insideFontBlock) {
		fmtBody += "</font>";
	}
	return fmtBody;
}

static bool codepointIsVisible(uint code) {
	return code > 0x00020;
}

bool Utils::isOnlyEmojis(const QString &text) {
	if (text.isEmpty()) return false;
	QVector<uint> utf32_string = text.toUcs4();
	for (auto &code : utf32_string)
		if (codepointIsVisible(code) && !Utils::codepointIsEmoji(code)) return false;
	return true;
}

void Utils::openContactAtAddress(const QString &address) {
	App::postModelAsync([address] {
		auto isFriend = ToolModel::findFriendByAddress(address);
		if (isFriend) {
			App::postCoreAsync([address] {
				auto window = getMainWindow();
				QMetaObject::invokeMethod(window, "displayContactPage", Q_ARG(QVariant, address));
			});
		} else {
			App::postCoreAsync([address] {
				auto window = getMainWindow();
				QMetaObject::invokeMethod(window, "displayCreateContactPage", Q_ARG(QVariant, ""),
				                          Q_ARG(QVariant, address));
			});
		}
	});
}

QString Utils::getFilename(QUrl url) {
	return url.fileName();
}

bool Utils::codepointIsEmoji(uint code) {
	return ((code >= 0x1F600 && code <= 0x1F64F) || // Emoticons
	        (code >= 0x1F300 && code <= 0x1F5FF) || // Misc Symbols and Pictographs
	        (code >= 0x1F680 && code <= 0x1F6FF) || // Transport & Map
	        (code >= 0x1F700 && code <= 0x1F77F) || // Alchemical Symbols
	        (code >= 0x1F900 && code <= 0x1F9FF) || // Supplemental Symbols & Pictographs
	        (code >= 0x1FA70 && code <= 0x1FAFF) || // Symbols and Pictographs Extended-A
	        (code >= 0x2600 && code <= 0x26FF) ||   // Miscellaneous Symbols
	        (code >= 0x2700 && code <= 0x27BF)      // Dingbats
	);
}

QString Utils::toDateTimeString(QDateTime date, const QString &format) {
	if (date.date() == QDate::currentDate()) return toTimeString(date);
	else {
		return getOffsettedUTC(date).toString(format);
	}
}

QDateTime Utils::getOffsettedUTC(const QDateTime &date) {
	QDateTime utc = date.toUTC();
	auto timezone = date.timeZone();
	int offset = timezone.offsetFromUtc(date);
	utc = utc.addSecs(offset);
	utc.setTimeZone(QTimeZone(offset));
	return utc;
}

QString Utils::toTimeString(QDateTime date, const QString &format) {
	// Issue : date.toString() will not print the good time in timezones. Get it from date and add ourself the offset.
	return getOffsettedUTC(date).toString(format);
}
QString Utils::getSafeFilePath(const QString &filePath, bool *soFarSoGood) {
	if (soFarSoGood) *soFarSoGood = true;

	QFileInfo info(filePath);
	if (!info.exists()) return filePath;

	const QString prefix = QStringLiteral("%1/%2").arg(info.absolutePath()).arg(info.baseName());
	const QString ext = info.completeSuffix();

	for (int i = 1; i < SafeFilePathLimit; ++i) {
		QString safePath = QStringLiteral("%1 (%3).%4").arg(prefix).arg(i).arg(ext);
		if (!QFileInfo::exists(safePath)) return safePath;
	}

	if (soFarSoGood) *soFarSoGood = false;

	return QString("");
}

void Utils::forwardMessageTo(ChatMessageGui *message, ChatGui *chatGui) {
	auto chatModel = chatGui && chatGui->mCore ? chatGui->mCore->getModel() : nullptr;
	auto chatMessageModel = message && message->mCore ? message->mCore->getModel() : nullptr;
	if (!chatModel || !chatMessageModel) {
		//: Cannot forward an invalid message
		QString error = !chatMessageModel ? tr("chat_message_forward_error")
		                                  //: Error creating or opening the chat
		                                  : tr("chat_error");
		//: Error
		showInformationPopup(tr("info_popup_error_title"),
		                     //: Could not forward message : %1
		                     tr("info_popup_forward_message_error").arg(error));
		return;
	}
	App::postModelAsync([chatModel, chatMessageModel] {
		mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
		auto chat = chatModel->getMonitor();
		auto messageToForward = chatMessageModel->getMonitor();
		auto linMessage = chatModel->createForwardMessage(messageToForward);
		if (linMessage) {
			linMessage->send();
		} else {
			App::postCoreAsync([] {
				//: Error
				showInformationPopup(tr("info_popup_error_title"),
				                     //: Failed to create forward message
				                     tr("info_popup_send_forward_message_error_message"));
			});
		}
	});
}

void Utils::sendReplyMessage(ChatMessageGui *message, ChatGui *chatGui, QString text, QVariantList files) {
	auto chatModel = chatGui && chatGui->mCore ? chatGui->mCore->getModel() : nullptr;
	auto chatMessageModel = message && message->mCore ? message->mCore->getModel() : nullptr;
	if (!chatModel || !chatMessageModel) {
		//: Cannot reply to invalid message
		QString error = !chatMessageModel ? tr("chat_message_reply_error")
		                                  //: Error in the chat
		                                  : tr("chat_error");
		//: Error
		showInformationPopup(tr("info_popup_error_title"),
		                     //: Could not send reply message : %1
		                     tr("info_popup_reply_message_error").arg(error));
		return;
	}
	QList<std::shared_ptr<ChatMessageContentModel>> filesContent;
	for (auto &file : files) {
		auto contentGui = qvariant_cast<ChatMessageContentGui *>(file);
		if (contentGui) {
			auto contentCore = contentGui->mCore;
			filesContent.append(contentCore->getContentModel());
		}
	}
	App::postModelAsync([chatModel, chatMessageModel, text, filesContent] {
		mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
		auto chat = chatModel->getMonitor();
		auto messageToReplyTo = chatMessageModel->getMonitor();
		auto linMessage = chatModel->createReplyMessage(messageToReplyTo);
		if (linMessage) {
			linMessage->addUtf8TextContent(Utils::appStringToCoreString(text));
			for (auto &content : filesContent) {
				linMessage->addFileContent(content->getContent());
			}
			linMessage->send();
		} else {
			App::postCoreAsync([] {
				//: Error
				showInformationPopup(tr("info_popup_error_title"),
				                     //: Failed to create reply message
				                     tr("info_popup_send_reply_message_error_message"));
			});
		}
	});
}

VariantObject *Utils::createVoiceRecordingMessage(RecorderGui *recorderGui, ChatGui *chatGui) {
	VariantObject *data = new VariantObject("createVoiceRecordingMessage");
	if (!data) return nullptr;
	data->makeRequest([recorderCore = recorderGui ? recorderGui->getCore() : nullptr,
	                   chatCore = chatGui ? chatGui->getCore() : nullptr]() {
		if (!recorderCore || !chatCore) return QVariant();
		auto model = recorderCore->getModel();
		auto chatModel = chatCore->getModel();
		if (!model || !chatModel) return QVariant();
		auto recorder = model->getRecorder();
		auto linMessage = chatModel->createVoiceRecordingMessage(recorder);
		if (linMessage) {
			auto messageCore = ChatMessageCore::create(linMessage);
			return QVariant::fromValue(new ChatMessageGui(messageCore));
		}
		return QVariant();
	});
	data->requestValue();
	return data;
}

void Utils::sendVoiceRecordingMessage(RecorderGui *recorderGui, ChatGui *chatGui) {
	auto chatModel = chatGui && chatGui->mCore ? chatGui->mCore->getModel() : nullptr;
	auto recorderModel = recorderGui && recorderGui->mCore ? recorderGui->mCore->getModel() : nullptr;
	if (!chatModel || !recorderModel) {
		//: Error with the recorder
		QString error = !recorderModel ? tr("recorder_error")
		                               //: Error in the chat
		                               : tr("chat_error");
		//: Error
		showInformationPopup(tr("info_popup_error_title"),
		                     //: Could not send voice message : %1
		                     tr("info_popup_send_voice_message_error_message").arg(error));
		return;
	}
	App::postModelAsync([chatModel, recorderModel] {
		mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
		auto chat = chatModel->getMonitor();
		auto recorder = recorderModel->getRecorder();
		auto linMessage = chatModel->createVoiceRecordingMessage(recorder);
		if (linMessage) {
			linMessage->send();
		} else
			//: Error
			showInformationPopup(tr("info_popup_error_title"),
			                     //: Failed to create message from record
			                     tr("info_popup_send_voice_message_sending_error_message"));
	});
}

bool Utils::isVideo(const QString &path) {
	if (path.isEmpty()) return false;
	return QMimeDatabase().mimeTypeForFile(path).name().contains("video/");
}

bool Utils::isPdf(const QString &path) {
	if (path.isEmpty()) return false;
	return QMimeDatabase().mimeTypeForFile(path).name().contains("application/pdf");
}

bool Utils::isText(const QString &path) {
	if (path.isEmpty()) return false;
	return QMimeDatabase().mimeTypeForFile(path).name().contains("text");
}

bool Utils::isImage(const QString &path) {
	if (path.isEmpty()) return false;
	QFileInfo info(path);
	if (!info.exists() || SettingsModel::getInstance()->getVfsEncrypted()) {
		return QMimeDatabase().mimeTypeForFile(path).name().contains("image/");
	} else {
		if (!QMimeDatabase().mimeTypeForFile(info).name().contains("image/")) return false;
		QImageReader reader(path);
		return reader.canRead() && reader.imageCount() == 1;
	}
}

bool Utils::isAnimatedImage(const QString &path) {
	if (path.isEmpty()) return false;
	QFileInfo info(path);
	if (!info.exists() || !QMimeDatabase().mimeTypeForFile(info).name().contains("image/")) return false;
	QImageReader reader(path);
	return reader.canRead() && reader.supportsAnimation() && reader.imageCount() > 1;
}

bool Utils::fileExists(const QString &path) {
	return QFileInfo::exists(path);
}

bool Utils::canHaveThumbnail(const QString &path) {
	if (path.isEmpty()) return false;
	return isImage(path) || isAnimatedImage(path) /*|| isPdf(path)*/ || isVideo(path);
}

QImage Utils::getImage(const QString &pUri) {
	QImage image(pUri);
	QImageReader reader(pUri);
	reader.setAutoTransform(true);
	if (image.isNull()) { // Try to determine format from headers instead of using suffix
		reader.setDecideFormatFromContent(true);
	}
	return reader.read();
}

void Utils::setGlobalCursor(Qt::CursorShape cursor) {
	if (!App::getInstance()->overrideCursor() || App::getInstance()->overrideCursor()->shape() != cursor) {
		App::getInstance()->setOverrideCursor(QCursor(cursor));
	}
}

void Utils::restoreGlobalCursor() {
	App::getInstance()->restoreOverrideCursor();
}

QString Utils::getEphemeralFormatedTime(int selectedTime) {
	if (selectedTime == 60) return tr("nMinute", "", 1).arg(1);
	else if (selectedTime == 3600) return tr("nHour", "", 1).arg(1);
	else if (selectedTime == 86400) return tr("nDay", "", 1).arg(1);
	else if (selectedTime == 259200) return tr("nDay", "", 3).arg(3);
	else if (selectedTime == 604800) return tr("nWeek", "", 1).arg(1);
	else return tr("nSeconds", "", selectedTime).arg(selectedTime);
}

bool Utils::stringMatchFormat(QString toMatch, QRegularExpression regExp) {
	if (!regExp.isValid()) return false;
	auto match = regExp.match(toMatch);
	return match.hasMatch();
}
