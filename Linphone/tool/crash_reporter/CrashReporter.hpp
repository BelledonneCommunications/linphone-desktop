/*
 * Copyright (c) 2010-2026 Belledonne Communications SARL.
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

#ifndef CRASH_REPORTER_H_
#define CRASH_REPORTER_H_

#include <QMap>
#include <QObject>
#include <QVector>
#include <string>

#include "client/crashpad_client.h"

// =============================================================================
class CrashReporter : public QObject {
public:
	CrashReporter(QObject *parent = nullptr);

	static void start();
	static void enable(const bool &on);
	void run();

	crashpad::CrashpadClient mClient;
	std::vector<base::FilePath> mAttachments;
	QMap<std::string, std::string> mAnnotations;
	std::vector<std::string> mArguments;
	base::FilePath mHandlerPath;
	base::FilePath mDatabasePath;
	base::FilePath mMetricsPath;
	base::FilePath mLogsPath;
	QString mBugsplatUrl;
	static CrashReporter *gHandler;
};

#endif