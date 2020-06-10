/*
 * ScreenSaverMacOS.m
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
 *  Created on: August 3, 2018
 *      Author: Ronan Abhamon
 */

#import <IOKit/pwr_mgt/IOPMLib.h>

// =============================================================================

static bool ScreenSaverEnabled = true;
static IOPMAssertionID AssertionID;

bool enableScreenSaverMacOs () {
  if (ScreenSaverEnabled)
    return true;

  ScreenSaverEnabled = IOPMAssertionRelease(AssertionID) == kIOReturnSuccess;
  return ScreenSaverEnabled;
}

bool disableScreenSaverMacOs () {
  if (!ScreenSaverEnabled)
    return true;

  ScreenSaverEnabled = IOPMAssertionCreateWithName(
    kIOPMAssertionTypeNoDisplaySleep,
    kIOPMAssertionLevelOn,
    CFSTR("Inhibit asked for video stream"),
    &AssertionID
  ) != kIOReturnSuccess;
  return !ScreenSaverEnabled;
}
