#include <QMenu>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickView>
#include <QtDebug>

#include "../components/calls/CallsListModel.hpp"
#include "../components/camera/Camera.hpp"
#include "../components/chat/ChatProxyModel.hpp"
#include "../components/contacts/ContactsListProxyModel.hpp"
#include "../components/core/CoreManager.hpp"
#include "../components/settings/AccountSettingsModel.hpp"
#include "../components/settings/SettingsModel.hpp"
#include "../components/smart-search-bar/SmartSearchBarModel.hpp"
#include "../components/timeline/TimelineModel.hpp"

#include "App.hpp"

#define LANGUAGES_PATH ":/languages/"
#define WINDOW_ICON_PATH ":/assets/images/linphone.png"

// The two main windows of Linphone desktop.
#define QML_VIEW_MAIN_WINDOW "qrc:/ui/views/App/MainWindow/MainWindow.qml"
#define QML_VIEW_CALL_WINDOW "qrc:/ui/views/App/Calls/Calls.qml"

// =============================================================================

App *App::m_instance = nullptr;

App::App (int &argc, char **argv) : QApplication(argc, argv) {
  if (m_english_translator.load(QLocale(QLocale::English), LANGUAGES_PATH))
    installTranslator(&m_english_translator);
  else
    qWarning("Unable to install english translator.");

  // Try to use default locale.
  QLocale current_locale = QLocale::system();

  if (m_default_translator.load(current_locale, LANGUAGES_PATH)) {
    installTranslator(&m_default_translator);
    m_locale = current_locale.name();
  } else {
    qWarning() << QStringLiteral("Unable to found translations for locale: %1.")
      .arg(current_locale.name());
  }

  // Provide avatars/thumbnails providers.
  m_engine.addImageProvider(AvatarProvider::PROVIDER_ID, &m_avatar_provider);
  m_engine.addImageProvider(ThumbnailProvider::PROVIDER_ID, &m_thumbnail_provider);

  setWindowIcon(QIcon(WINDOW_ICON_PATH));

  // Provide `+custom` folders for custom components.
  m_file_selector = new QQmlFileSelector(&m_engine);
  m_file_selector->setExtraSelectors(QStringList("custom"));

  // Set modules paths.
  m_engine.addImportPath(":/ui/modules");
  m_engine.addImportPath(":/ui/scripts");
  m_engine.addImportPath(":/ui/views");
}

// -----------------------------------------------------------------------------

bool App::hasFocus () const {
  QQmlApplicationEngine &engine = const_cast<QQmlApplicationEngine &>(m_engine);
  const QQuickWindow *root = qobject_cast<QQuickWindow *>(engine.rootObjects().at(0));
  return !!root->activeFocusItem();
}

// -----------------------------------------------------------------------------

void App::initContentApp () {
  // Init core.
  CoreManager::init();
  qInfo() << "Core manager initialized.";

  // Register types and load context properties.
  registerTypes();
  addContextProperties();

  CoreManager::getInstance()->enableHandlers();

  // Load main view.
  qInfo() << "Loading main view...";
  m_engine.load(QUrl(QML_VIEW_MAIN_WINDOW));
  if (m_engine.rootObjects().isEmpty())
    qFatal("Unable to open main window.");

  // Enable TrayIconSystem.
  if (!QSystemTrayIcon::isSystemTrayAvailable())
    qWarning("System tray not found on this system.");
  else
    setTrayIcon();
}

void App::registerTypes () {
  qInfo() << "Registering types...";

  qmlRegisterUncreatableType<CallModel>(
    "Linphone", 1, 0, "CallModel", "CallModel is uncreatable."
  );
  qmlRegisterUncreatableType<ContactModel>(
    "Linphone", 1, 0, "ContactModel", "ContactModel is uncreatable."
  );
  qmlRegisterUncreatableType<ContactObserver>(
    "Linphone", 1, 0, "ContactObserver", "ContactObserver is uncreatable."
  );
  qmlRegisterUncreatableType<Presence>(
    "Linphone", 1, 0, "Presence", "Presence is uncreatable."
  );
  qmlRegisterUncreatableType<VcardModel>(
    "Linphone", 1, 0, "VcardModel", "VcardModel is uncreatable."
  );

  qmlRegisterSingletonType<App>(
    "Linphone", 1, 0, "App",
    [](QQmlEngine *, QJSEngine *) -> QObject *{
      return App::getInstance();
    }
  );

  qmlRegisterSingletonType<CoreManager>(
    "Linphone", 1, 0, "CoreManager",
    [](QQmlEngine *, QJSEngine *) -> QObject *{
      return CoreManager::getInstance();
    }
  );

  qmlRegisterSingletonType<AccountSettingsModel>(
    "Linphone", 1, 0, "AccountSettingsModel",
    [](QQmlEngine *, QJSEngine *) -> QObject *{
      return new AccountSettingsModel();
    }
  );

  qmlRegisterSingletonType<CallsListModel>(
    "Linphone", 1, 0, "CallsListModel",
    [](QQmlEngine *, QJSEngine *) -> QObject *{
      return new CallsListModel();
    }
  );

  qmlRegisterSingletonType<ContactsListModel>(
    "Linphone", 1, 0, "ContactsListModel",
    [](QQmlEngine *, QJSEngine *) -> QObject *{
      return CoreManager::getInstance()->getContactsListModel();
    }
  );

  qmlRegisterSingletonType<SettingsModel>(
    "Linphone", 1, 0, "SettingsModel",
    [](QQmlEngine *, QJSEngine *) -> QObject *{
      return new SettingsModel();
    }
  );

  qmlRegisterSingletonType<SipAddressesModel>(
    "Linphone", 1, 0, "SipAddressesModel",
    [](QQmlEngine *, QJSEngine *) -> QObject *{
      return CoreManager::getInstance()->getSipAddressesModel();
    }
  );

  qmlRegisterSingletonType<TimelineModel>(
    "Linphone", 1, 0, "TimelineModel",
    [](QQmlEngine *, QJSEngine *) -> QObject *{
      return new TimelineModel();
    }
  );

  qmlRegisterType<Camera>("Linphone", 1, 0, "Camera");
  qmlRegisterType<ContactsListProxyModel>("Linphone", 1, 0, "ContactsListProxyModel");
  qmlRegisterType<ChatModel>("Linphone", 1, 0, "ChatModel");
  qmlRegisterType<ChatProxyModel>("Linphone", 1, 0, "ChatProxyModel");
  qmlRegisterType<SmartSearchBarModel>("Linphone", 1, 0, "SmartSearchBarModel");

  qRegisterMetaType<ChatModel::EntryType>("ChatModel::EntryType");
}

void App::addContextProperties () {
  qInfo() << "Adding context properties...";
  QQmlContext *context = m_engine.rootContext();

  // TODO: Avoid context properties. Use qmlRegister...
  QQmlComponent component(&m_engine, QUrl(QML_VIEW_CALL_WINDOW));
  if (component.isError()) {
    qWarning() << component.errors();
    abort();
  }

  context->setContextProperty("CallsWindow", component.create());

  m_notifier = new Notifier();
  context->setContextProperty("Notifier", m_notifier);
}

void App::setTrayIcon () {
  QQuickWindow *root = qobject_cast<QQuickWindow *>(m_engine.rootObjects().at(0));
  QMenu *menu = new QMenu();

  m_system_tray_icon = new QSystemTrayIcon(root);

  // trayIcon: Right click actions.
  QAction *quit_action = new QAction("Quit", root);
  root->connect(quit_action, &QAction::triggered, qApp, &QCoreApplication::quit);

  QAction *restore_action = new QAction("Restore", root);
  root->connect(restore_action, &QAction::triggered, root, &QQuickWindow::showNormal);

  // trayIcon: Left click actions.
  root->connect(
    m_system_tray_icon, &QSystemTrayIcon::activated, [root](
      QSystemTrayIcon::ActivationReason reason
    ) {
      if (reason == QSystemTrayIcon::Trigger) {
        if (root->visibility() == QWindow::Hidden)
          root->showNormal();
        else
          root->hide();
      }
    }
  );

  // Build trayIcon menu.
  menu->addAction(restore_action);
  menu->addSeparator();
  menu->addAction(quit_action);

  m_system_tray_icon->setContextMenu(menu);
  m_system_tray_icon->setIcon(QIcon(WINDOW_ICON_PATH));
  m_system_tray_icon->setToolTip("Linphone");
  m_system_tray_icon->show();
}
