/*
 * TestUtils.cpp
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

#ifdef QT_NO_DEBUG
  #undef QT_NO_DEBUG
#endif // ifdef QT_NO_DEBUG

#include <QTest>
#include <QtGlobal>

#include "../app/App.hpp"

#include "TestUtils.hpp"

// =============================================================================

void TestUtils::executeKeySequence (QQuickWindow *window, QKeySequence sequence) {
  for (int i = 0; i < sequence.count(); ++i) {
    int key = sequence[i];
    QTest::keyClick(
      window,
      Qt::Key(key & ~Qt::KeyboardModifierMask),
      Qt::KeyboardModifiers(key & Qt::KeyboardModifierMask)
    );
  }
}

// -----------------------------------------------------------------------------

static void printItemTree (const QQuickItem *item, QString &output, int spaces) {
  output.append(QString().leftJustified(spaces, ' '));
  output.append(item->metaObject()->className());
  output.append("\n");

  for (const auto &childItem : item->childItems())
    printItemTree(childItem, output, spaces + 2);
}

void TestUtils::printItemTree (const QQuickItem *item) {
  QString output;
  ::printItemTree(item, output, 0);
  qInfo().noquote() << output;
}

// -----------------------------------------------------------------------------

QQuickItem *TestUtils::getMainLoaderFromMainWindow () {
  QList<QQuickItem *> items = App::getInstance()->getMainWindow()->contentItem()->childItems();
  Q_ASSERT(!items.empty());

  for (int i = 0; i < 3; ++i) {
    items = items.at(0)->childItems();
    Q_ASSERT(!items.empty());
  }

  QQuickItem *loader = items.at(0);
  Q_ASSERT(!strcmp(loader->metaObject()->className(), "QQuickLoader"));

  return loader;
}

// -----------------------------------------------------------------------------

QQuickItem *TestUtils::getVirtualWindowContent (const QQuickWindow *window) {
  Q_CHECK_PTR(window);

  QList<QQuickItem *> items = window->contentItem()->childItems();
  Q_ASSERT(!items.empty());

  items = items.at(0)->childItems();
  Q_ASSERT(!items.empty());

  items = items.at(0)->childItems();
  Q_ASSERT(items.size() == 2);

  const char name[] = "VirtualWindow_QMLTYPE_";
  QQuickItem *virtualWindow = items.at(1);
  Q_ASSERT(!strncmp(virtualWindow->metaObject()->className(), name, sizeof name - 1));

  items = virtualWindow->childItems();
  Q_ASSERT(items.size() == 2);

  items = items.at(1)->childItems();
  return items.empty() ? nullptr : items.at(0);
}
