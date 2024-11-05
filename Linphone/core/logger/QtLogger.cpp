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

#include "QtLogger.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/Utils.hpp"
#include <QApplication>
#include <QMessageBox>
#include <QMetaMethod>
#include <iostream>
#include <linphone++/linphone.hh>
// -----------------------------------------------------------------------------

static QtLogger gLogger;

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

QtLogger::QtLogger(QObject *parent) : QObject(parent) {
	qInstallMessageHandler(QtLogger::onQtLog);
}

QtLogger::~QtLogger() {
	qInstallMessageHandler(0);
}

QtLogger *QtLogger::getInstance() {
	return &gLogger;
}

QString QtLogger::formatLog(QString contextFile, int contextLine, QString msg) {
	QString message;

#ifdef QT_MESSAGELOGCONTEXT
	{
		QStringList cleanFiles = contextFile.split(Constants::SrcPattern);
		QString fileToDisplay = cleanFiles.back();

		message = QStringLiteral("%1:%2: ").arg(fileToDisplay).arg(contextLine);
	}
#else
	Q_UNUSED(contextFile)
	Q_UNUSED(contextLine)
#endif
	message += msg;
	return message;
}

void QtLogger::onQtLog(QtMsgType type, const QMessageLogContext &context, const QString &msg) {
	QString out;
	QString message = QtLogger::formatLog(context.file, context.line, msg);
	if (gLogger.mVerboseEnabled || !gLogger.isSignalConnected(QMetaMethod::fromSignal(&QtLogger::qtLogReceived))) {
		gLogger.printLog(&out, Constants::AppDomain, LinphoneEnums::toLinphone(type),
		                 Utils::appStringToCoreString(message));
	}
	emit gLogger.qtLogReceived(type, message);
}

void QtLogger::enableVerbose(bool verbose) {
	gLogger.mVerboseEnabled = verbose;
	emit gLogger.requestVerboseEnabled(verbose);
}

void QtLogger::enableQtOnly(bool qtOnly) {
	emit gLogger.requestQtOnlyEnabled(qtOnly);
}

void QtLogger::onLinphoneLog(const std::string &domain, linphone::LogLevel level, const std::string &message) {
	QString qMessage;
	printLog(&qMessage, domain, level, message);

	if (level == linphone::LogLevel::Fatal) {
		QMetaObject::invokeMethod(qApp, [qMessage]() {
			QMessageBox::critical(nullptr, EXECUTABLE_NAME " will crash", qMessage);
			std::terminate();
		});
	}
}

void QtLogger::printLog(QString *qMessage,
                        const std::string &domain,
                        linphone::LogLevel level,
                        const std::string &message) {
	bool isAppLog = domain == Constants::AppDomain;
	FILE *out = stdout;
	// TypeColor Date  SourceColor [Domain] TypeColor Type Reset Message
	QString format = "%1 %2 %3[%4]%1 %5" RESET " %6\n";
	QString colorType;
	QString type;
	*qMessage = Utils::coreStringToAppString(message);
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
	                               .arg(*qMessage);
	fprintf(out, "%s", qPrintable(messageToDisplay));
	fflush(out);
}
