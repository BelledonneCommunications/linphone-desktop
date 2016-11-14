#include "app/App.hpp"
#include "app/Logger.hpp"

// ===================================================================

int main (int argc, char *argv[]) {
  qInstallMessageHandler(qmlLogger);

  QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  App app(argc, argv);

  // Run!
  return app.exec();
}
