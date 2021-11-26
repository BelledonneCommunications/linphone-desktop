/*
 * Copyright (c) 2010-2021 Belledonne Communications SARL.
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

#include <QtGlobal>
#include <QDirIterator>
#include <QFontDatabase>
#include <QMessageBox>
#include <QQuickStyle>
#include <QtWebView>

#include "config.h"
#include "gitversion.h"

#include "AppController.hpp"

#include "components/other/desktop-tools/DesktopTools.hpp"
#include "utils/Constants.hpp"
// =============================================================================

using namespace std;

AppController::AppController (int &argc, char *argv[]) {
	DesktopTools::init();
	QT_REQUIRE_VERSION(argc, argv, Constants::ApplicationMinimalQtVersion)
	Q_ASSERT(!mApp);
	// Disable QML cache. Avoid malformed cache.
	qputenv("QML_DISABLE_DISK_CACHE", "true");
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	// Useful to share camera on Fullscreen (other context)
	QApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
	
	// Do not use APPLICATION_NAME here.
	// The EXECUTABLE_NAME will be used in qt standard paths. It's our goal.
	QCoreApplication::setApplicationName(EXECUTABLE_NAME);
	QApplication::setOrganizationDomain(EXECUTABLE_NAME);
	QCoreApplication::setApplicationVersion(LINPHONE_QT_GIT_VERSION);
#if QT_VERSION < QT_VERSION_CHECK(5, 15, 0)
	mApp = new App(argc, argv);
	QtWebView::initialize();
#else
	QtWebView::initialize();
	mApp = new App(argc, argv);
#endif
	// ---------------------------------------------------------------------------
	// App creation.
	// ---------------------------------------------------------------------------
	
	QQuickStyle::setStyle("Default");
	if (mApp->isSecondary()) {
#ifdef Q_OS_MACOS
		mApp->processEvents();
#endif // ifdef Q_OS_MACOS
		
		QString command = mApp->getCommandArgument();
		if( command.isEmpty()){
			command = "show";
			QStringList parametersList;
			for(int i = 1 ; i < argc ; ++i){
				QString a = argv[i];
				if(a.startsWith("--"))// show is a command : remove <-->-style parameters
					a.remove(0,2);
				command += " "+a;
			}
		}
		mApp->sendMessage(command.toLocal8Bit(), -1);
		
		return;
	}
	
	// ---------------------------------------------------------------------------
	// Fonts.
	// ---------------------------------------------------------------------------
	
	QDirIterator it(":", QDirIterator::Subdirectories);
	while (it.hasNext()) {
		QFileInfo info(it.next());
		
		if (info.suffix() == QLatin1String("ttf") || info.suffix() == QLatin1String("otf")) {
			QString path = info.absoluteFilePath();
			if (path.startsWith(":/assets/fonts/"))
				if(QFontDatabase::addApplicationFont(path)<0)
					qWarning() << "Font cannot load : " << path;
		}
	}
	qInfo() << "Available fonts : " << QFontDatabase().families();
	
	mApp->setFont(QFont(Constants::DefaultFont));
}

AppController::~AppController () {
	try{
		delete mApp;
	}
	catch(...){
	}
}
