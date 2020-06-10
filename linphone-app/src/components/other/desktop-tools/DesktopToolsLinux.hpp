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

#ifndef DESKTOP_TOOLS_LINUX_H_
#define DESKTOP_TOOLS_LINUX_H_

#include "components/other/desktop-tools/screen-saver/ScreenSaverDBus.hpp"
#include "components/other/desktop-tools/screen-saver/ScreenSaverXdg.hpp"

// =============================================================================

class DesktopTools : public QObject {
  Q_OBJECT;

  Q_PROPERTY(bool screenSaverStatus READ getScreenSaverStatus WRITE setScreenSaverStatus NOTIFY screenSaverStatusChanged);

public:
  DesktopTools (QObject *parent = Q_NULLPTR) : QObject(parent) {}
  ~DesktopTools ();

  bool getScreenSaverStatus () const;
  void setScreenSaverStatus (bool status);

  static void init(){}
  static void applicationStateChanged(Qt::ApplicationState){};

signals:
  void screenSaverStatusChanged (bool status);

private:
  bool mScreenSaverStatus = true;

  ScreenSaverDBus screenSaverDBus;
  ScreenSaverXdg screenSaverXdg;
};

#endif // DESKTOP_TOOLS_LINUX_H_
