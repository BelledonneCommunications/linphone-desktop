/*
 * AppController.cpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: July 17, 2017
 *      Author: Ronan Abhamon
 */

#include <QDirIterator>
#include <QFontDatabase>
#include <QMessageBox>
#include <QQuickStyle>

#include "config.h"
#include "gitversion.h"

#include "AppController.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr char ApplicationMinimalQtVersion[] = "5.9.0";
  constexpr char DefaultFont[] = "Noto Sans";
}

AppController::AppController (int &argc, char *argv[]) {
  QT_REQUIRE_VERSION(argc, argv, ApplicationMinimalQtVersion);
  Q_ASSERT(!mApp);

  // Disable QML cache. Avoid malformed cache.
  qputenv("QML_DISABLE_DISK_CACHE", "true");

  // ---------------------------------------------------------------------------

  QGuiApplication::setAttribute(Qt::AA_DisableHighDpiScaling, true);

  // Useful to share camera on Fullscreen (other context).
  QApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

  // ---------------------------------------------------------------------------
  // App creation.
  // ---------------------------------------------------------------------------

  // Do not use APPLICATION_NAME here.
  // The EXECUTABLE_NAME will be used in qt standard paths. It's our goal.
  QCoreApplication::setApplicationName(EXECUTABLE_NAME);
  QCoreApplication::setApplicationVersion(LINPHONE_QT_GIT_VERSION);

  mApp = new App(argc, argv);
  QQuickStyle::setStyle("Default");
  if (mApp->isSecondary()) {
    #ifdef Q_OS_MACOS
      mApp->processEvents();
    #endif // ifdef Q_OS_MACOS

    QString command = mApp->getCommandArgument();
    mApp->sendMessage(command.isEmpty() ? "show" : command.toLocal8Bit(), -1);

    return;
  }

  // ---------------------------------------------------------------------------
  // Fonts.
  // ---------------------------------------------------------------------------

  QDirIterator it(":", QDirIterator::Subdirectories);
  while (it.hasNext()) {
    QFileInfo info(it.next());

    if (info.suffix() == QLatin1String("ttf")) {
      QString path = info.absoluteFilePath();
      if (path.startsWith(":/assets/fonts/"))
        QFontDatabase::addApplicationFont(path);
    }
  }

  mApp->setFont(QFont(DefaultFont));
}

AppController::~AppController () {
  delete mApp;
}
