/*
 * TestUtils.hpp
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

#ifndef TEST_UTILS_H_
#define TEST_UTILS_H_

#include <QQuickItem>
#include <QQuickWindow>

// =============================================================================

#define CHECK_VIRTUAL_WINDOW_CONTENT_INFO(WINDOW, TYPE, NAME) \
  do { \
    QQuickItem *virtualWindowContent = TestUtils::getVirtualWindowContent(WINDOW); \
    QVERIFY(virtualWindowContent); \
    QVERIFY(!strncmp(virtualWindowContent->metaObject()->className(), TYPE, sizeof TYPE - 1)); \
    QCOMPARE(virtualWindowContent->objectName(), QStringLiteral(NAME)); \
  } while (0)

namespace TestUtils {
  void executeKeySequence (QQuickWindow *window, QKeySequence sequence);

  void printItemTree (const QQuickItem *item);

  QQuickItem *getMainLoaderFromMainWindow ();

  QQuickItem *getVirtualWindowContent (const QQuickWindow *window);
}

#endif // ifndef TEST_UTILS_H_
