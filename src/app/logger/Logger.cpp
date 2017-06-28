/*
 * Logger.cpp
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

#include <bctoolbox/logging.h>
#include <linphone/linphonecore.h>
#include <QDateTime>
#include <QThread>

#include "../../components/settings/SettingsModel.hpp"
#include "../../utils/Utils.hpp"

#include "Logger.hpp"

#if defined(__linux__) || defined(__APPLE__)
  #define BLUE "\x1B[1;34m"
  #define YELLOW "\x1B[1;33m"
  #define GREEN "\x1B[1;32m"
  #define PURPLE "\x1B[1;35m"
  #define RED "\x1B[1;31m"
  #define RESET "\x1B[0m"
#else
  #define BLUE ""
  #define YELLOW ""
  #define GREEN ""
  #define PURPLE ""
  #define RED ""
  #define RESET ""
#endif // if defined(__linux__) || defined(__APPLE__)

#define QT_DOMAIN "qt"

#define MAX_LOGS_COLLECTION_SIZE 10485760 /* 10MB. */

#define SRC_PATTERN "/linphone-desktop/src/"

using namespace std;

// =============================================================================

QMutex Logger::mMutex;

Logger *Logger::mInstance = nullptr;

// -----------------------------------------------------------------------------

inline QByteArray getFormattedCurrentTime () {
  return QDateTime::currentDateTime().toString("HH:mm:ss:zzz").toLocal8Bit();
}

// -----------------------------------------------------------------------------

static void linphoneLog (const char *domain, OrtpLogLevel type, const char *fmt, va_list args) {
  const char *format;

  if (type == ORTP_DEBUG)
    format = GREEN "[%s][Debug]" YELLOW "Core:%s: " RESET "%s\n";
  else if (type == ORTP_TRACE)
    format = BLUE "[%s][Trace]" YELLOW "Core:%s: " RESET "%s\n";
  else if (type == ORTP_MESSAGE)
    format = BLUE "[%s][Info]" YELLOW "Core:%s: " RESET "%s\n";
  else if (type == ORTP_WARNING)
    format = RED "[%s][Warning]" YELLOW "Core:%s: " RESET "%s\n";
  else if (type == ORTP_ERROR)
    format = RED "[%s][Error]" YELLOW "Core:%s: " RESET "%s\n";
  else if (type == ORTP_FATAL)
    format = RED "[%s][Fatal]" YELLOW "Core:%s: " RESET "%s\n";
  else
    return;

  QByteArray dateTime = ::getFormattedCurrentTime();
  char *msg = bctbx_strdup_vprintf(fmt, args);

  fprintf(stderr, format, dateTime.constData(), domain ? domain : "linphone", msg);

  bctbx_free(msg);

  if (type == ORTP_FATAL)
    abort();
}

// -----------------------------------------------------------------------------

void Logger::log (QtMsgType type, const QMessageLogContext &context, const QString &msg) {
  const char *format;
  BctbxLogLevel level;

  if (type == QtDebugMsg) {
    format = GREEN "[%s][%p][Debug]" PURPLE "%s" RESET "%s\n";
    level = BCTBX_LOG_DEBUG;
  } else if (type == QtInfoMsg) {
    format = BLUE "[%s][%p][Info]" PURPLE "%s" RESET "%s\n";
    level = BCTBX_LOG_MESSAGE;
  } else if (type == QtWarningMsg) {
    format = RED "[%s][%p][Warning]" PURPLE "%s" RESET "%s\n";
    level = BCTBX_LOG_WARNING;
  } else if (type == QtCriticalMsg) {
    format = RED "[%s][%p][Critical]" PURPLE "%s" RESET "%s\n";
    level = BCTBX_LOG_ERROR;
  } else if (type == QtFatalMsg) {
    format = RED "[%s][%p][Fatal]" PURPLE "%s" RESET "%s\n";
    level = BCTBX_LOG_FATAL;
  } else
    return;

  const char *contextStr = "";

  #ifdef QT_MESSAGELOGCONTEXT
    QByteArray contextArr;
    {
      const char *file = context.file;
      const char *pos = file ? ::Utils::rstrstr(file, SRC_PATTERN) : file;

      contextArr = QStringLiteral("%1:%2: ")
        .arg(pos ? pos + sizeof(SRC_PATTERN) - 1 : file)
        .arg(context.line)
        .toLocal8Bit();
      contextStr = contextArr.constData();
    }
  #else
    (void)context;
  #endif // ifdef QT_MESSAGELOGCONTEXT

  QByteArray localMsg = msg.toLocal8Bit();
  QByteArray dateTime = ::getFormattedCurrentTime();

  mMutex.lock();

  fprintf(stderr, format, dateTime.constData(), QThread::currentThread(), contextStr, localMsg.constData());
  bctbx_log(QT_DOMAIN, level, "QT: %s%s", contextStr, localMsg.constData());

  mMutex.unlock();

  if (type == QtFatalMsg)
    abort();
}

// -----------------------------------------------------------------------------

void Logger::enable (bool status) {
  linphone_core_enable_log_collection(status ? LinphoneLogCollectionEnabled : LinphoneLogCollectionDisabled);
}

void Logger::init (const shared_ptr<linphone::Config> &config) {
  if (mInstance)
    return;

  const QString folder = SettingsModel::getLogsFolder(config);
  Q_ASSERT(!folder.isEmpty());

  mInstance = new Logger();

  qInstallMessageHandler(Logger::log);

  linphone_core_set_log_level(ORTP_MESSAGE);
  linphone_core_set_log_handler([](const char *domain, OrtpLogLevel type, const char *fmt, va_list args) {
      if (mInstance->isVerbose())
        ::linphoneLog(domain, type, fmt, args);
    });

  linphone_core_set_log_collection_path(::Utils::appStringToCoreString(folder).c_str());

  linphone_core_set_log_collection_max_file_size(MAX_LOGS_COLLECTION_SIZE);
  mInstance->enable(SettingsModel::getLogsEnabled(config));
}
