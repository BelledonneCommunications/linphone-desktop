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

#ifndef QT_LOGGER_H_
#define QT_LOGGER_H_

#include <QMetaMethod>
#include <QObject>

#include <linphone++/linphone.hh>

// =============================================================================
//
//      Qt          SDK
// fatal |            |
//   -- *----------> |
//  |                |
//  |   | <--------- *
//  |   |            |
//   -> |            |
//      V            V
//     OUT          FILE
//
// Only one instance. Use getInstance() and logReceived() to bind logs coming from Qt.
class QtLogger : public QObject {
	Q_OBJECT
public:
	QtLogger(QObject *parent = nullptr);
	~QtLogger();
	static QtLogger *getInstance();
	static void enableVerbose(bool verbose);
	static void enableQtOnly(bool qtOnly);

	static QString formatLog(QString contextFile, int contextLine, QString msg);
	void printLog(QString *qMessage, const std::string &domain, linphone::LogLevel level, const std::string &message);

	// Log Sources
	static void onQtLog(QtMsgType type, const QMessageLogContext &context, const QString &msg);
	void onLinphoneLog(const std::string &domain, linphone::LogLevel level, const std::string &message);
	bool mVerboseEnabled = false;
signals:
	void qtLogReceived(QtMsgType type, QString msg);
	void requestVerboseEnabled(bool verbose);
	void requestQtOnlyEnabled(bool qtOnly);
};

#endif
