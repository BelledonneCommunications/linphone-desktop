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

#include "CoreModel.hpp"

#include <QApplication>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QSysInfo>
#include <QTimer>

#include "tool/Utils.hpp"

// =============================================================================

CoreModel::CoreModel(const QString &configPath, QObject *parent) : QObject(parent) {
	mConfigPath = configPath;
	mLogger = std::make_shared<LoggerModel>(this);
	mLogger->init();
}

CoreModel::~CoreModel() {
}

void CoreModel::start() {
	auto configPath = Utils::appStringToCoreString(mConfigPath);
	mCore = linphone::Factory::get()->createCore(configPath, "", nullptr);
	mCore->enableAutoIterate(true);
	mCore->start();
}
// -----------------------------------------------------------------------------

CoreModel *CoreModel::getInstance() {
	return nullptr;
}

std::shared_ptr<linphone::Core> CoreModel::getCore() {
	return mCore;
}
