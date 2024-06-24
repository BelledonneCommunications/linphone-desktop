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

#include <QDateTime>
#include <QLoggingCategory>
#include <QMessageBox>
#include <QString>
#include <linphone++/linphone.hh>

#include "config.h"

#include "LoggerListener.hpp"
#include "LoggerModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "tool/Constants.hpp"
#include "tool/Utils.hpp"

#include "core/logger/QtLogger.hpp"
// -----------------------------------------------------------------------------

LoggerModel::LoggerModel(QObject *parent) : QObject(parent) {
	connect(QtLogger::getInstance(), &QtLogger::qtLogReceived, this, &LoggerModel::onQtLog, Qt::QueuedConnection);
	connect(QtLogger::getInstance(), &QtLogger::requestVerboseEnabled, this, &LoggerModel::enableVerbose,
	        Qt::QueuedConnection);
	connect(QtLogger::getInstance(), &QtLogger::requestQtOnlyEnabled, this, &LoggerModel::enableQtOnly,
	        Qt::QueuedConnection);
	connect(this, &LoggerModel::linphoneLogReceived, QtLogger::getInstance(), &QtLogger::onLinphoneLog,
	        Qt::QueuedConnection);
}

LoggerModel::~LoggerModel() {
	linphone::LoggingService::get()->removeListener(mListener);
}

bool LoggerModel::isVerbose() const {
	return mVerboseEnabled;
}

void LoggerModel::enableVerbose(bool verbose) {
	if (mVerboseEnabled != verbose) {
		mVerboseEnabled = verbose;
		emit verboseEnabledChanged();
	}
}

void LoggerModel::enableFullLogs(const bool &full) {
	auto service = linphone::LoggingService::get();
	if (service) service->setLogLevel(full ? linphone::LogLevel::Debug : linphone::LogLevel::Message);
}

bool LoggerModel::qtOnlyEnabled() const {
	return mQtOnlyEnabled;
}

void LoggerModel::enableQtOnly(const bool &enable) {
	if (mQtOnlyEnabled != enable) {
		mQtOnlyEnabled = enable;
		auto service = linphone::LoggingService::get();
		if (service) service->setDomain(enable ? Constants::AppDomain : "");
		emit qtOnlyEnabledChanged();
	}
}

// -----------------------------------------------------------------------------
// Called from Qt
void LoggerModel::onQtLog(QtMsgType type, QString msg) {
	auto service = linphone::LoggingService::get();

	auto serviceMsg = Utils::appStringToCoreString(msg);
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

// Call from Linphone
void LoggerModel::onLinphoneLog(const std::shared_ptr<linphone::LoggingService> &,
                                const std::string &domain,
                                linphone::LogLevel level,
                                const std::string &message) {
	bool isAppLog = domain == Constants::AppDomain;
	if (isAppLog || !mVerboseEnabled || mQtOnlyEnabled) return; // App logs are already managed.

	emit linphoneLogReceived(domain, level, message);
}

// -----------------------------------------------------------------------------

void LoggerModel::enable(bool status) {
	linphone::Core::enableLogCollection(status ? linphone::LogCollectionState::Enabled
	                                           : linphone::LogCollectionState::Disabled);
}

void LoggerModel::applyConfig(const std::shared_ptr<linphone::Config> &config) {
	const QString folder = SettingsModel::getLogsFolder(config);
	linphone::Core::setLogCollectionPath(Utils::appStringToCoreString(folder));
	enableFullLogs(SettingsModel::getFullLogsEnabled(config));
	// TODO : uncomment when it is possible to change the config from settings
	// enable(SettingsModel::getLogsEnabled(config));
	enable(true);
}

void LoggerModel::init() {
	QLoggingCategory::setFilterRules("qt.qml.connections.warning=false");
	mListener = std::make_shared<LoggerListener>();
	connect(mListener.get(), &LoggerListener::logReceived, this, &LoggerModel::onLinphoneLog);
	{
		std::shared_ptr<linphone::LoggingService> loggingService = mLoginService = linphone::LoggingService::get();
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
