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

#include "Settings.hpp"

#include <QUrl>

#include "core/path/Paths.hpp"

// =============================================================================

Settings::Settings(QObject *parent) : QObject(parent) {
}

Settings::~Settings() {
}

QString Settings::getConfigPath(const QCommandLineParser &parser) {
	QString filePath = parser.isSet("config") ? parser.value("config") : "";
	QString configPath;
	if (!QUrl(filePath).isRelative()) {
		// configPath = FileDownloader::synchronousDownload(filePath,
		// Utils::coreStringToAppString(Paths::getConfigDirPath(false)), true));
	}
	if (configPath == "") configPath = Paths::getConfigFilePath(filePath, false);
	if (configPath == "") configPath = Paths::getConfigFilePath("", false);
	return configPath;
}