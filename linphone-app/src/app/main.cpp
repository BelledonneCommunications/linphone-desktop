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

#include "AppController.hpp"
#include <qloggingcategory.h>
#ifdef QT_QML_DEBUG
#include <QQmlDebuggingEnabler>
#endif
#include <QSurfaceFormat>
#ifdef _WIN32
#include <Windows.h>
FILE * gStream = NULL;
#endif

#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"

#ifdef ENABLE_QT_KEYCHAIN
#include "components/vfs/VfsUtils.hpp"
#endif

// =============================================================================

void cleanStream(){
#ifdef _WIN32
	if(gStream) {
		fflush(stdout);
		fflush(stderr);
		fclose(gStream);
	}
#endif
}



int main (int argc, char *argv[]) {
#ifdef __APPLE__
	qputenv("QT_ENABLE_GLYPH_CACHE_WORKAROUND", "1");	// On Mac, set this workaround to avoid glitches on M1, because of https://bugreports.qt.io/browse/QTBUG-89379
#elif defined _WIN32
	// log in console only if launched from console
	if (AttachConsole(ATTACH_PARENT_PROCESS)) {
		freopen_s(&gStream, "CONOUT$", "w", stdout);
		freopen_s(&gStream, "CONOUT$", "w", stderr);
	}
#endif

#ifdef ENABLE_QT_KEYCHAIN
	bool vfsEncrypted = VfsUtils::updateSDKWithKey();
#else
	bool vfsEncrypted = false;
#endif

	AppController controller(argc, argv);
#ifdef QT_QML_DEBUG
	QQmlDebuggingEnabler enabler;
#endif
	//QLoggingCategory::setFilterRules("*.debug=true;qml=false");
	App *app = controller.getApp();
	if(vfsEncrypted)
		qInfo() << "Activation of VFS encryption.";
	if (app->isSecondary())
	{
		qInfo() << QStringLiteral("Running secondary app success. Kill it now.");
		cleanStream();
		return EXIT_SUCCESS;
	}
	
	qInfo() << QStringLiteral("Running app...");
	
	int ret;
	do {
		app->initContentApp();
		ret = app->exec();
	} while (ret == App::RestartCode);
	controller.stopApp();	// Stopping app before core to let time to GUI to process needed items from linphone.
	if( CoreManager::getInstance()){
		auto core = CoreManager::getInstance()->getCore();
		if(core && core->getGlobalState() == linphone::GlobalState::On)
			core->stop();
	}
	cleanStream();
	if( ret == App::DeleteDataCode){
		Utils::deleteAllUserDataOffline();
	}
	return ret;
}
