/*
 * ScreenSaverXdg.cpp
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
 *  Created on: June 21, 2018
 *      Author: Ronan Abhamon
 */

#include <QProcess>

#include "ScreenSaverXdg.hpp"

// =============================================================================

namespace {
  constexpr char Program[] = "xdg-screensaver";
  const QStringList Arguments{"reset"};

  constexpr int Interval = 30000;
}

ScreenSaverXdg::ScreenSaverXdg (QObject *parent) : QObject(parent) {
  mTimer.setInterval(Interval);
  QObject::connect(&mTimer, &QTimer::timeout, []() {
    // Legacy for systems without DBus screensaver.
    QProcess::startDetached(Program, Arguments);
  });
}

bool ScreenSaverXdg::getScreenSaverStatus () const {
  return !mTimer.isActive();
}

void ScreenSaverXdg::setScreenSaverStatus (bool status) {
  if (status == !mTimer.isActive())
    return;

  if (status)
    mTimer.stop();
  else
    mTimer.start();

  emit screenSaverStatusChanged(status);
}
