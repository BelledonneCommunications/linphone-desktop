#include <cstdlib>

#include <QQmlApplicationEngine>

#include "app.hpp"

// ===================================================================

int main (int argc, char *argv[]) {
  App app(argc, argv);
  QQmlApplicationEngine engine(QUrl("qrc:/ui/views/main_window.qml"));

  if (engine.rootObjects().isEmpty())
    return EXIT_FAILURE;

  return app.exec();
}
