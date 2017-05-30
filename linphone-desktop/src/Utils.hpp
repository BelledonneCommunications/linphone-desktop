/*
 * utils.hpp
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
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#ifndef UTILS_H_
#define UTILS_H_

#include <QString>

// =============================================================================

namespace Utils {
  inline QString coreStringToAppString (const std::string &string) {
    return QString::fromLocal8Bit(string.c_str(), static_cast<int>(string.size()));
  }

  inline std::string appStringToCoreString (const QString &string) {
    return string.toLocal8Bit().constData();
  }

  // Reverse function of strstr.
  char *rstrstr (const char *a, const char *b);
}

#endif // UTILS_H_
