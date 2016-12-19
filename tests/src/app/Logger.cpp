#include <QDateTime>

#include "Logger.hpp"

#ifdef __linux__
  #define BLUE "\x1B[1;34m"
  #define GREEN "\x1B[1;32m"
  #define PURPLE "\x1B[1;35m"
  #define RED "\x1B[1;31m"
  #define RESET "\x1B[0m"
#else
  #define BLUE ""
  #define GREEN ""
  #define PURPLE ""
  #define RED ""
  #define RESET ""
#endif // ifdef __linux__

// =============================================================================

void logger (QtMsgType type, const QMessageLogContext &context, const QString &msg) {
  QByteArray local_msg = msg.toLocal8Bit();
  QByteArray date_time = QDateTime::currentDateTime()
    .toString("HH:mm:ss").toLocal8Bit();

  const char *context_file = "cpp";
  int context_line = 0;

  if (context.file && !context.function) {
    context_file = context.file;
    context_line = context.line;
  }

  if (type == QtDebugMsg)
    fprintf(
      stderr, GREEN "[%s][Debug]" PURPLE "%s:%u: " RESET "%s\n",
      date_time.constData(), context_file, context_line, local_msg.constData()
    );
  else if (type == QtInfoMsg)
    fprintf(
      stderr, BLUE "[%s][Info]" PURPLE "%s:%u: " RESET "%s\n",
      date_time.constData(), context_file, context_line, local_msg.constData()
    );
  else if (type == QtWarningMsg)
    fprintf(
      stderr, RED "[%s][Warning]" PURPLE "%s:%u: " RESET "%s\n",
      date_time.constData(), context_file, context_line, local_msg.constData()
    );
  else if (type == QtCriticalMsg)
    fprintf(
      stderr, RED "[%s][Critical]" PURPLE "%s:%u: " RESET "%s\n",
      date_time.constData(), context_file, context_line, local_msg.constData()
    );
  else if (type == QtFatalMsg) {
    fprintf(
      stderr, RED "[%s][Fatal]" PURPLE "%s:%u: " RESET "%s\n",
      date_time.constData(), context_file, context_line, local_msg.constData()
    );
    abort();
  }
}
