#include <QMenu>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlFileSelector>
#include <QQuickView>
#include <QSystemTrayIcon>
#include <QtDebug>

#include "app/App.hpp"
#include "app/Logger.hpp"
#include "components/contacts/ContactsListProxyModel.hpp"
#include "components/linphone/LinphoneCore.hpp"
#include "components/notification/Notification.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/timeline/TimelineModel.hpp"

// ===================================================================

void setTrayIcon (QQmlApplicationEngine &engine) {
  QQuickWindow *root = qobject_cast<QQuickWindow *>(engine.rootObjects().at(0));
  QMenu *menu = new QMenu();
  QSystemTrayIcon *tray_icon = new QSystemTrayIcon(root);

  // trayIcon: Right click actions.
  QAction *quit_action = new QAction("Quit", root);
  root->connect(quit_action, &QAction::triggered, qApp, &QCoreApplication::quit);

  QAction *restore_action = new QAction("Restore", root);
  root->connect(restore_action, &QAction::triggered, root, &QQuickWindow::showNormal);

  // trayIcon: Left click actions.
  root->connect(tray_icon, &QSystemTrayIcon::activated, [root](QSystemTrayIcon::ActivationReason reason) {
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
  tray_icon->setIcon(QIcon(":/assets/images/linphone.png"));
  tray_icon->setToolTip("Linphone");
  tray_icon->show();
}

void registerTypes () {
  qmlRegisterUncreatableType<Presence>(
    "Linphone", 1, 0, "Presence", "Presence is uncreatable"
  );

  ContactsListProxyModel::initContactsListModel(new ContactsListModel());
  qmlRegisterType<ContactsListProxyModel>("Linphone", 1, 0, "ContactsListProxyModel");

  // Expose the static functions of ContactsListModel.
  qmlRegisterSingletonType<ContactsListModel>(
    "Linphone", 1, 0, "ContactsListModel",
    [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject *{
      Q_UNUSED(engine);
      Q_UNUSED(scriptEngine);

      return ContactsListProxyModel::getContactsListModel();
    }
  );
}

void addContextProperties (QQmlApplicationEngine &engine) {
  QQmlContext *context = engine.rootContext();
  QQmlComponent component(&engine, QUrl("qrc:/ui/views/App/Calls/Calls.qml"));

  // Windows.
  if (component.isError()) {
    qWarning() << component.errors();
  } else {
    // context->setContextProperty("CallsWindow", component.create());
  }

  // Models.
  context->setContextProperty("AccountSettingsModel", new AccountSettingsModel());
  context->setContextProperty("TimelineModel", new TimelineModel());

  // Other.
  context->setContextProperty("LinphoneCore", LinphoneCore::getInstance());
  context->setContextProperty("Notification", new Notification());
}

// ===================================================================

int main (int argc, char *argv[]) {
  qInstallMessageHandler(qmlLogger);

  registerTypes();

  QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  App app(argc, argv);
  QQmlApplicationEngine engine;

  // Provide `+custom` folders for custom components.
  QQmlFileSelector *selector = new QQmlFileSelector(&engine);
  selector->setExtraSelectors(QStringList("custom"));

  // Set modules paths.
  engine.addImportPath(":/ui/modules");
  engine.addImportPath(":/ui/scripts");
  engine.addImportPath(":/ui/views");

  // Load context properties.
  addContextProperties(engine);

  // Load main view.
  engine.load(QUrl("qrc:/ui/views/App/MainWindow/MainWindow.qml"));
  if (engine.rootObjects().isEmpty()) {
    qWarning() << "Unable to open main window.";
    return EXIT_FAILURE;
  }

  // Enable TrayIconSystem.
  if (!QSystemTrayIcon::isSystemTrayAvailable())
    qWarning() << "System tray not found on this system.";
  else
    setTrayIcon(engine);

  // Run!
  return app.exec();
}
