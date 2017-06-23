/*
 * Logger.hpp
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

#ifndef LOGGER_H_
#define LOGGER_H_

#include <linphone++/linphone.hh>
#include <QMutex>

// =============================================================================

class Logger {
public:
  ~Logger () = default;

  bool isVerbose () const {
    return mVerbose;
  }

  void setVerbose (bool verbose) {
    mVerbose = verbose;
  }

  void enable (bool status);

  static void init (const std::shared_ptr<linphone::Config> &config);

  static Logger *getInstance () {
    return mInstance;
  }

private:
  Logger () = default;

  static void log (QtMsgType type, const QMessageLogContext &context, const QString &msg);

  bool mVerbose = false;

  static QMutex mMutex;
  static Logger *mInstance;
};

#endif // LOGGER_H_
