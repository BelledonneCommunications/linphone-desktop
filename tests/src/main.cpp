#include <cstdlib>

#include <QMenu>
#include <QQmlApplicationEngine>
#include <QSystemTrayIcon>
#include <QtDebug>

#include "app.hpp"

// ===================================================================

void createSystemTrayIcon (QQmlApplicationEngine &engine) {
  QObject *root = engine.rootObjects().at(0);
  QMenu *menu = new QMenu();
  QSystemTrayIcon *tray_icon = new QSystemTrayIcon(root);

  QAction *quitAction = new QAction(QObject::tr("Quit"), root);
  root->connect(quitAction, &QAction::triggered, qApp, &QCoreApplication::quit);

  QAction *restoreAction = new QAction(QObject::tr("Restore"), root);
  root->connect(restoreAction, SIGNAL(triggered()), root, SLOT(showNormal()));

  menu->addAction(restoreAction);
  menu->addSeparator();
  menu->addAction(quitAction);

  tray_icon->setContextMenu(menu);
  tray_icon->setIcon(QIcon(":/imgs/linphone.png"));
  tray_icon->show();

  return;
}

int main (int argc, char *argv[]) {
  App app(argc, argv);
  QQmlApplicationEngine engine(QUrl("qrc:/ui/views/mainWindow/mainWindow.qml"));

  if (engine.rootObjects().isEmpty())
    return EXIT_FAILURE;

  if (!QSystemTrayIcon::isSystemTrayAvailable())
    qWarning() << "System tray not found on this system.";
  else
    createSystemTrayIcon(engine);

  return app.exec();
}
