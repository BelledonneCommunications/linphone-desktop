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
