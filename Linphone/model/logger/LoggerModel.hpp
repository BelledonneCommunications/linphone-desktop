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

#ifndef LOGGER_MODEL_H_
#define LOGGER_MODEL_H_

#include <QObject>
#include <QString>
#include <linphone++/linphone.hh>

#include "LoggerListener.hpp"
// =============================================================================

class LoggerModel : public QObject {
	Q_OBJECT
public:
	LoggerModel(QObject *parent = nullptr);
	~LoggerModel();

	bool isVerbose() const;
	void enableVerbose(bool verbose);
	void enable(bool status);
	QString getLogText() const;
	void enableFullLogs(const bool &full);
	bool qtOnlyEnabled() const;
	void enableQtOnly(const bool &enable);

	void init();
	void applyConfig(const std::shared_ptr<linphone::Config> &config);

	void onQtLog(QtMsgType type, QString msg); // Received from Qt
	void onLinphoneLog(const std::shared_ptr<linphone::LoggingService> &,
	                   const std::string &domain,
	                   linphone::LogLevel level,
	                   const std::string &message); // Received from SDK

signals:
	void
	linphoneLogReceived(const std::string &domain, linphone::LogLevel level, const std::string &message); // Send to Qt
	void verboseEnabledChanged();
	void qtOnlyEnabledChanged();

private:
	static void log(QtMsgType type, const QMessageLogContext &context, const QString &msg);
	bool mVerboseEnabled = false;
	bool mQtOnlyEnabled = false;
	std::shared_ptr<LoggerListener> mListener;
	std::shared_ptr<linphone::LoggingService> mLoginService; // Need to store one instance to avoid unwanted cleanup.
};

#endif
