/*
 * Units.cpp
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
 *  Created on: June 8, 2017
 *      Author: Ronan Abhamon
 */

#include "Units.hpp"

// =============================================================================

Units::Units (QObject *parent) : QObject(parent) {}

float Units::getDp () const {
  #ifdef Q_OS_MACOS
    return 96.0 / 72.0;
  #endif // ifdef Q_OS_MACOS

  return 1.0;
}
