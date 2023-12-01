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

#include <bctoolbox/logging.h>
#include <linphone++/linphone.hh>
#include <QDateTime>
#include <QThread>
#include <QMessageBox>
#include <QLoggingCategory>

#include "config.h"

#include "components/settings/SettingsModel.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"
#include "Logger.hpp"

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

using namespace std;

QMutex Logger::mMutex;

Logger *Logger::mInstance;

// -----------------------------------------------------------------------------

static inline QByteArray getFormattedCurrentTime () {
	return QDateTime::currentDateTime().toString("HH:mm:ss:zzz").toLocal8Bit();
}

// -----------------------------------------------------------------------------
// Called from SDK
class LinphoneLogger : public linphone::LoggingServiceListener {
public:
	LinphoneLogger (const Logger *logger) : mLogger(logger) {}
	
private:
	void onLogMessageWritten (
			const shared_ptr<linphone::LoggingService> &,
			const string &domain,
			linphone::LogLevel level,
			const string &message
			) override {
		bool isQtLog = domain==Constants::QtDomain;
		if (!mLogger->isVerbose() || (!isQtLog && mLogger->qtOnlyEnabled()))
			return;
		FILE * out = stdout;
		using LogLevel = linphone::LogLevel;
		QString format = (isQtLog ? PURPLE : YELLOW ) + QString("Core:%s: " RESET "%s\n");
		switch (level) {
			case LogLevel::Debug:
				format.prepend(GREEN "[%s][Debug]");
				break;
			case LogLevel::Trace:
				format.prepend(BLUE "[%s][Trace]");
				break;
			case LogLevel::Message:
				format.prepend(BLUE "[%s][Info]");
				break;
			case LogLevel::Warning:
				format.prepend(RED "[%s][Warning]");
				out = stderr;
				break;
			case LogLevel::Error:
				format.prepend(RED "[%s][Error]");
				out = stderr;
				break;
			case LogLevel::Fatal:
				format.prepend(RED "[%s][Fatal]");
				out = stderr;
				break;
		}
		
		fprintf(	out,
					qPrintable(format),
					getFormattedCurrentTime().constData(),
					domain.empty() ? domain.c_str() : EXECUTABLE_NAME,
					message.c_str()
					);
		fflush(out);
		if (level == LogLevel::Fatal)
			terminate();
	};
	
	const Logger *mLogger;
};

// -----------------------------------------------------------------------------
// Called from Qt
void Logger::log (QtMsgType type, const QMessageLogContext &context, const QString &msg) {
	const char *format;
	BctbxLogLevel level;
	
	if (type == QtDebugMsg) {
		format = GREEN "[%s][%p][Debug]" PURPLE "%s" RESET "%s\n";
		level = BCTBX_LOG_DEBUG;
	} else if (type == QtInfoMsg) {
		format = BLUE "[%s][%p][Info]" PURPLE "%s" RESET "%s\n";
		level = BCTBX_LOG_MESSAGE;
	} else if (type == QtWarningMsg) {
		format = RED "[%s][%p][Warning]" PURPLE "%s" RESET "%s\n";
		level = BCTBX_LOG_WARNING;
	} else if (type == QtCriticalMsg) {
		format = RED "[%s][%p][Critical]" PURPLE "%s" RESET "%s\n";
		level = BCTBX_LOG_ERROR;
	} else if (type == QtFatalMsg) {
		format = RED "[%s][%p][Fatal]" PURPLE "%s" RESET "%s\n";
		level = BCTBX_LOG_FATAL;
	} else
		return;
	
	const char *contextStr = "";
	
#ifdef QT_MESSAGELOGCONTEXT
	QByteArray contextArr;
	{
		const char *file = context.file;
		const char *pos = file ? Utils::rstrstr(file, Constants::SrcPattern) : file;
		
		contextArr = QStringLiteral("%1:%2: ")
				.arg(pos ? pos + sizeof(Constants::SrcPattern) - 1 : file)
				.arg(context.line)
				.toLocal8Bit();
		contextStr = contextArr.constData();
	}
#else
	Q_UNUSED(context);
#endif // ifdef QT_MESSAGELOGCONTEXT
	
	QByteArray localMsg = msg.toLocal8Bit();
	QByteArray dateTime = getFormattedCurrentTime();
	
	mMutex.lock();
	
	if( level == BCTBX_LOG_FATAL)
		QMessageBox::critical(nullptr, "Linphone will crash", msg); // Print an error message before sending msg to bctoolbox
	bctbx_log(Constants::QtDomain, level, "QT: %s%s", contextStr, localMsg.constData());
	
	mMutex.unlock();
	
	if (type == QtFatalMsg)
		terminate();
}

// -----------------------------------------------------------------------------

void Logger::enable (bool status) {
	linphone::Core::enableLogCollection(
				status
				? linphone::LogCollectionState::Enabled
				: linphone::LogCollectionState::Disabled
				  );
}

void Logger::init (const shared_ptr<linphone::Config> &config) {
	if (mInstance)
		return;
	QLoggingCategory::setFilterRules("qt.qml.connections.warning=false");
	const QString folder = SettingsModel::getLogsFolder(config);
	Q_ASSERT(!folder.isEmpty());
	
	mInstance = new Logger();
	
	qInstallMessageHandler(Logger::log);
	
	{
		shared_ptr<linphone::LoggingService> loggingService = mInstance->mLoggingService = linphone::LoggingService::get();
		loggingService->setDomain(Constants::QtDomain);
		loggingService->setLogLevel(linphone::LogLevel::Message);
		loggingService->addListener(make_shared<LinphoneLogger>(mInstance));
#ifdef _WIN32
		loggingService->enableStackTraceDumps(true);
#endif
	}
	
	linphone::Core::setLogCollectionPrefix(EXECUTABLE_NAME);
	linphone::Core::setLogCollectionPath(Utils::appStringToCoreString(folder));
	linphone::Core::setLogCollectionMaxFileSize(SettingsModel::getMaxLogsCollectionSize(config));
	
	mInstance->enableFullLogs(SettingsModel::getFullLogsEnabled(config));
	mInstance->enable(SettingsModel::getLogsEnabled(config));
	
}

void Logger::enableFullLogs(const bool& full){
	if(mLoggingService){
		mLoggingService->setLogLevel(full ? linphone::LogLevel::Debug : linphone::LogLevel::Message);
	}
}

bool Logger::qtOnlyEnabled() const{
	return mQtOnly;
}

void Logger::enableQtOnly(const bool& enable){
	mQtOnly = enable;
	if(mLoggingService){
		mLoggingService->setDomain(enable ? Constants::QtDomain : "");
	}
}

QString Logger::getLogText()const{
	QDir path = QString::fromStdString(linphone::Core::getLogCollectionPath());
	QString prefix = QString::fromStdString(linphone::Core::getLogCollectionPrefix());
	auto files = path.entryInfoList(QStringList(prefix+"*.log"), QDir::Files | QDir::NoSymLinks | QDir::Readable, QDir::Time | QDir::Reversed);
    QString result;
	for(auto fileInfo : files){
		QFile file(fileInfo.filePath());
		if (file.open(QIODevice::ReadOnly)) {
			QByteArray arr = file.readAll();
			result += QString::fromLatin1(arr);
			file.close();
		}
	}
    return result;
}
