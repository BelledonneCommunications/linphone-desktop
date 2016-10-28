#include <QDateTime>

#include "logger.hpp"

#ifdef __linux__
  #define RED "\x1B[1;31m"
  #define GREEN "\x1B[1;32m"
  #define BLUE "\x1B[1;34m"
  #define RESET "\x1B[0m"
#else
  #define RED ""
  #define GREEN ""
  #define BLUE ""
  #define RESET ""
#endif

// ===================================================================

void qmlLogger (QtMsgType type, const QMessageLogContext &context, const QString &msg) {
  QByteArray local_msg = msg.toLocal8Bit();
  QByteArray date_time = QDateTime::currentDateTime()
    .toString("HH:mm:ss").toLocal8Bit();

  switch (type) {
    case QtDebugMsg:
      fprintf(stderr, GREEN "[%s][Debug]" RESET "%s:%u: %s\n",
        date_time.constData(), context.file, context.line, local_msg.constData());
      break;
    case QtInfoMsg:
      fprintf(stderr, BLUE "[%s][Info]" RESET "%s:%u: %s\n",
        date_time.constData(), context.file, context.line, local_msg.constData());
      break;
    case QtWarningMsg:
      fprintf(stderr, RED "[%s][Warning]" RESET "%s:%u: %s\n",
        date_time.constData(), context.file, context.line, local_msg.constData());
      break;
    case QtCriticalMsg:
      fprintf(stderr, RED "[%s][Critical]" RESET "%s:%u: %s\n",
        date_time.constData(), context.file, context.line, local_msg.constData());
      break;
    case QtFatalMsg:
      fprintf(stderr, RED "[%s][Fatal]" RESET "%s:%u: %s\n",
        date_time.constData(), context.file, context.line, local_msg.constData());
      abort();
  }
}
