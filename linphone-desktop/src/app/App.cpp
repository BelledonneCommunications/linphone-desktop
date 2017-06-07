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

#include <QDir>
#include <QFileSelector>
#include <QMenu>
#include <QQmlFileSelector>
#include <QSystemTrayIcon>
#include <QtDebug>
#include <QTimer>

#include "gitversion.h"

#include "../components/Components.hpp"
#include "../Utils.hpp"

#include "cli/Cli.hpp"
#include "logger/Logger.hpp"
#include "paths/Paths.hpp"
#include "providers/AvatarProvider.hpp"
#include "providers/ThumbnailProvider.hpp"
#include "translator/DefaultTranslator.hpp"

#include "App.hpp"

#define DEFAULT_LOCALE "en"

#define LANGUAGES_PATH ":/languages/"
#define WINDOW_ICON_PATH ":/assets/images/linphone_logo.svg"

// The main windows of Linphone desktop.
#define QML_VIEW_MAIN_WINDOW "qrc:/ui/views/App/Main/MainWindow.qml"
#define QML_VIEW_CALLS_WINDOW "qrc:/ui/views/App/Calls/CallsWindow.qml"
#define QML_VIEW_SETTINGS_WINDOW "qrc:/ui/views/App/Settings/SettingsWindow.qml"

#define QML_VIEW_SPLASH_SCREEN "qrc:/ui/views/App/SplashScreen/SplashScreen.qml"

#define SELF_TEST_DELAY 300000

#ifndef LINPHONE_QT_GIT_VERSION
  #define LINPHONE_QT_GIT_VERSION "unknown"
#endif // ifndef LINPHONE_QT_GIT_VERSION

using namespace std;

// =============================================================================

inline bool installLocale (App &app, QTranslator &translator, const QLocale &locale) {
  return translator.load(locale, LANGUAGES_PATH) && app.installTranslator(&translator);
}

App::App (int &argc, char *argv[]) : SingleApplication(argc, argv, true) {
  setApplicationVersion(LINPHONE_QT_GIT_VERSION);
  setWindowIcon(QIcon(WINDOW_ICON_PATH));

  parseArgs();

  // List available locales.
  for (const auto &locale : QDir(LANGUAGES_PATH).entryList())
    mAvailableLocales << QLocale(locale);

  mTranslator = new DefaultTranslator(this);

  // Try to use preferred locale.
  QString locale = ::Utils::coreStringToAppString(
      linphone::Config::newWithFactory(
        Paths::getConfigFilePath(mParser.value("config")), "")->getString(
        SettingsModel::UI_SECTION, "locale", ""
      )
    );

  if (!locale.isEmpty() && installLocale(*this, *mTranslator, QLocale(locale))) {
    mLocale = locale;
    qInfo() << QStringLiteral("Use preferred locale: %1").arg(locale);
    return;
  }

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
  delete mEngine;
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
  qInfo() << QStringLiteral("Open splash screen...");
  QQuickWindow *splashScreen = createSubWindow(app, QML_VIEW_SPLASH_SCREEN);
  QObject::connect(CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::coreStarted, splashScreen, [splashScreen] {
    splashScreen->close();
    splashScreen->deleteLater();
  });
}

void App::initContentApp () {
  // Destroy qml components and linphone core if necessary.
  if (mEngine) {
    qInfo() << QStringLiteral("Restarting app...");
    delete mEngine;

    mCallsWindow = nullptr;
    mSettingsWindow = nullptr;

    CoreManager::uninit();
  } else {
    // Don't quit if last window is closed!!!
    setQuitOnLastWindowClosed(false);

    QObject::connect(this, &App::receivedMessage, this, [this](int, const QByteArray &byteArray) {
        QString command(byteArray);
        qInfo() << QStringLiteral("Received command from other application: `%1`.").arg(command);
        executeCommand(command);
      });

    mCli = new Cli(this);
  }

  // Init core.
  CoreManager::init(this, mParser.value("config"));

  // Init engine content.
  mEngine = new QQmlApplicationEngine();

  // Provide `+custom` folders for custom components.
  (new QQmlFileSelector(mEngine, mEngine))->setExtraSelectors(QStringList("custom"));
  qInfo() << QStringLiteral("Activated selectors:") << QQmlFileSelector::get(mEngine)->selector()->allSelectors();

  // Set modules paths.
  mEngine->addImportPath(":/ui/modules");
  mEngine->addImportPath(":/ui/scripts");
  mEngine->addImportPath(":/ui/views");

  // Provide avatars/thumbnails providers.
  mEngine->addImageProvider(AvatarProvider::PROVIDER_ID, new AvatarProvider());
  mEngine->addImageProvider(ThumbnailProvider::PROVIDER_ID, new ThumbnailProvider());

  registerTypes();
  registerSharedTypes();

  // Enable notifications.
  createNotifier();

  // Load main view.
  qInfo() << QStringLiteral("Loading main view...");
  mEngine->load(QUrl(QML_VIEW_MAIN_WINDOW));
  if (mEngine->rootObjects().isEmpty())
    qFatal("Unable to open main window.");

  bool selfTest = mParser.isSet("self-test");

  // Load splashscreen.
  if (!selfTest)
    activeSplashScreen(this);
  // Set a self test limit.
  else
    QTimer::singleShot(SELF_TEST_DELAY, this, [] {
      qFatal("Self test failed. :(");
    });

  QObject::connect(
    CoreManager::getInstance()->getHandlers().get(),
    &CoreHandlers::coreStarted,
    this, selfTest ? &App::quit : &App::openAppAfterInit
  );
}

// -----------------------------------------------------------------------------

QString App::getCommandArgument () {
  return mParser.value("cmd");
}

// -----------------------------------------------------------------------------

void App::executeCommand (const QString &command) {
  mCli->executeCommand(command);
}

// -----------------------------------------------------------------------------

QQuickWindow *App::getCallsWindow () {
  if (!mCallsWindow)
    mCallsWindow = createSubWindow(this, QML_VIEW_CALLS_WINDOW);

  return mCallsWindow;
}

QQuickWindow *App::getMainWindow () const {
  return qobject_cast<QQuickWindow *>(
    const_cast<QQmlApplicationEngine *>(mEngine)->rootObjects().at(0)
  );
}

QQuickWindow *App::getSettingsWindow () {
  if (!mSettingsWindow) {
    mSettingsWindow = createSubWindow(this, QML_VIEW_SETTINGS_WINDOW);
    QObject::connect(mSettingsWindow, &QWindow::visibilityChanged, this, [](QWindow::Visibility visibility) {
        if (visibility == QWindow::Hidden) {
          qInfo() << QStringLiteral("Update nat policy.");
          shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
          core->setNatPolicy(core->getNatPolicy());
        }
      });
  }

  return mSettingsWindow;
}

// -----------------------------------------------------------------------------

void App::smartShowWindow (QQuickWindow *window) {
  window->setVisible(true);

  if (window->visibility() == QWindow::Minimized)
    window->show();

  window->raise();
  window->requestActivate();
}

void App::checkForUpdate () {
  CoreManager::getInstance()->getCore()->checkForUpdate(LINPHONE_QT_GIT_VERSION);
}

QString App::convertUrlToLocalPath (const QUrl &url) {
  return QDir::toNativeSeparators(url.toLocalFile());
}

// -----------------------------------------------------------------------------

bool App::hasFocus () const {
  return getMainWindow()->isActive() || (mCallsWindow && mCallsWindow->isActive());
}

// -----------------------------------------------------------------------------

void App::parseArgs () {
  mParser.setApplicationDescription(tr("applicationDescription"));
  mParser.addHelpOption();
  mParser.addVersionOption();
  mParser.addOptions({
    { "config", tr("commandLineOptionConfig"), tr("commandLineOptionConfigArg") },
    #ifndef Q_OS_MACOS
      { "iconified", tr("commandLineOptionIconified") },
    #endif // ifndef Q_OS_MACOS
    { "self-test", tr("commandLineOptionSelfTest") },
    { { "V", "verbose" }, tr("commandLineOptionVerbose") },
    { { "c", "cmd" }, tr("commandLineOptionCmd"), tr("commandLineOptionCmdArg") }
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

#define registerSharedSingletonType(TYPE, NAME, METHOD) qmlRegisterSingletonType<TYPE>( \
  "Linphone", 1, 0, NAME, \
  [](QQmlEngine *, QJSEngine *) -> QObject *{ \
    QObject *object = METHOD(); \
    QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership); \
    return object; \
  } \
)

#define registerUncreatableType(TYPE, NAME) qmlRegisterUncreatableType<TYPE>( \
  "Linphone", 1, 0, NAME, NAME " is uncreatable." \
)

template<class T>
void registerMetaType (const char *name) {
  qRegisterMetaType<T>(name);
}

template<class T>
void registerSingletonType (const char *name) {
  qmlRegisterSingletonType<T>("Linphone", 1, 0, name, [](QQmlEngine *, QJSEngine *) -> QObject *{
      return new T();
    });
}

template<class T>
void registerType (const char *name) {
  qmlRegisterType<T>("Linphone", 1, 0, name);
}

void App::registerTypes () {
  qInfo() << QStringLiteral("Registering types...");

  registerType<AssistantModel>("AssistantModel");
  registerType<AuthenticationNotifier>("AuthenticationNotifier");
  registerType<CallsListProxyModel>("CallsListProxyModel");
  registerType<Camera>("Camera");
  registerType<CameraPreview>("CameraPreview");
  registerType<ChatModel>("ChatModel");
  registerType<ChatProxyModel>("ChatProxyModel");
  registerType<ConferenceHelperModel>("ConferenceHelperModel");
  registerType<ConferenceModel>("ConferenceModel");
  registerType<ContactsListProxyModel>("ContactsListProxyModel");
  registerType<SipAddressesProxyModel>("SipAddressesProxyModel");
  registerType<SoundPlayer>("SoundPlayer");
  registerType<TelephoneNumbersModel>("TelephoneNumbersModel");

  registerSingletonType<AudioCodecsModel>("AudioCodecsModel");
  registerSingletonType<Clipboard>("Clipboard");
  registerSingletonType<OwnPresenceModel>("OwnPresenceModel");
  registerSingletonType<Presence>("Presence");
  registerSingletonType<TextToSpeech>("TextToSpeech");
  registerSingletonType<TimelineModel>("TimelineModel");
  registerSingletonType<VideoCodecsModel>("VideoCodecsModel");

  registerMetaType<ChatModel::EntryType>("ChatModel::EntryType");

  registerUncreatableType(CallModel, "CallModel");
  registerUncreatableType(ConferenceHelperModel::ConferenceAddModel, "ConferenceAddModel");
  registerUncreatableType(ContactModel, "ContactModel");
  registerUncreatableType(SipAddressObserver, "SipAddressObserver");
  registerUncreatableType(VcardModel, "VcardModel");
}

void App::registerSharedTypes () {
  qInfo() << QStringLiteral("Registering shared types...");

  registerSharedSingletonType(App, "App", App::getInstance);
  registerSharedSingletonType(CoreManager, "CoreManager", CoreManager::getInstance);
  registerSharedSingletonType(SettingsModel, "SettingsModel", CoreManager::getInstance()->getSettingsModel);
  registerSharedSingletonType(AccountSettingsModel, "AccountSettingsModel", CoreManager::getInstance()->getAccountSettingsModel);
  registerSharedSingletonType(SipAddressesModel, "SipAddressesModel", CoreManager::getInstance()->getSipAddressesModel);
  registerSharedSingletonType(CallsListModel, "CallsListModel", CoreManager::getInstance()->getCallsListModel);
  registerSharedSingletonType(ContactsListModel, "ContactsListModel", CoreManager::getInstance()->getContactsListModel);
}

#undef registerUncreatableType
#undef registerSharedSingletonType

// -----------------------------------------------------------------------------

void App::setTrayIcon () {
  QQuickWindow *root = getMainWindow();
  QSystemTrayIcon *systemTrayIcon = new QSystemTrayIcon(mEngine);

  // trayIcon: Right click actions.
  QAction *quitAction = new QAction("Quit", root);
  root->connect(quitAction, &QAction::triggered, this, &App::quit);

  QAction *restoreAction = new QAction("Restore", root);
  root->connect(restoreAction, &QAction::triggered, root, [root] {
    smartShowWindow(root);
  });

  // trayIcon: Left click actions.
  QMenu *menu = new QMenu();
  root->connect(systemTrayIcon, &QSystemTrayIcon::activated, [root](
      QSystemTrayIcon::ActivationReason reason
    ) {
      if (reason == QSystemTrayIcon::Trigger) {
        if (root->visibility() == QWindow::Hidden)
          smartShowWindow(root);
        else
          root->hide();
      }
    });

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

void App::createNotifier () {
  if (!mNotifier)
    mNotifier = new Notifier(this);
}

// -----------------------------------------------------------------------------

QString App::getConfigLocale () const {
  return ::Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getConfig()->getString(
      SettingsModel::UI_SECTION, "locale", ""
    )
  );
}

void App::setConfigLocale (const QString &locale) {
  CoreManager::getInstance()->getCore()->getConfig()->setString(
    SettingsModel::UI_SECTION, "locale", ::Utils::appStringToCoreString(locale)
  );

  emit configLocaleChanged(locale);
}

QString App::getLocale () const {
  return mLocale;
}

// -----------------------------------------------------------------------------

void App::openAppAfterInit () {
  qInfo() << QStringLiteral("Open linphone app.");

  QQuickWindow *mainWindow = getMainWindow();

  #ifndef __APPLE__
    // Enable TrayIconSystem.
    if (!QSystemTrayIcon::isSystemTrayAvailable())
      qWarning("System tray not found on this system.");
    else
      setTrayIcon();

    if (!mParser.isSet("iconified"))
      smartShowWindow(mainWindow);
  #else
    smartShowWindow(mainWindow);
  #endif // ifndef __APPLE__

  // Display Assistant if it's the first time app launch.
  {
    shared_ptr<linphone::Config> config = CoreManager::getInstance()->getCore()->getConfig();
    if (config->getInt(SettingsModel::UI_SECTION, "force_assistant_at_startup", 1)) {
      QMetaObject::invokeMethod(mainWindow, "setView", Q_ARG(QVariant, "Assistant"), Q_ARG(QVariant, ""));
      config->setInt(SettingsModel::UI_SECTION, "force_assistant_at_startup", 0);
    }
  }

  // Execute command argument if needed.
  {
    const QString &commandArgument = getCommandArgument();
    if (!commandArgument.isEmpty())
      executeCommand(commandArgument);
  }
}

// -----------------------------------------------------------------------------

void App::quit () {
  if (mParser.isSet("self-test"))
    cout << tr("selfTestResult").toStdString() << endl;

  QApplication::quit();
}
