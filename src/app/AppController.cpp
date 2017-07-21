/*
 * AppController.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
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

#include "gitversion.h"

#include "AppController.hpp"

// Must be unique. Used by `SingleApplication` and `Paths`.
#define APPLICATION_NAME "linphone"
#define APPLICATION_VERSION LINPHONE_QT_GIT_VERSION
#define APPLICATION_MINIMAL_QT_VERSION "5.9.0"

#define DEFAULT_FONT "Noto Sans"

using namespace std;

// =============================================================================

AppController::AppController (int &argc, char *argv[]) {
  QT_REQUIRE_VERSION(argc, argv, APPLICATION_MINIMAL_QT_VERSION);
  Q_ASSERT(!mApp);

  // Disable QML cache. Avoid malformed cache.
  qputenv("QML_DISABLE_DISK_CACHE", "true");

  // ---------------------------------------------------------------------------
  // OpenGL properties.
  // ---------------------------------------------------------------------------

  // Options to get a nice video render.
  #ifdef Q_OS_WIN
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES, true);
  #else
    QCoreApplication::setAttribute(Qt::AA_UseDesktopOpenGL, true);
  #endif // ifdef Q_OS_WIN
  QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts, true);

  {
    QSurfaceFormat format;

    format.setSwapBehavior(QSurfaceFormat::TripleBuffer);
    format.setSwapInterval(1);

    format.setRedBufferSize(8);
    format.setGreenBufferSize(8);
    format.setBlueBufferSize(8);
    format.setAlphaBufferSize(8);

    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);

    QSurfaceFormat::setDefaultFormat(format);
  }

  // ---------------------------------------------------------------------------
  // App creation.
  // ---------------------------------------------------------------------------

  QCoreApplication::setApplicationName(APPLICATION_NAME);
  QCoreApplication::setApplicationVersion(APPLICATION_VERSION);

  mApp = new App(argc, argv);
  if (mApp->isSecondary()) {
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

    if (info.suffix() == "ttf") {
      QString path = info.absoluteFilePath();
      if (path.startsWith(":/assets/fonts/"))
        QFontDatabase::addApplicationFont(path);
    }
  }

  mApp->setFont(QFont(DEFAULT_FONT));
}

AppController::~AppController () {
  delete mApp;
}
