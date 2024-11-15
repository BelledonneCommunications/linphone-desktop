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

#include "CarddavGui.hpp"
#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(CarddavGui)

CarddavGui::CarddavGui(QSharedPointer<CarddavCore> core) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::JavaScriptOwnership);
	mCore = core;
	if (isInLinphoneThread()) moveToThread(App::getInstance()->thread());
}

CarddavGui::CarddavGui(QObject *parent) : QObject(parent) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	App::postModelSync([this]() {
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		mCore = CarddavCore::create(nullptr);
	});
}

CarddavGui::~CarddavGui() {
	mustBeInMainThread("~" + getClassName());
}

CarddavCore *CarddavGui::getCore() const {
	return mCore.get();
}
