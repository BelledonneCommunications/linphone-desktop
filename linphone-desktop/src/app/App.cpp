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

#include "../components/Components.hpp"
#include "../Utils.hpp"

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

using namespace std;

// =============================================================================

inline bool installLocale (App &app, QTranslator &translator, const QLocale &locale) {
  return translator.load(locale, LANGUAGES_PATH) && app.installTranslator(&translator);
}

App::App (int &argc, char *argv[]) : SingleApplication(argc, argv, true) {
  setApplicationVersion("4.0");
  setWindowIcon(QIcon(WINDOW_ICON_PATH));

  // List available locales.
  for (const auto &locale : QDir(LANGUAGES_PATH).entryList())
    mAvailableLocales << QLocale(locale);

  mTranslator = new DefaultTranslator(this);

  // Try to use system locale.
  QLocale sysLocale = QLocale::system();
  if (installLocale(*this, *mTranslator, sysLocale)) {
    mLocale = sysLocale.name();
    qInfo() << QStringLiteral("Use system locale: %1").arg(mLocale);
    return;
  }

  // Use english.
  mLocale = DEFAULT_LOCALE;
  if (!installLocale(*this, *mTranslator, QLocale(mLocale)))
    qFatal("Unable to install default translator.");
  qInfo() << QStringLiteral("Use default locale: %1").arg(mLocale);
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
  QQuickWindow *splashScreen = createSubWindow(app, QML_VIEW_SPLASH_SCREEN);
  QObject::connect(CoreManager::getInstance(), &CoreManager::linphoneCoreCreated, splashScreen, [splashScreen] {
    splashScreen->close();
    splashScreen->deleteLater();
  });
}

void App::initContentApp () {
  // Init core.
  CoreManager::init(this, mParser.value("config"));
  qInfo() << "Activated selectors:" << QQmlFileSelector::get(&mEngine)->selector()->allSelectors();

  // Provide `+custom` folders for custom components.
  (new QQmlFileSelector(&mEngine, this))->setExtraSelectors(QStringList("custom"));

  // Set modules paths.
  mEngine.addImportPath(":/ui/modules");
  mEngine.addImportPath(":/ui/scripts");
  mEngine.addImportPath(":/ui/views");

  // Provide avatars/thumbnails providers.
  mEngine.addImageProvider(AvatarProvider::PROVIDER_ID, new AvatarProvider());
  mEngine.addImageProvider(ThumbnailProvider::PROVIDER_ID, new ThumbnailProvider());

  // Don't quit if last window is closed!!!
  setQuitOnLastWindowClosed(false);

  // Register types.
  registerTypes();

  // Enable notifications.
  mNotifier = new Notifier(this);

  // Load main view.
  qInfo() << "Loading main view...";
  mEngine.load(QUrl(QML_VIEW_MAIN_WINDOW));
  if (mEngine.rootObjects().isEmpty())
    qFatal("Unable to open main window.");

  // Load splashscreen.
  activeSplashScreen(this);

  QObject::connect(
    CoreManager::getInstance(),
    &CoreManager::linphoneCoreCreated,
    this, mParser.isSet("selftest") ? &App::quit : &App::openAppAfterInit
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
  mParser.setApplicationDescription(tr("applicationDescription"));
  mParser.addHelpOption();
  mParser.addVersionOption();
  mParser.addOptions({
    { "config", tr("commandLineOptionConfig"), "file" },
    #ifndef __APPLE__
      { "iconified", tr("commandLineOptionIconified") },
    #endif // ifndef __APPLE__
    { "selftest", tr("commandLineOptionSelftest") },
    { { "V", "verbose" }, tr("commandLineOptionVerbose") }
  });

  mParser.process(*this);

  // Initialize logger. (Do not do this before this point because the
  // application has to be created for the logs to be put in the correct
  // directory.)
  Logger::init();
  if (mParser.isSet("verbose")) {
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
      mTranslator->deleteLater();
      mTranslator = translator;
      mLocale = locale;

      qInfo() << QStringLiteral("Use preferred locale: %1").arg(locale);
    } else {
      // Reset config.
      setConfigLocale("");
      translator->deleteLater();
    }
  }
}

// -----------------------------------------------------------------------------

QQuickWindow *App::getCallsWindow () {
  if (!mCallsWindow)
    mCallsWindow = createSubWindow(this, QML_VIEW_CALLS_WINDOW);

  return mCallsWindow;
}

QQuickWindow *App::getMainWindow () const {
  return qobject_cast<QQuickWindow *>(
    const_cast<QQmlApplicationEngine *>(&mEngine)->rootObjects().at(0)
  );
}

QQuickWindow *App::getSettingsWindow () {
  if (!mSettingsWindow) {
    mSettingsWindow = createSubWindow(this, QML_VIEW_SETTINGS_WINDOW);
    QObject::connect(
      mSettingsWindow, &QWindow::visibilityChanged, this, [](QWindow::Visibility visibility) {
        if (visibility == QWindow::Hidden) {
          qInfo() << "Update nat policy.";
          shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
          core->setNatPolicy(core->getNatPolicy());
        }
      }
    );
  }

  return mSettingsWindow;
}

// -----------------------------------------------------------------------------

bool App::hasFocus () const {
  return getMainWindow()->isActive() || (mCallsWindow && mCallsWindow->isActive());
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

  qmlRegisterType<AssistantModel>("Linphone", 1, 0, "AssistantModel");
  qmlRegisterType<Authentication>("Linphone", 1, 0, "Authentication");
  qmlRegisterType<Camera>("Linphone", 1, 0, "Camera");
  qmlRegisterType<Camera>("Linphone", 1, 0, "CameraPreview");
  qmlRegisterType<ChatModel>("Linphone", 1, 0, "ChatModel");
  qmlRegisterType<ChatProxyModel>("Linphone", 1, 0, "ChatProxyModel");
  qmlRegisterType<ContactsListProxyModel>("Linphone", 1, 0, "ContactsListProxyModel");
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

  registerSingletonType<AudioCodecsModel>("AudioCodecsModel");
  registerSingletonType<OwnPresenceModel>("OwnPresenceModel");
  registerSingletonType<Presence>("Presence");
  registerSingletonType<TimelineModel>("TimelineModel");
  registerSingletonType<VideoCodecsModel>("VideoCodecsModel");

  registerSharedSingletonType(App, "App", App::getInstance);
  registerSharedSingletonType(CoreManager, "CoreManager", CoreManager::getInstance);
  registerSharedSingletonType(SettingsModel, "SettingsModel", CoreManager::getInstance()->getSettingsModel);
  registerSharedSingletonType(AccountSettingsModel, "AccountSettingsModel", CoreManager::getInstance()->getAccountSettingsModel);
  registerSharedSingletonType(SipAddressesModel, "SipAddressesModel", CoreManager::getInstance()->getSipAddressesModel);
  registerSharedSingletonType(CallsListModel, "CallsListModel", CoreManager::getInstance()->getCallsListModel);
  registerSharedSingletonType(ContactsListModel, "ContactsListModel", CoreManager::getInstance()->getContactsListModel);
}

#undef registerSharedSingletonType

// -----------------------------------------------------------------------------

void App::setTrayIcon () {
  QQuickWindow *root = getMainWindow();
  QSystemTrayIcon *systemTrayIcon = new QSystemTrayIcon(root);

  // trayIcon: Right click actions.
  QAction *quitAction = new QAction("Quit", root);
  root->connect(quitAction, &QAction::triggered, this, &App::quit);

  QAction *restoreAction = new QAction("Restore", root);
  root->connect(restoreAction, &QAction::triggered, root, &QQuickWindow::showNormal);

  // trayIcon: Left click actions.
  QMenu *menu = new QMenu();
  root->connect(
    systemTrayIcon, &QSystemTrayIcon::activated, [root](
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
  menu->addAction(restoreAction);
  menu->addSeparator();
  menu->addAction(quitAction);

  systemTrayIcon->setContextMenu(menu);
  systemTrayIcon->setIcon(QIcon(WINDOW_ICON_PATH));
  systemTrayIcon->setToolTip("Linphone");
  systemTrayIcon->show();
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
  return mLocale;
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

    if (!mParser.isSet("iconified"))
      getMainWindow()->showNormal();
  #else
    getMainWindow()->showNormal();
  #endif // ifndef __APPLE__
}

// -----------------------------------------------------------------------------

void App::quit () {
  if (mParser.isSet("selftest"))
    cout << tr("selftestResult").toStdString() << endl;

  QApplication::quit();
}
