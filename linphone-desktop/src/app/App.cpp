/*
 * App.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#include "../components/calls/CallsListModel.hpp"
#include "../components/camera/Camera.hpp"
#include "../components/chat/ChatProxyModel.hpp"
#include "../components/codecs/AudioCodecsModel.hpp"
#include "../components/codecs/VideoCodecsModel.hpp"
#include "../components/contacts/ContactsListProxyModel.hpp"
#include "../components/core/CoreManager.hpp"
#include "../components/presence/OwnPresenceModel.hpp"
#include "../components/settings/AccountSettingsModel.hpp"
#include "../components/smart-search-bar/SmartSearchBarModel.hpp"
#include "../components/timeline/TimelineModel.hpp"
#include "../utils.hpp"

#include "logger/Logger.hpp"
#include "providers/AvatarProvider.hpp"
#include "providers/ThumbnailProvider.hpp"
#include "translator/DefaultTranslator.hpp"

#include "App.hpp"

#include <QDir>
#include <QFileSelector>
#include <QMenu>
#include <QQmlFileSelector>
#include <QSystemTrayIcon>
#include <QtDebug>
#include <QTimer>

#define DEFAULT_LOCALE "en"

#define LANGUAGES_PATH ":/languages/"
#define WINDOW_ICON_PATH ":/assets/images/linphone_logo.svg"

// The main windows of Linphone desktop.
#define QML_VIEW_MAIN_WINDOW "qrc:/ui/views/App/Main/MainWindow.qml"
#define QML_VIEW_CALLS_WINDOW "qrc:/ui/views/App/Calls/CallsWindow.qml"
#define QML_VIEW_SETTINGS_WINDOW "qrc:/ui/views/App/Settings/SettingsWindow.qml"

#define QML_VIEW_SPLASH_SCREEN "qrc:/ui/views/App/SplashScreen/SplashScreen.qml"

// =============================================================================

inline bool installLocale (App &app, QTranslator &translator, const QLocale &locale) {
  return translator.load(locale, LANGUAGES_PATH) && app.installTranslator(&translator);
}

App::App (int &argc, char *argv[]) : SingleApplication(argc, argv, true) {
  setApplicationVersion("4.0");
  setWindowIcon(QIcon(WINDOW_ICON_PATH));

  // List available locales.
  for (const auto &locale : QDir(LANGUAGES_PATH).entryList())
    m_available_locales << QLocale(locale);

  m_translator = new DefaultTranslator(this);

  // Try to use system locale.
  QLocale sys_locale = QLocale::system();
  if (installLocale(*this, *m_translator, sys_locale)) {
    m_locale = sys_locale.name();
    qInfo() << QStringLiteral("Use system locale: %1").arg(m_locale);
    return;
  }

  // Use english.
  m_locale = DEFAULT_LOCALE;
  if (!installLocale(*this, *m_translator, QLocale(m_locale)))
    qFatal("Unable to install default translator.");
  qInfo() << QStringLiteral("Use default locale: %1").arg(m_locale);
}

App::~App () {
  qInfo() << QStringLiteral("Destroying app...");
}

// -----------------------------------------------------------------------------

inline QQuickWindow *createSubWindow (App *app, const char *path) {
  QQmlEngine *engine = app->getEngine();

  QQmlComponent component(engine, QUrl(path));
  if (component.isError()) {
    qWarning() << component.errors();
    abort();
  }

  QObject *object = component.create();
  QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
  object->setParent(app->getMainWindow());

  return qobject_cast<QQuickWindow *>(object);
}

// -----------------------------------------------------------------------------

inline void activeSplashScreen (App *app) {
  QQuickWindow *splash_screen = createSubWindow(app, QML_VIEW_SPLASH_SCREEN);
  QObject::connect(CoreManager::getInstance(), &CoreManager::linphoneCoreCreated, splash_screen, [splash_screen] {
    splash_screen->close();
    splash_screen->deleteLater();
  });
}

void App::initContentApp () {
  // Init core.
  CoreManager::init(this, m_parser.value("config"));
  qInfo() << "Activated selectors:" << QQmlFileSelector::get(&m_engine)->selector()->allSelectors();

  // Provide `+custom` folders for custom components.
  (new QQmlFileSelector(&m_engine, this))->setExtraSelectors(QStringList("custom"));

  // Set modules paths.
  m_engine.addImportPath(":/ui/modules");
  m_engine.addImportPath(":/ui/scripts");
  m_engine.addImportPath(":/ui/views");

  // Provide avatars/thumbnails providers.
  m_engine.addImageProvider(AvatarProvider::PROVIDER_ID, new AvatarProvider());
  m_engine.addImageProvider(ThumbnailProvider::PROVIDER_ID, new ThumbnailProvider());

  // Don't quit if last window is closed!!!
  setQuitOnLastWindowClosed(false);

  // Register types.
  registerTypes();

  // Enable notifications.
  m_notifier = new Notifier(this);

  // Load main view.
  qInfo() << "Loading main view...";
  m_engine.load(QUrl(QML_VIEW_MAIN_WINDOW));
  if (m_engine.rootObjects().isEmpty())
    qFatal("Unable to open main window.");

  // Load splashscreen.
  activeSplashScreen(this);

  QObject::connect(
    CoreManager::getInstance(),
    &CoreManager::linphoneCoreCreated,
    this, m_parser.isSet("selftest") ? &App::quit : &App::openAppAfterInit
  );

  QObject::connect(
    this, &App::receivedMessage, this, [this](int, QByteArray message) {
      if (message == "show")
        getMainWindow()->showNormal();
    }
  );
}

// -----------------------------------------------------------------------------

void App::parseArgs () {
  m_parser.setApplicationDescription(tr("applicationDescription"));
  m_parser.addHelpOption();
  m_parser.addVersionOption();
  m_parser.addOptions({
    { "config", tr("commandLineOptionConfig"), "file" },
    #ifndef __APPLE__
      { "iconified", tr("commandLineOptionIconified") },
    #endif // ifndef __APPLE__
    { "selftest", tr("commandLineOptionSelftest") },
    { { "V", "verbose" }, tr("commandLineOptionVerbose") }
  });

  m_parser.process(*this);

  // Initialize logger. (Do not do this before this point because the
  // application has to be created for the logs to be put in the correct
  // directory.)
  Logger::init();
  if (m_parser.isSet("verbose")) {
    Logger::getInstance()->setVerbose(true);
  }
}

// -----------------------------------------------------------------------------

void App::tryToUsePreferredLocale () {
  QString locale = getConfigLocale();

  if (!locale.isEmpty()) {
    DefaultTranslator *translator = new DefaultTranslator(this);

    if (installLocale(*this, *translator, QLocale(locale))) {
      // Use config.
      m_translator->deleteLater();
      m_translator = translator;
      m_locale = locale;

      qInfo() << QStringLiteral("Use preferred locale: %1").arg(locale);
    } else {
      // Reset config.
      setConfigLocale("");
      translator->deleteLater();
    }
  }
}

// -----------------------------------------------------------------------------

QQuickWindow *App::getCallsWindow () const {
  return qobject_cast<QQuickWindow *>(m_calls_window.getObject());
}

QQuickWindow *App::getMainWindow () const {
  return qobject_cast<QQuickWindow *>(
    const_cast<QQmlApplicationEngine *>(&m_engine)->rootObjects().at(0)
  );
}

QQuickWindow *App::getSettingsWindow () const {
  return qobject_cast<QQuickWindow *>(m_settings_window.getObject());
}

// -----------------------------------------------------------------------------

bool App::hasFocus () const {
  return getMainWindow()->isActive() || (m_calls_window.isCreated() && getCallsWindow()->isActive());
}

// -----------------------------------------------------------------------------

#define registerSharedSingletonType(TYPE, NAME, METHOD) qmlRegisterSingletonType<TYPE>( \
  "Linphone", 1, 0, NAME, \
  [](QQmlEngine *, QJSEngine *) -> QObject *{ \
    QObject *object = METHOD(); \
    QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership); \
    return object; \
  } \
)

template<class T>
void registerSingletonType (const char *name) {
  qmlRegisterSingletonType<T>(
    "Linphone", 1, 0, name,
    [](QQmlEngine *, QJSEngine *) -> QObject *{
      return new T();
    }
  );
}

void App::registerTypes () {
  qInfo() << "Registering types...";

  qmlRegisterType<Camera>("Linphone", 1, 0, "Camera");
  qmlRegisterType<ContactsListProxyModel>("Linphone", 1, 0, "ContactsListProxyModel");
  qmlRegisterType<ChatModel>("Linphone", 1, 0, "ChatModel");
  qmlRegisterType<ChatProxyModel>("Linphone", 1, 0, "ChatProxyModel");
  qmlRegisterType<SmartSearchBarModel>("Linphone", 1, 0, "SmartSearchBarModel");

  qRegisterMetaType<ChatModel::EntryType>("ChatModel::EntryType");

  qmlRegisterUncreatableType<CallModel>(
    "Linphone", 1, 0, "CallModel", "CallModel is uncreatable."
  );
  qmlRegisterUncreatableType<ContactModel>(
    "Linphone", 1, 0, "ContactModel", "ContactModel is uncreatable."
  );
  qmlRegisterUncreatableType<SipAddressObserver>(
    "Linphone", 1, 0, "SipAddressObserver", "SipAddressObserver is uncreatable."
  );
  qmlRegisterUncreatableType<VcardModel>(
    "Linphone", 1, 0, "VcardModel", "VcardModel is uncreatable."
  );

  registerSingletonType<AccountSettingsModel>("AccountSettingsModel");
  registerSingletonType<OwnPresenceModel>("OwnPresenceModel");
  registerSingletonType<Presence>("Presence");
  registerSingletonType<TimelineModel>("TimelineModel");
  registerSingletonType<AudioCodecsModel>("AudioCodecsModel");
  registerSingletonType<VideoCodecsModel>("VideoCodecsModel");

  registerSharedSingletonType(App, "App", App::getInstance);
  registerSharedSingletonType(CoreManager, "CoreManager", CoreManager::getInstance);
  registerSharedSingletonType(SettingsModel, "SettingsModel", CoreManager::getInstance()->getSettingsModel);
  registerSharedSingletonType(SipAddressesModel, "SipAddressesModel", CoreManager::getInstance()->getSipAddressesModel);
  registerSharedSingletonType(CallsListModel, "CallsListModel", CoreManager::getInstance()->getCallsListModel);
  registerSharedSingletonType(ContactsListModel, "ContactsListModel", CoreManager::getInstance()->getContactsListModel);
}

#undef registerSharedSingletonType

// -----------------------------------------------------------------------------

void App::setTrayIcon () {
  QQuickWindow *root = getMainWindow();
  QSystemTrayIcon *system_tray_icon = new QSystemTrayIcon(root);

  // trayIcon: Right click actions.
  QAction *quit_action = new QAction("Quit", root);
  root->connect(quit_action, &QAction::triggered, this, &App::quit);

  QAction *restore_action = new QAction("Restore", root);
  root->connect(restore_action, &QAction::triggered, root, &QQuickWindow::showNormal);

  // trayIcon: Left click actions.
  QMenu *menu = new QMenu();
  root->connect(
    system_tray_icon, &QSystemTrayIcon::activated, [root](
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

  system_tray_icon->setContextMenu(menu);
  system_tray_icon->setIcon(QIcon(WINDOW_ICON_PATH));
  system_tray_icon->setToolTip("Linphone");
  system_tray_icon->show();
}

// -----------------------------------------------------------------------------

QString App::getConfigLocale () const {
  return ::Utils::linphoneStringToQString(
    CoreManager::getInstance()->getCore()->getConfig()->getString(
      SettingsModel::UI_SECTION, "locale", ""
    )
  );
}

void App::setConfigLocale (const QString &locale) {
  CoreManager::getInstance()->getCore()->getConfig()->setString(
    SettingsModel::UI_SECTION, "locale", ::Utils::qStringToLinphoneString(locale)
  );

  emit configLocaleChanged(locale);
}

QString App::getLocale () const {
  return m_locale;
}

// -----------------------------------------------------------------------------

void App::openAppAfterInit () {
  tryToUsePreferredLocale();

  qInfo() << QStringLiteral("Linphone core created.");
  CoreManager::getInstance()->enableHandlers();

  #ifndef __APPLE__
    // Enable TrayIconSystem.
    if (!QSystemTrayIcon::isSystemTrayAvailable())
      qWarning("System tray not found on this system.");
    else
      setTrayIcon();

    if (!m_parser.isSet("iconified"))
      getMainWindow()->showNormal();
  #else
    getMainWindow()->showNormal();
  #endif   // ifndef __APPLE__

  m_calls_window.createObject(&m_engine, QML_VIEW_CALLS_WINDOW);

  m_settings_window.createObject(
    &m_engine, QML_VIEW_SETTINGS_WINDOW, [this](QObject *object) {
      QQuickWindow *window = qobject_cast<QQuickWindow *>(object);
      QObject::connect(
        window, &QWindow::visibilityChanged, this, [](QWindow::Visibility visibility) {
          if (visibility == QWindow::Hidden) {
            qInfo() << "Update nat policy.";
            shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
            core->setNatPolicy(core->getNatPolicy());
          }
        }
      );
    }
  );
}

// -----------------------------------------------------------------------------

void App::quit () {
  if (m_parser.isSet("selftest"))
    cout << tr("selftestResult").toStdString() << endl;

  QApplication::quit();
}
