#include "app/App.hpp"
#include "app/Logger.hpp"

// =============================================================================

int main (int argc, char *argv[]) {
  Logger::init();

  QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  App::init(argc, argv);

  // Run!
  return App::getInstance()->exec();
}
