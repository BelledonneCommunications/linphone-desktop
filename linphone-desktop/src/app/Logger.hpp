#ifndef LOGGER_H_
#define LOGGER_H_

#include <QtGlobal>

// =============================================================================

class Logger {
public:
  static void init ();

private:
  Logger () = default;

  bool m_display_core_logs = false;

  static Logger *m_instance;
};

#endif // LOGGER_H_
