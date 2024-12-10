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

#include <QLibrary>

#include "DownloadablePayloadTypeModel.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(DownloadablePayloadTypeModel)

DownloadablePayloadTypeModel::DownloadablePayloadTypeModel(QObject *parent) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
}

DownloadablePayloadTypeModel::~DownloadablePayloadTypeModel() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
}

void DownloadablePayloadTypeModel::loadLibrary(QString filename) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	lInfo() << log().arg("Loading library:") << filename;
	if (QLibrary::isLibrary(filename)) {
		auto library = QLibrary(filename);
		if (!library.load()) {
			lWarning() << log().arg("Failed loading library:") << filename << " error:" << library.errorString();
			emit loaded(false);
		} else {
			lInfo() << log().arg("Successfully loaded library:") << filename;
			CoreModel::getInstance()->getCore()->reloadMsPlugins("");
			emit loaded(true);
		}
	} else {
		lWarning() << log().arg("Failed loading library (not a library file):") << filename;
		emit loaded(false);
	}
	lInfo() << log().arg("Finished Loading library:") << filename;
}
