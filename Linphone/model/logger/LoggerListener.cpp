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

#include "LoggerListener.hpp"

#include <QCoreApplication>
#include <QDateTime>
#include <QMessageBox>
#include <QString>

#include "tool/Constants.hpp"
#include "tool/Utils.hpp"

// =============================================================================

#if defined(__linux__) || defined(__APPLE__)
#define BLUE "\x1B[1;34m"
#define YELLOW "\x1B[1;33m"
#define GREEN "\x1B[1;32m"
#define PURPLE "\x1B[1;35m"
#define RED "\x1B[1;31m"
#define RESET "\x1B[0m"
#else
#define BLUE ""
#define YELLOW ""
#define GREEN ""
#define PURPLE ""
#define RED ""
#define RESET ""
#endif // if defined(__linux__) || defined(__APPLE__)

// -----------------------------------------------------------------------------

static inline QByteArray getFormattedCurrentTime() {
	return QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss:zzz").toLocal8Bit();
}

// -----------------------------------------------------------------------------

LoggerListener::LoggerListener() {
}

void LoggerListener::onLogMessageWritten(const std::shared_ptr<linphone::LoggingService> &,
                                         const std::string &domain,
                                         linphone::LogLevel level,
                                         const std::string &message) {
	bool isAppLog = domain == Constants::AppDomain;
	if (!mIsVerbose || (!isAppLog && mQtOnlyEnabled)) return;
	FILE *out = stdout;
	// TypeColor Date  SourceColor [Domain] TypeColor Type Reset Message
	QString format = "%1 %2 %3[%4]%1 %5" RESET " %6\n";
	QString colorType;
	QString type;
	QString qMessage = Utils::coreStringToAppString(message);
	switch (level) {
		case linphone::LogLevel::Debug:
			colorType = GREEN;
			type = "DEBUG";
			break;
		case linphone::LogLevel::Trace:
			colorType = BLUE;
			type = "TRACE";
			break;
		case linphone::LogLevel::Message:
			colorType = BLUE;
			type = "MESSAGE";
			break;
		case linphone::LogLevel::Warning:
			colorType = RED;
			type = "WARNING";
			out = stderr;
			break;
		case linphone::LogLevel::Error:
			colorType = RED;
			type = "ERROR";
			out = stderr;
			break;
		case linphone::LogLevel::Fatal:
			colorType = RED;
			type = "FATAL";
			out = stderr;
			break;
	}
	QString messageToDisplay = format.arg(colorType)
	                               .arg(getFormattedCurrentTime())
	                               .arg(isAppLog ? PURPLE : YELLOW)
	                               .arg(Utils::coreStringToAppString(domain))
	                               .arg(type)
	                               .arg(qMessage);
	fprintf(out, "%s", qPrintable(messageToDisplay));
	fflush(out);
	if (level == linphone::LogLevel::Fatal) {
		QMetaObject::invokeMethod(qApp, [qMessage]() {
			QMessageBox::critical(nullptr, EXECUTABLE_NAME " will crash", qMessage);
			std::terminate();
		});
	}
}
