#include "app/App.hpp"
#include "app/Logger.hpp"

// =============================================================================

int main (int argc, char *argv[]) {
  Logger::init();

  // Force shader version 2.0.
  QSurfaceFormat fmt;
  fmt.setVersion(2, 0);
  QSurfaceFormat::setDefaultFormat(fmt);

  QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  App::init(argc, argv);

  // Run!
  return App::getInstance()->exec();
}
