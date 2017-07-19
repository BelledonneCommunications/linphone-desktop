/*
 * SelfTest.cpp
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

#include <QQmlProperty>
#include <QSignalSpy>
#include <QTest>

#include "../../app/App.hpp"
#include "../../components/core/CoreManager.hpp"
#include "../TestUtils.hpp"

#include "SelfTest.hpp"

// =============================================================================

void SelfTest::checkAppStartup () {
  CoreManager *coreManager = CoreManager::getInstance();
  QQuickItem *mainLoader = TestUtils::getMainLoaderFromMainWindow();

  QSignalSpy spyCoreStarted(coreManager->getHandlers().get(), &CoreHandlers::coreStarted);
  QSignalSpy spyLoaderReady(mainLoader, SIGNAL(loaded()));

  if (!coreManager->started())
    QVERIFY(spyCoreStarted.wait(5000));

  if (!QQmlProperty::read(mainLoader, "item").value<QObject *>())
    QVERIFY(spyLoaderReady.wait(1000));

  QVERIFY(QTest::qWaitForWindowExposed(App::getInstance()->getMainWindow()));
}
