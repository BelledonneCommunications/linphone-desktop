#include <cstdlib>

#include <QQmlApplicationEngine>

#include "app.hpp"

int main (int argc, char *argv[]) {
  // Init main window.
  App app(argc, argv);
  QQmlApplicationEngine engine(QUrl("qrc:/ui/main_window.qml"));

  // File not found.
  if (engine.rootObjects().isEmpty())
    exit(EXIT_FAILURE);

  exit(app.exec());
}
