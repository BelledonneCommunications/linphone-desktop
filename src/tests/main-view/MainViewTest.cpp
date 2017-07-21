/*
 * MainViewTest.cpp
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
 *  Created on: July 18, 2017
 *      Author: Ronan Abhamon
 */

#include <QQmlProperty>
#include <QSignalSpy>
#include <QTest>

#include "../../app/App.hpp"
#include "../TestUtils.hpp"

#include "MainViewTest.hpp"

// =============================================================================

void MainViewTest::showAboutPopup () {
  QQuickWindow *mainWindow = App::getInstance()->getMainWindow();

  // Open popup.
  TestUtils::executeKeySequence(mainWindow, QKeySequence::HelpContents);

  CHECK_VIRTUAL_WINDOW_CONTENT_INFO(mainWindow, "DialogPlus_QMLTYPE_", "__about");

  // Close popup.
  QTest::mouseClick(mainWindow, Qt::LeftButton, Qt::KeyboardModifiers(), QPoint(476, 392));
  QVERIFY(!TestUtils::getVirtualWindowContent(mainWindow));
}

// -----------------------------------------------------------------------------

void MainViewTest::showManageAccountsPopup () {
  QQuickWindow *mainWindow = App::getInstance()->getMainWindow();

  // Open popup.
  QTest::mouseClick(mainWindow, Qt::LeftButton, Qt::KeyboardModifiers(), QPoint(100, 35));

  CHECK_VIRTUAL_WINDOW_CONTENT_INFO(mainWindow, "DialogPlus_QMLTYPE_", "__manageAccounts");

  // Close popup.
  QTest::mouseClick(mainWindow, Qt::LeftButton, Qt::KeyboardModifiers(), QPoint(476, 392));
  QVERIFY(!TestUtils::getVirtualWindowContent(mainWindow));
}

// -----------------------------------------------------------------------------

void MainViewTest::showSettingsWindow () {
  App *app = App::getInstance();

  // Open window.
  QTest::keyClick(app->getMainWindow(), Qt::Key_P, Qt::ControlModifier);
  QQuickWindow *settingsWindow = app->getSettingsWindow();

  QVERIFY(QTest::qWaitForWindowExposed(settingsWindow));

  // Hide window.
  TestUtils::executeKeySequence(settingsWindow, QKeySequence::Close);
  QVERIFY(!settingsWindow->isVisible());
}

// -----------------------------------------------------------------------------

void MainViewTest::testMainMenuEntries_data () {
  QTest::addColumn<int>("y");
  QTest::addColumn<QString>("source");

  QTest::newRow("home view 1") << 100 << "qrc:/ui/views/App/Main/Home.qml";
  QTest::newRow("contacts view 1") << 150 << "qrc:/ui/views/App/Main/Contacts.qml";
  QTest::newRow("home view 2") << 100 << "qrc:/ui/views/App/Main/Home.qml";
  QTest::newRow("contacts view 2") << 150 << "qrc:/ui/views/App/Main/Contacts.qml";
}

void MainViewTest::testMainMenuEntries () {
  QQuickWindow *mainWindow = App::getInstance()->getMainWindow();

  QQuickItem *contentLoader = mainWindow->findChild<QQuickItem *>("__contentLoader");
  QVERIFY(contentLoader);

  QSignalSpy spyLoaderReady(contentLoader, SIGNAL(loaded()));

  QFETCH(int, y);
  QTest::mouseClick(mainWindow, Qt::LeftButton, Qt::KeyboardModifiers(), QPoint(110, y));
  QVERIFY(spyLoaderReady.count() == 1);

  QFETCH(QString, source);
  QCOMPARE(QQmlProperty::read(contentLoader, "source").toString(), source);
}
