/*
 * ScreenSaverDBusLinux.cpp
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

#include <QCoreApplication>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QDebug>

#include "ScreenSaverDBus.hpp"

// =============================================================================

namespace {
  constexpr char ServiceName[] = "org.freedesktop.ScreenSaver";
  constexpr char ServicePath[] = "/ScreenSaver";
}

ScreenSaverDBus::ScreenSaverDBus (QObject *parent) : QObject(parent), mBus(ServiceName, ServicePath, ServiceName) {}

ScreenSaverDBus::~ScreenSaverDBus () {
  setScreenSaverStatus(true);
}

bool ScreenSaverDBus::getScreenSaverStatus () const {
  return mScreenSaverStatus;
}

void ScreenSaverDBus::setScreenSaverStatus (bool status) {
  if (status == mScreenSaverStatus)
    return;

  if (status) {
    QDBusMessage reply(mBus.call("UnInhibit", mToken));
    if (reply.type() == QDBusMessage::ErrorMessage) {
      qWarning() << QStringLiteral("Uninhibit screen saver failed: `%1: %2`.")
        .arg(reply.errorName()).arg(reply.errorMessage());
      return;
    } else
      qInfo("Uninhibit screen saver.");

    mToken = uint32_t(reply.arguments().first().toULongLong());
    mScreenSaverStatus = status;
    emit screenSaverStatusChanged(mScreenSaverStatus);
    return;
  }

  QDBusMessage reply(mBus.call("Inhibit", QCoreApplication::applicationName(), "Inhibit asked for video stream"));
  if (reply.type() == QDBusMessage::ErrorMessage) {
    if (reply.errorName() != QLatin1String("org.freedesktop.DBus.Error.ServiceUnknown"))
      qWarning() << QStringLiteral("Inhibit screen saver failed: `%1: %2`.")
        .arg(reply.errorName()).arg(reply.errorMessage());
    return;
  } else
    qInfo("Inhibit screen saver.");

  mScreenSaverStatus = status;
  emit screenSaverStatusChanged(mScreenSaverStatus);
}
