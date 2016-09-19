#include <cstdlib>

#include <QMenu>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QSystemTrayIcon>
#include <QtDebug>

#include "app.hpp"

// ===================================================================

int exec (App &app, QQmlApplicationEngine &engine) {
  if (!QSystemTrayIcon::isSystemTrayAvailable())
    qWarning() << "System tray not found on this system.";
  else {
    QQuickWindow *root = qobject_cast<QQuickWindow *>(engine.rootObjects().at(0));
    QMenu *menu = new QMenu();
    QSystemTrayIcon *tray_icon = new QSystemTrayIcon(root);

    // Right click actions.
    QAction *quitAction = new QAction(QObject::tr("Quit"), root);
    root->connect(quitAction, &QAction::triggered, qApp, &QCoreApplication::quit);

    QAction *restoreAction = new QAction(QObject::tr("Restore"), root);
    root->connect(restoreAction, &QAction::triggered, root, &QQuickWindow::showNormal);

    // Left click action.
    root->connect(tray_icon, &QSystemTrayIcon::activated, [&root](QSystemTrayIcon::ActivationReason reason) {
      if (reason == QSystemTrayIcon::DoubleClick)
        root->showNormal();
    });

    menu->addAction(restoreAction);
    menu->addSeparator();
    menu->addAction(quitAction);

    tray_icon->setContextMenu(menu);
    tray_icon->setIcon(QIcon(":/imgs/linphone.png"));
    tray_icon->show();
  }

  return app.exec();
}

int main (int argc, char *argv[]) {
  App app(argc, argv);
  QQmlApplicationEngine engine(QUrl("qrc:/ui/views/mainWindow/mainWindow.qml"));

  if (engine.rootObjects().isEmpty())
    return EXIT_FAILURE;

  return exec(app, engine);
}
