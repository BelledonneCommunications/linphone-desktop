/*
 * DesktopToolsMacOs.cpp
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

#include "DesktopToolsMacOs.hpp"

// =============================================================================

extern "C" bool enableScreenSaverMacOs ();
extern "C" bool disableScreenSaverMacOs ();

DesktopTools::DesktopTools (QObject *parent) : QObject(parent) {}

DesktopTools::~DesktopTools () {
  setScreenSaverStatus(true);
}

bool DesktopTools::getScreenSaverStatus () const {
  return mScreenSaverStatus;
}

void DesktopTools::setScreenSaverStatus (bool status) {
  if (status != mScreenSaverStatus && (status ? enableScreenSaverMacOs() : disableScreenSaverMacOs())) {
    mScreenSaverStatus = status;
    emit screenSaverStatusChanged(mScreenSaverStatus);
  }
}
