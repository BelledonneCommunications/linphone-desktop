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
  qputenv("QML_DISABLE_DISK_CACHE", "true");

  QCoreApplication::setAttribute(Qt::AA_UseDesktopOpenGL, true);
  QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts, true);

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
