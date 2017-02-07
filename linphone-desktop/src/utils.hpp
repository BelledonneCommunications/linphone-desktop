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

#include <QObject>
#include <QString>

// =============================================================================

namespace Utils {
  inline QString linphoneStringToQString (const std::string &string) {
    return QString::fromLocal8Bit(string.c_str(), static_cast<int>(string.size()));
  }

  inline std::string qStringToLinphoneString (const QString &string) {
    return string.toLocal8Bit().constData();
  }

  template<class T>
  T *findParentType (const QObject *object) {
    QObject *parent = object->parent();
    if (!parent)
      return nullptr;

    T *found = qobject_cast<T *>(parent);
    if (found)
      return found;

    return findParentType<T>(parent);
  }
}

#endif // UTILS_H_
