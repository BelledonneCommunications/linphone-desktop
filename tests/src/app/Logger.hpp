#ifndef LOGGER_H_
#define LOGGER_H_

#include <QtGlobal>

void qmlLogger (QtMsgType type, const QMessageLogContext &context, const QString &msg);

#endif // LOGGER_H_
