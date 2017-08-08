/*
 * MessagesCountNotifierLinux.hpp
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
 *  Created on: August 7, 2017
 *      Author: Ronan Abhamon
 */

#include <QIcon>
#include <QPainter>
#include <QSvgRenderer>
#include <QSystemTrayIcon>

#include "../../../app/App.hpp"
#include "../../../utils/LinphoneUtils.hpp"

#include "MessagesCountNotifierLinux.hpp"

#define ICON_WIDTH 256
#define ICON_HEIGHT 256

#define ICON_COUNTER_BACKGROUND_COLOR "#FF3C31"
#define ICON_COUNTER_BACKGROUND_RADIUS 100
#define ICON_COUNTER_TEXT_COLOR "#FFFBFA"
#define ICON_COUNTER_TEXT_PIXEL_SIZE 144

// =============================================================================

MessagesCountNotifier::MessagesCountNotifier (QObject *parent) : AbstractMessagesCountNotifier(parent) {
  QSvgRenderer renderer(QStringLiteral(WINDOW_ICON_PATH));
  if (!renderer.isValid())
    qFatal("Invalid SVG Image.");

  QPixmap buf(ICON_WIDTH, ICON_HEIGHT);
  buf.fill(QColor(Qt::transparent));

  QPainter painter(&buf);
  renderer.render(&painter);

  mBuf = new QPixmap(buf);
}

MessagesCountNotifier::~MessagesCountNotifier () {
  delete mBuf;
}

void MessagesCountNotifier::notifyUnreadMessagesCount (int n) {
  QSystemTrayIcon *sysTrayIcon = App::getInstance()->getSystemTrayIcon();
  if (!sysTrayIcon)
    return;

  if (!n) {
    sysTrayIcon->setIcon(QIcon(*mBuf));
    return;
  }

  QPixmap buf(*mBuf);
  QPainter p(&buf);

  const int width = buf.width();
  const int height = buf.height();

  // Draw background.
  {
    p.setBrush(QColor(ICON_COUNTER_BACKGROUND_COLOR));
    p.drawEllipse(QPointF(width / 2, height / 2), ICON_COUNTER_BACKGROUND_RADIUS, ICON_COUNTER_BACKGROUND_RADIUS);
  }

  // Draw text.
  {
    QFont font = p.font();
    font.setPixelSize(ICON_COUNTER_TEXT_PIXEL_SIZE);

    p.setFont(font);
    p.setPen(QPen(QColor(ICON_COUNTER_TEXT_COLOR), 1));
    p.drawText(QRect(0, 0, width, height), Qt::AlignCenter, QString::number(n));
  }

  sysTrayIcon->setIcon(QIcon(buf));
}
