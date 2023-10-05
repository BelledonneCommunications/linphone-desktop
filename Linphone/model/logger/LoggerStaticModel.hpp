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

#ifndef LOGGER_STATIC_MODEL_H_
#define LOGGER_STATIC_MODEL_H_

#include <QMetaMethod>
#include <QObject>

// =============================================================================

// Only one instance. Use getInstance() and logReceived() to bind logs coming from Qt.
class LoggerStaticModel : public QObject {
	Q_OBJECT
public:
	LoggerStaticModel(QObject *parent = nullptr);

	static LoggerStaticModel *getInstance();
	static void onQtLog(QtMsgType type, const QMessageLogContext &context, const QString &msg);

signals:
	void logReceived(QtMsgType type, QString contextFile, int contextLine, QString msg);
};

#endif
