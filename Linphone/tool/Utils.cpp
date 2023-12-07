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
#include "core/path/Paths.hpp"
#include "model/object/VariantObject.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/providers/AvatarProvider.hpp"
#include <QImageReader>
#include <QQuickWindow>

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
	VariantObject *data = new VariantObject(splitted.first().split("@").first()); // Scope : GUI
	data->makeRequest([address]() {
		QString displayName = ToolModel::getDisplayName(address);
		return displayName;
	});
	data->requestValue();
	return data;
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

VariantObject *Utils::createCall(const QString &sipAddress,
                                 const QString &prepareTransfertAddress,
                                 const QHash<QString, QString> &headers) {
	VariantObject *data = new VariantObject(QVariant()); // Scope : GUI

	data->makeRequest([sipAddress, prepareTransfertAddress, headers]() {
		auto call = ToolModel::createCall(sipAddress, prepareTransfertAddress, headers);
		if (call) {
			auto callGui = QVariant::fromValue(new CallGui(call));
			App::postCoreSync([callGui]() {
				auto app = App::getInstance();
				auto window = app->getCallsWindow(callGui);
				window->show();
			});
			return callGui;
		} else return QVariant();
	});
	data->requestValue();

	return data;
}
void Utils::openCallsWindow(CallGui *call) {
	if (call) App::getInstance()->getCallsWindow(QVariant::fromValue(call))->show();
}
void Utils::closeCallsWindow() {
	App::getInstance()->closeCallsWindow();
}

VariantObject *Utils::haveAccount() {
	VariantObject *result = new VariantObject();

	// Using connect ensure to have sender() and receiver() alive.
	result->makeRequest([]() {
		// Model
		return CoreModel::getInstance()->getCore()->getAccountList().size() > 0;
	});
	result->makeUpdate(CoreModel::getInstance().get(), &CoreModel::accountAdded);
	result->requestValue();
	return result;
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

QString Utils::formatElapsedTime(int seconds) {
	// s,	m,	h,		d,		W,		M,			Y
	// 1,	60,	3600,	86400,	604800,	2592000,	31104000
	auto y = floor(seconds / 31104000);
	if (y > 0) return QString::number(y) + " years";
	auto M = floor(seconds / 2592000);
	if (M > 0) return QString::number(M) + " months";
	auto w = floor(seconds / 604800);
	if (w > 0) return QString::number(w) + " week";
	auto d = floor(seconds / 86400);
	if (d > 0) return QString::number(d) + " days";

	auto h = floor(seconds / 3600);
	auto m = floor((seconds - h * 3600) / 60);
	auto s = seconds - h * 3600 - m * 60;

	QString hours, min, sec;

	if (h < 10 && h > 0) {
		hours = "0" + QString::number(h);
	}

	if (m < 10) {
		min = "0" + QString::number(m);
	}

	if (s < 10) {
		sec = "0" + QString::number(s);
	}

	return (h == 0 ? "" : hours + ":") + min + ":" + sec;
}
