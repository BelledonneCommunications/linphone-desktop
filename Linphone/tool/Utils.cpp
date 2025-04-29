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

#include "core/App.hpp"
#include "core/call/CallGui.hpp"
#include "core/chat/ChatCore.hpp"
#include "core/chat/ChatGui.hpp"
#include "core/conference/ConferenceCore.hpp"
#include "core/conference/ConferenceInfoCore.hpp"
#include "core/conference/ConferenceInfoGui.hpp"
#include "core/friend/FriendGui.hpp"
#include "core/participant/ParticipantDeviceCore.hpp"
#include "core/path/Paths.hpp"
#include "core/payload-type/DownloadablePayloadTypeCore.hpp"
#include "model/object/VariantObject.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/providers/AvatarProvider.hpp"

#include <limits.h>

#include <QClipboard>
#include <QCryptographicHash>
#include <QDesktopServices>
#include <QHostAddress>
#include <QImageReader>
#include <QProcess>
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

QString Utils::getInitials(const QString &username) {
	if (username.isEmpty()) return "";

	QRegularExpression regex("[\\s\\.]+");
	QStringList words = username.split(regex); // Qt 5.14: Qt::SkipEmptyParts
	QStringList initials;
	auto str32 = words[0].toStdU32String();
	std::u32string char32;
	char32 += str32[0];
	initials << QString::fromStdU32String(char32);
	for (int i = 1; i < words.size() && initials.size() <= 1; ++i) {
		if (words[i].size() > 0) {
			str32 = words[i].toStdU32String();
			char32[0] = str32[0];
			initials << QString::fromStdU32String(char32);
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
		window->showNormal();
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

QString Utils::formatDate(const QDateTime &date, bool includeTime, bool includeDateIfToday, QString format) {
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
				auto params = linphoneChatRoom->getCurrentParams();
				auto chatCore = ChatCore::create(linphoneChatRoom);
				return QVariant::fromValue(new ChatGui(chatCore));
			} else {
				qWarning() << "Failed to create 1-1 conversation with"
				           << callModel->getRemoteAddress()->asStringUriOnly() << "!";
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

VariantObject *Utils::getChatForAddress(QString address) {
	VariantObject *data = new VariantObject("lookupCurrentCallChat");
	if (!data) return nullptr;
	data->makeRequest([address, data]() {
		auto linAddr = ToolModel::interpretUrl(address);
		if (!linAddr) return QVariant();
		auto linphoneChatRoom = ToolModel::lookupChatForAddress(linAddr);
		if (linphoneChatRoom) {
			auto chatCore = ChatCore::create(linphoneChatRoom);
			return QVariant::fromValue(new ChatGui(chatCore));
		} else {
			qDebug() << "Did not find existing chat room, create one";
			linphoneChatRoom = ToolModel::createChatForAddress(linAddr);
			if (linphoneChatRoom != nullptr) {
				qDebug() << "Chatroom created with" << linAddr->asStringUriOnly();
				auto params = linphoneChatRoom->getCurrentParams();
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
