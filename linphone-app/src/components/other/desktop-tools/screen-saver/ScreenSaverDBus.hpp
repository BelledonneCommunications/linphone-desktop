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

#ifndef SCREEN_SAVER_DBUS_H_
#define SCREEN_SAVER_DBUS_H_

#include <QDBusInterface>

// =============================================================================

class QDBusPendingCallWatcher;

class ScreenSaverDBus : public QObject {
  Q_OBJECT;

public:
  ScreenSaverDBus (QObject *parent = Q_NULLPTR);
  ~ScreenSaverDBus ();

  bool getScreenSaverStatus () const;
  void setScreenSaverStatus (bool status);

signals:
  void screenSaverStatusChanged (bool status);

private:
  bool mScreenSaverStatus = true;

  QDBusInterface mBus;
  uint32_t mToken;
};

#endif // SCREEN_SAVER_DBUS_H_
