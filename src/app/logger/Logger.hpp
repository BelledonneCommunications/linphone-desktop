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

#ifndef LOGGER_H_
#define LOGGER_H_

#include <memory>

#include <QMutex>

// =============================================================================

namespace linphone {
  class Config;
  class LoggingService;
}

class Logger {
public:
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

  std::shared_ptr<linphone::LoggingService> mLoggingService;
};

#endif // LOGGER_H_
