#include <cstdlib>

#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main (int argc, char *argv[]) {
  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine(QUrl("qrc:/ui/main_window.qml"));

  if (engine.rootObjects().isEmpty())
    exit(EXIT_FAILURE);

  exit(app.exec());
}
