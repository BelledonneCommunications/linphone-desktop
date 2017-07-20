/*
 * AssistantViewTest.cpp
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
 *  Created on: July 20, 2017
 *      Author: Ronan Abhamon
 */

#include <QQmlProperty>
#include <QQuickItem>
#include <QSignalSpy>
#include <QTest>

#include "../../app/App.hpp"

#include "AssistantViewTest.hpp"

// =============================================================================

void AssistantViewTest::showAssistantView () {
  QQuickWindow *mainWindow = App::getInstance()->getMainWindow();

  // Ensure home view is selected.
  QQuickItem *contentLoader = mainWindow->findChild<QQuickItem *>("__contentLoader");
  QVERIFY(contentLoader);
  QTest::mouseClick(mainWindow, Qt::LeftButton, Qt::KeyboardModifiers(), QPoint(110, 100));

  // Show assistant view.
  QSignalSpy spyLoaderReady(contentLoader, SIGNAL(loaded()));
  QTest::mouseClick(mainWindow, Qt::LeftButton, Qt::KeyboardModifiers(), QPoint(705, 485));
  QVERIFY(spyLoaderReady.count() == 1);
  QCOMPARE(
    QQmlProperty::read(contentLoader, "source").toString(),
    QStringLiteral("qrc:/ui/views/App/Main/Assistant.qml")
  );
}
