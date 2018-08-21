/*
 * MessageCountNotifierSystemTrayIcon.hpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
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
#include <QTimer>
#include <QWindow>

#include "app/App.hpp"
#include "utils/LinphoneUtils.hpp"
#include "utils/Utils.hpp"

#include "MessageCountNotifierSystemTrayIcon.hpp"

// =============================================================================

namespace {
  constexpr int IconWidth = 256;
  constexpr int IconHeight = 256;

  constexpr char IconCounterBackgroundColor[] = "#FF3C31";
  constexpr int IconCounterBackgroundRadius = 100;
  constexpr int IconCounterBlinkInterval = 1000;
  constexpr char IconCounterTextColor[] = "#FFFBFA";
  constexpr int IconCounterTextPixelSize = 144;
}

MessageCountNotifier::MessageCountNotifier (QObject *parent) : AbstractMessageCountNotifier(parent) {
  QSvgRenderer renderer((QString(LinphoneUtils::WindowIconPath)));
  if (!renderer.isValid())
    qFatal("Invalid SVG Image.");

  QPixmap buf(IconWidth, IconHeight);
  buf.fill(QColor(Qt::transparent));

  QPainter painter(&buf);
  renderer.render(&painter);

  mBuf = new QPixmap(buf);
  mBufWithCounter = new QPixmap();

  mBlinkTimer = new QTimer(this);
  mBlinkTimer->setInterval(IconCounterBlinkInterval);
  QObject::connect(mBlinkTimer, &QTimer::timeout, this, &MessageCountNotifier::update);

  Utils::connectOnce(
    App::getInstance(), &App::focusWindowChanged,
    this, &MessageCountNotifier::updateUnreadMessageCount
  );
}

MessageCountNotifier::~MessageCountNotifier () {
  delete mBuf;
  delete mBufWithCounter;
}

void MessageCountNotifier::notifyUnreadMessageCount (int n) {
  QSystemTrayIcon *sysTrayIcon = App::getInstance()->getSystemTrayIcon();
  if (!sysTrayIcon)
    return;

  if (!n) {
    mBlinkTimer->stop();
    sysTrayIcon->setIcon(QIcon(*mBuf));
    return;
  }

  *mBufWithCounter = *mBuf;
  QPainter p(mBufWithCounter);

  const int width = mBufWithCounter->width();
  const int height = mBufWithCounter->height();

  // Draw background.
  {
    p.setBrush(QColor(IconCounterBackgroundColor));
    p.drawEllipse(QPointF(width / 2, height / 2), IconCounterBackgroundRadius, IconCounterBackgroundRadius);
  }

  // Draw text.
  {
    QFont font = p.font();
    font.setPixelSize(IconCounterTextPixelSize);

    p.setFont(font);
    p.setPen(QPen(QColor(IconCounterTextColor), 1));
    p.drawText(QRect(0, 0, width, height), Qt::AlignCenter, QString::number(n));
  }

  // Change counter.
  mBlinkTimer->stop();
  mBlinkTimer->start();
  mDisplayCounter = true;
  update();
}

void MessageCountNotifier::update () {
  QSystemTrayIcon *sysTrayIcon = App::getInstance()->getSystemTrayIcon();
  Q_CHECK_PTR(sysTrayIcon);
  sysTrayIcon->setIcon(QIcon(mDisplayCounter ? *mBufWithCounter : *mBuf));
  mDisplayCounter = !mDisplayCounter;
}
