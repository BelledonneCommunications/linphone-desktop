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

#include "CrashReporter.hpp"
#include "config.h"
#include "core/path/Paths.hpp"
#include "model/setting/SettingsModel.hpp"
#include "tool/Constants.hpp"
#include "tool/Utils.hpp"

#include "client/crash_report_database.h"
#include "client/settings.h"
#include <QSettings>

CrashReporter *CrashReporter::gHandler = nullptr;

CrashReporter::CrashReporter(QObject *parent) : QObject(parent) {
	mHandlerPath = base::FilePath(Utils::getNativeString(Paths::getCrashpadHandlerFilePath()));
	mDatabasePath = base::FilePath(Utils::getNativeString(Paths::getCrashpadDirPath()));
	mMetricsPath = base::FilePath(Utils::getNativeString(Paths::getMetricsDirPath()));
	mBugsplatUrl = Constants::BugsplatUrl;

	mAnnotations["format"] = "minidump";          // Required: Crashpad setting to save crash as a minidump
	mAnnotations["database"] = BUGSPLAT_DATABASE; // Required: BugSplat database
	mAnnotations["product"] = APPLICATION_NAME;   // Required: BugSplat appName
	mAnnotations["version"] = APPLICATION_SEMVER;
	//	annotations["key"] = "Sample key";                  // Optional: BugSplat key field
	//	annotations["user"] = "fred@bugsplat.com";          // Optional: BugSplat user email
	//	annotations["list_annotations"] = "Sample comment";	// Optional: BugSplat crash description

	// Disable crashpad rate limiting so that all crashes have dmp files
	mArguments.push_back("--no-rate-limit");
	auto config =
	    linphone::Factory::get()->createConfig(Utils::appStringToCoreString(Paths::getConfigFilePath("", true)));

	// Attachments to be uploaded alongside the crash - default bundle size limit is 20MB
	// Crashpad doesn't manage folders. We have to guess the files to be uploaded.
	QString logFiles = Paths::getLogsDirPath() + QDir::separator() + EXECUTABLE_NAME;
	mAttachments.push_back(base::FilePath(Utils::getNativeString(logFiles + ".log")));
	mAttachments.push_back(base::FilePath(Utils::getNativeString(logFiles + "1.log")));
	mAttachments.push_back(base::FilePath(Utils::getNativeString(logFiles + "2.log")));
}

bool CrashReporter::start() {
	lInfo() << "[CrashReporter] Starting CrashReporter";
	auto config =
	    linphone::Factory::get()->createConfig(Utils::appStringToCoreString(Paths::getConfigFilePath("", true)));
	return CrashReporter::enable(SettingsModel::getCrashReporterEnabled(config));
}

bool CrashReporter::run() {

	// Attachments to be uploaded alongside the crash - default bundle size limit is 20MB
	base::FilePath attachment(Utils::getNativeString(Paths::getCrashpadAttachmentsPath()));
#if defined(Q_OS_WINDOWS) || defined(Q_OS_LINUX)
	// Crashpad hasn't implemented attachments on OS X yet
	mAttachments.push_back(attachment);
#endif
	lInfo() << "[CrashReporter] Start handler, handler path =" << Paths::getCrashpadHandlerFilePath()
	        << "| database path =" << Paths::getCrashpadDirPath() << "| metrics path =" << Paths::getMetricsDirPath()
	        << "bugsplat url =" << mBugsplatUrl;
	// crashpad::CrashpadClient *client = new crashpad::CrashpadClient();
	bool status = mClient.StartHandler(mHandlerPath, mDatabasePath, mMetricsPath, mBugsplatUrl.toStdString(),
	                                   mAnnotations.toStdMap(), mArguments, true, true, mAttachments);

	if (!status) {
		lWarning() << "[CrashReporter] Failed to start Crashpad handler. Crashes will not be logged.";
	} else {
		lInfo() << "[CrashReporter] Started Crashpad handler. Database at" << Paths::getCrashpadDirPath();
		lInfo() << "[CrashReporter] Crashes upload url :" << mBugsplatUrl;
	}
	return status;
}

bool CrashReporter::enable(const bool &on) {
	if (!gHandler) gHandler = new CrashReporter();
	lInfo() << "[CrashReporter] Enable CrashReporter" << on;
	std::unique_ptr<crashpad::CrashReportDatabase> database =
	    crashpad::CrashReportDatabase::Initialize(gHandler->mDatabasePath);
	if (database == NULL) {
		lInfo() << "[CrashReporter] No Crashpad database, return";
		return false;
	}
	crashpad::Settings *settings = database->GetSettings();
	if (settings == NULL) {
		lInfo() << "[CrashReporter] No Crashpad settings, return";
		return false;
	}
	settings->SetUploadsEnabled(on);

	if (on) {
		lInfo() << "[CrashReporter] Run Crashpad";
		return gHandler->run();
	} else {
		lInfo() << "[CrashReporter] Crashpad has been deactivated by user.";
		return false;
	}
}
