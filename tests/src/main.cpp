#include <cstdlib>

#include <QMenu>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QSystemTrayIcon>
#include <QtDebug>

#include "app.hpp"
#include "models/notification/NotificationModel.hpp"

// ===================================================================

int exec (App &app, QQmlApplicationEngine &engine) {
  if (!QSystemTrayIcon::isSystemTrayAvailable())
    qWarning() << "System tray not found on this system.";

  QQuickWindow *root = qobject_cast<QQuickWindow *>(engine.rootObjects().at(0));
  QMenu *menu = new QMenu();
  QSystemTrayIcon *tray_icon = new QSystemTrayIcon(root);

  // trayIcon: Right click actions.
  QAction *quit_action = new QAction("Quit", root);
  root->connect(quit_action, &QAction::triggered, qApp, &QCoreApplication::quit);

  QAction *restore_action = new QAction("Restore", root);
  root->connect(restore_action, &QAction::triggered, root, &QQuickWindow::showNormal);

  // trayIcon: Left click actions.
  root->connect(tray_icon, &QSystemTrayIcon::activated, [&root](QSystemTrayIcon::ActivationReason reason) {
    if (reason == QSystemTrayIcon::Trigger) {
      if (root->visibility() == QWindow::Hidden)
        root->showNormal();
      else
        root->hide();
    }
  });

  // Build trayIcon menu.
  menu->addAction(restore_action);
  menu->addSeparator();
  menu->addAction(quit_action);

  tray_icon->setContextMenu(menu);
  tray_icon->setIcon(QIcon(":/imgs/linphone.png"));
  tray_icon->setToolTip("Linphone");
  tray_icon->show();

  // Warning: Add global context Notification for all views!
  NotificationModel notification;
  engine.rootContext()->setContextProperty("Notification", &notification);

  // Run.
  return app.exec();
}

int main (int argc, char *argv[]) {
  App app(argc, argv);
  QQmlApplicationEngine engine(QUrl("qrc:/ui/views/mainWindow/mainWindow.qml"));

  if (engine.rootObjects().isEmpty())
    return EXIT_FAILURE;

  return exec(app, engine);
}
