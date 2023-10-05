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

#include <QDateTime>
#include <QLoggingCategory>
#include <QMessageBox>
#include <QThread>
#include <linphone++/linphone.hh>

#include "config.h"

//#include "components/settings/SettingsModel.hpp"
#include "LoggerListener.hpp"
#include "LoggerModel.hpp"
#include "tool/Constants.hpp"
#include "tool/Utils.hpp"

#include "LoggerStaticModel.hpp"
// -----------------------------------------------------------------------------

LoggerModel::LoggerModel(QObject *parent) : QObject(parent) {
	connect(LoggerStaticModel::getInstance(), &LoggerStaticModel::logReceived, this, &LoggerModel::onLog,
	        Qt::QueuedConnection);
}

LoggerModel::~LoggerModel() {
}

bool LoggerModel::isVerbose() const {
	return mVerbose;
}

void LoggerModel::setVerbose(bool verbose) {
	mVerbose = verbose;
}

// -----------------------------------------------------------------------------
// Called from Qt
void LoggerModel::onLog(QtMsgType type, QString contextFile, int contextLine, QString msg) {
	connect(this, &LoggerModel::logReceived, this, &LoggerModel::onLog, Qt::QueuedConnection);
	auto service = linphone::LoggingService::get();
	QString contextStr = "";
#ifdef QT_MESSAGELOGCONTEXT
	{
		QStringList cleanFiles = contextFile.split(Constants::SrcPattern);
		QString fileToDisplay = cleanFiles.back();

		contextStr = QStringLiteral("%1:%2: ").arg(fileToDisplay).arg(contextLine);
	}
#else
	Q_UNUSED(context);
#endif

	auto serviceMsg = Utils::appStringToCoreString(contextStr + msg);
	if (service) {
		switch (type) {
			case QtDebugMsg:
				service->debug(serviceMsg);
				break;
			case QtInfoMsg:
				service->message(serviceMsg);
				break;
			case QtWarningMsg:
				service->warning(serviceMsg);
				break;
			case QtCriticalMsg:
				service->error(serviceMsg);
				break;
			case QtFatalMsg:
				service->fatal(serviceMsg);
				break;
		}
	}
}

// -----------------------------------------------------------------------------

void LoggerModel::enable(bool status) {
	linphone::Core::enableLogCollection(status ? linphone::LogCollectionState::Enabled
	                                           : linphone::LogCollectionState::Disabled);
}

void LoggerModel::init(const std::shared_ptr<linphone::Config> &config) {
	// TODO update from config
	// const QString folder = SettingsModel::getLogsFolder(config);
	// linphone::Core::setLogCollectionPath(Utils::appStringToCoreString(folder));
	// enableFullLogs(SettingsModel::getFullLogsEnabled(config));
	// enable(SettingsModel::getLogsEnabled(config));
}

void LoggerModel::init() {
	QLoggingCategory::setFilterRules("qt.qml.connections.warning=false");
	mListener = std::make_shared<LoggerListener>();

	{
		std::shared_ptr<linphone::LoggingService> loggingService = linphone::LoggingService::get();
		loggingService->setDomain(Constants::AppDomain);
		loggingService->setLogLevel(linphone::LogLevel::Debug);
		loggingService->addListener(mListener);
#ifdef _WIN32
		loggingService->enableStackTraceDumps(true);
#endif
	}
	linphone::Core::setLogCollectionPrefix(EXECUTABLE_NAME);
	linphone::Core::setLogCollectionMaxFileSize(Constants::MaxLogsCollectionSize);

	enable(true);
}

void LoggerModel::enableFullLogs(const bool &full) {
	auto service = linphone::LoggingService::get();
	if (service) {
		service->setLogLevel(full ? linphone::LogLevel::Debug : linphone::LogLevel::Message);
	}
}

bool LoggerModel::qtOnlyEnabled() const {
	return mQtOnly;
}

void LoggerModel::enableQtOnly(const bool &enable) {
	mQtOnly = enable;
	auto service = linphone::LoggingService::get();
	if (service) {
		service->setDomain(enable ? Constants::AppDomain : "");
	}
}

QString LoggerModel::getLogText() const {
	QDir path = QString::fromStdString(linphone::Core::getLogCollectionPath());
	QString prefix = QString::fromStdString(linphone::Core::getLogCollectionPrefix());
	auto files = path.entryInfoList(QStringList(prefix + "*.log"), QDir::Files | QDir::NoSymLinks | QDir::Readable,
	                                QDir::Time | QDir::Reversed);
	QString result;
	for (auto fileInfo : files) {
		QFile file(fileInfo.filePath());
		if (file.open(QIODevice::ReadOnly)) {
			QByteArray arr = file.readAll();
			result += QString::fromLatin1(arr);
			file.close();
		}
	}
	return result;
}
