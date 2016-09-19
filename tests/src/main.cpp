#include <cstdlib>

#include <QMenu>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QSystemTrayIcon>
#include <QtDebug>

#include "app.hpp"

// ===================================================================

int exec (App &app, QQmlApplicationEngine &engine) {
  if (!QSystemTrayIcon::isSystemTrayAvailable())
    qWarning() << "System tray not found on this system.";

  QQuickWindow *root = qobject_cast<QQuickWindow *>(engine.rootObjects().at(0));
  QMenu *menu = new QMenu();
  QSystemTrayIcon *tray_icon = new QSystemTrayIcon(root);

  // Warning: Add global context trayIcon for all views!
  engine.rootContext()->setContextProperty("trayIcon", tray_icon);

  // trayIcon: Right click actions.
  QAction *quitAction = new QAction(QObject::tr("Quit"), root);
  root->connect(quitAction, &QAction::triggered, qApp, &QCoreApplication::quit);

  QAction *restoreAction = new QAction(QObject::tr("Restore"), root);
  root->connect(restoreAction, &QAction::triggered, root, &QQuickWindow::showNormal);

  // trayIcon: Left click actions.
  root->connect(tray_icon, &QSystemTrayIcon::activated, [&root](QSystemTrayIcon::ActivationReason reason) {
    if (reason == QSystemTrayIcon::Trigger)
      root->requestActivate();
    else if (reason == QSystemTrayIcon::DoubleClick)
      root->showNormal();
  });

  // Build trayIcon menu.
  menu->addAction(restoreAction);
  menu->addSeparator();
  menu->addAction(quitAction);

  tray_icon->setContextMenu(menu);
  tray_icon->setIcon(QIcon(":/imgs/linphone.png"));
  tray_icon->setToolTip("Linphone");
  tray_icon->show();

  // RUN.
  return app.exec();
}

int main (int argc, char *argv[]) {
  App app(argc, argv);
  QQmlApplicationEngine engine(QUrl("qrc:/ui/views/mainWindow/mainWindow.qml"));

  if (engine.rootObjects().isEmpty())
    return EXIT_FAILURE;

  return exec(app, engine);
}
