/*
 * DesktopToolsMacOs.hpp
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

#ifndef DESKTOP_TOOLS_MAC_OS_H_
#define DESKTOP_TOOLS_MAC_OS_H_

#include <QObject>

// =============================================================================

class DesktopTools : public QObject {
  Q_OBJECT;

  Q_PROPERTY(bool screenSaverStatus READ getScreenSaverStatus WRITE setScreenSaverStatus NOTIFY screenSaverStatusChanged);

public:
  DesktopTools (QObject *parent = Q_NULLPTR);
  ~DesktopTools ();

  bool getScreenSaverStatus () const;
  void setScreenSaverStatus (bool status);

signals:
  void screenSaverStatusChanged (bool status);

private:
  bool mScreenSaverStatus = true;
};

#endif // DESKTOP_TOOLS_MAC_OS_H_
