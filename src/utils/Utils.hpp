/*
 * utils.hpp
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
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#ifndef UTILS_H_
#define UTILS_H_

#include <QObject>
#include <QString>

// =============================================================================

/*
 * Define telling g++ that a 'break' statement has been deliberately omitted
 * in switch block.
 */
#ifndef UTILS_NO_BREAK
  #if defined(__GNUC__) && __GNUC__ >= 7
    #define UTILS_NO_BREAK __attribute__((fallthrough))
  #else
    #define UTILS_NO_BREAK
  #endif // if defined(__GNUC__) && __GNUC__ >= 7
#endif // ifndef UTILS_NO_BREAK

namespace Utils {
  inline QString coreStringToAppString (const std::string &str) {
    return QString::fromLocal8Bit(str.c_str(), int(str.size()));
  }

  inline std::string appStringToCoreString (const QString &str) {
    return qPrintable(str);
  }

  // Reverse function of strstr.
  char *rstrstr (const char *a, const char *b);

  // Returns the same path given in parameter if `filePath` exists.
  // Otherwise returns a safe path with a unique number before the extension.
  QString getSafeFilePath (const QString &filePath, bool *soFarSoGood = nullptr);

  // Connect once to a member function.
  template<typename Func1, typename Func2>
  static inline QMetaObject::Connection connectOnce (
    typename QtPrivate::FunctionPointer<Func1>::Object *sender,
    Func1 signal,
    typename QtPrivate::FunctionPointer<Func2>::Object *receiver,
    Func2 slot
  ) {
    QMetaObject::Connection connection = QObject::connect(sender, signal, receiver, slot);
    QMetaObject::Connection *deleter = new QMetaObject::Connection();

    *deleter = QObject::connect(sender, signal, [connection, deleter] {
      QObject::disconnect(connection);
      QObject::disconnect(*deleter);
      delete deleter;
    });

    return connection;
  }

  // Connect once to a function.
  template<typename Func1, typename Func2>
  static inline QMetaObject::Connection connectOnce (
    typename QtPrivate::FunctionPointer<Func1>::Object *sender,
    Func1 signal,
    const QObject *receiver,
    Func2 slot
  ) {
    QMetaObject::Connection connection = QObject::connect(sender, signal, receiver, slot);
    QMetaObject::Connection *deleter = new QMetaObject::Connection();

    *deleter = QObject::connect(sender, signal, [connection, deleter] {
      QObject::disconnect(connection);
      QObject::disconnect(*deleter);
      delete deleter;
    });

    return connection;
  }
}

#endif // UTILS_H_
