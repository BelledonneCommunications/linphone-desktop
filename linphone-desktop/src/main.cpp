/*
 * main.cpp
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
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#include <iostream>

#include "app/App.hpp"
#include "app/Logger.hpp"

using namespace std;

// =============================================================================

int main (int argc, char *argv[]) {
  // Disable QML cache. Avoid malformed cache.
  qputenv("QML_DISABLE_DISK_CACHE", "true");

  // Options to get a nice video render.
#ifdef _WIN32
  QCoreApplication::setAttribute(Qt::AA_UseOpenGLES, true);
#else
  QCoreApplication::setAttribute(Qt::AA_UseDesktopOpenGL, true);
#endif
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

  App app(argc, argv);
  app.parseArgs();

  if (app.isSecondary()) {
    app.sendMessage("show", 0);
    return 0;
  }

  app.initContentApp();

  // Run!
  return app.exec();
}
