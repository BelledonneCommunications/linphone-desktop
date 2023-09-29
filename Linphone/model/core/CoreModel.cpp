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

#include "CoreModel.hpp"

#include <QCoreApplication>
#include <QDir>
#include <QSysInfo>
#include <QTimer>
#include <QFile>

// =============================================================================

CoreModel::CoreModel (const QString &configPath, QObject *parent) :
	QThread(parent) {
	mConfigPath = configPath;
}

CoreModel::~CoreModel(){
}

void CoreModel::run() {
	mCore = linphone::Factory::get()->createCore("","",nullptr);
	
	mCore->start();
	while(!mEnd){
		mCore->iterate();
	}
	mCore->stop();
	mCore = nullptr;
}

// -----------------------------------------------------------------------------

std::shared_ptr<linphone::Core> CoreModel::getCore () {
	return mCore;
}

