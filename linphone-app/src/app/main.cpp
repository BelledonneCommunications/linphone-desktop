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

#include "components/core/CoreManager.hpp"
// =============================================================================

int main (int argc, char *argv[]) {
#ifdef __APPLE__
	qputenv("QT_ENABLE_GLYPH_CACHE_WORKAROUND", "1");	// On Mac, set this workaround to avoid glitches on M1, because of https://bugreports.qt.io/browse/QTBUG-89379
#endif
  AppController controller(argc, argv);
#ifdef QT_QML_DEBUG
  QQmlDebuggingEnabler enabler;
#endif
  //QLoggingCategory::setFilterRules("*.debug=true;qml=false");
  App *app = controller.getApp();
  
  if (app->isSecondary())
  {
	  qInfo() << QStringLiteral("Running secondary app success. Kill it now.");
	  return EXIT_SUCCESS;
  }

  qInfo() << QStringLiteral("Running app...");

  int ret;
  do {
    app->initContentApp();
    ret = app->exec();
  } while (ret == App::RestartCode);
  auto core = CoreManager::getInstance()->getCore();
  if(core && core->getGlobalState() == linphone::GlobalState::On)
	core->stop();
  
  return ret;
}
