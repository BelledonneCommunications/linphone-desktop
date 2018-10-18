/*
 * App.cpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
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

#include <QCommandLineParser>
#include <QDir>
#include <QFileSelector>
#include <QLibraryInfo>
#include <QMenu>
#include <QQmlApplicationEngine>
#include <QQmlFileSelector>
#include <QQuickWindow>
#include <QSystemTrayIcon>
#include <QTimer>

#ifdef Q_OS_WIN
  #include <QSettings>
#endif // ifdef Q_OS_WIN

#include "config.h"

#include "cli/Cli.hpp"
#include "components/Components.hpp"
#include "logger/Logger.hpp"
#include "paths/Paths.hpp"
#include "providers/AvatarProvider.hpp"
#include "providers/ImageProvider.hpp"
#include "providers/ThumbnailProvider.hpp"
#include "translator/DefaultTranslator.hpp"
#include "utils/LinphoneUtils.hpp"
#include "utils/Utils.hpp"

#include "App.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr char DefaultLocale[] = "en";

  constexpr char LanguagePath[] = ":/languages/";

  // The main windows of Linphone desktop.
  constexpr char QmlViewMainWindow[] = "qrc:/ui/views/App/Main/MainWindow.qml";
  constexpr char QmlViewCallsWindow[] = "qrc:/ui/views/App/Calls/CallsWindow.qml";
  constexpr char QmlViewSettingsWindow[] = "qrc:/ui/views/App/Settings/SettingsWindow.qml";

  #ifdef ENABLE_UPDATE_CHECK
    constexpr int VersionUpdateCheckInterval = 86400000; // 24 hours in milliseconds.
  #endif // ifdef ENABLE_UPDATE_CHECK

  constexpr char MainQmlUri[] = "Linphone";

  constexpr char AttachVirtualWindowMethodName[] = "attachVirtualWindow";
  constexpr char AboutPath[] = "qrc:/ui/views/App/Main/Dialogs/About.qml";

  constexpr char AssistantViewName[] = "Assistant";

  #ifdef Q_OS_LINUX
    QString AutoStartDirectory(
      QStandardPaths::standardLocations(QStandardPaths::ConfigLocation).at(0) + QLatin1String("/autostart/")
    );
  #elif defined(Q_OS_MACOS)
    QString OsascriptExecutable("osascript");
  #else
    QString AutoStartSettingsFilePath("HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run");
  #endif // ifdef Q_OS_LINUX
}

// -----------------------------------------------------------------------------

#ifdef Q_OS_LINUX
  static inline bool autoStartEnabled () {
    return QDir(AutoStartDirectory).exists() && QFile(AutoStartDirectory + EXECUTABLE_NAME ".desktop").exists();
  }
#elif defined(Q_OS_MACOS)
  static inline QString getMacOsBundlePath () {
    QDir dir(QCoreApplication::applicationDirPath());
    if (dir.dirName() != QLatin1String("MacOS"))
      return QString();

    dir.cdUp();
    dir.cdUp();

    QString path(dir.path());
    if (path.length() > 0 && path.right(1) == "/")
      path.chop(1);
    return path;
  }

  static inline QString getMacOsBundleName () {
    return QFileInfo(getMacOsBundlePath()).baseName();
  }

  static inline bool autoStartEnabled () {
    const QByteArray expectedWord(getMacOsBundleName().toUtf8());
    if (expectedWord.isEmpty()) {
      qInfo() << QStringLiteral("Application is not installed. Autostart unavailable.");
      return false;
    }

    QProcess process;
    process.start(OsascriptExecutable, { "-e", "tell application \"System Events\" to get the name of every login item" });
    if (!process.waitForFinished()) {
      qWarning() << QStringLiteral("Unable to execute properly: `%1` (%2).").arg(OsascriptExecutable).arg(process.errorString());
      return false;
    }

    // TODO: Move in utils?
    const QByteArray buf(process.readAll());
    for (const char *p = buf.data(), *word = p, *end = p + buf.length(); p <= end; ++p) {
      switch (*p) {
        case ' ':
        case '\r':
        case '\n':
        case '\t':
        case '\0':
          if (word != p) {
            if (!strncmp(word, expectedWord, size_t(p - word)))
              return true;
            word = p + 1;
          }
        default:
          break;
      }
    }

    return false;
  }
#else
  static inline bool autoStartEnabled () {
    return QSettings(AutoStartSettingsFilePath, QSettings::NativeFormat).value(EXECUTABLE_NAME).isValid();
  }
#endif // ifdef Q_OS_LINUX

// -----------------------------------------------------------------------------

static inline bool installLocale (App &app, QTranslator &translator, const QLocale &locale) {
  return translator.load(locale, LanguagePath) && app.installTranslator(&translator);
}

static inline shared_ptr<linphone::Config> getConfigIfExists (const QCommandLineParser &parser) {
  string configPath(Paths::getConfigFilePath(parser.value("config"), false));
  if (!Paths::filePathExists(configPath))
    configPath.clear();

  string factoryPath(Paths::getFactoryConfigFilePath());
  if (!Paths::filePathExists(factoryPath))
    factoryPath.clear();

  return linphone::Config::newWithFactory(configPath, factoryPath);
}

// -----------------------------------------------------------------------------

App::App (int &argc, char *argv[]) : SingleApplication(argc, argv, true, Mode::User | Mode::ExcludeAppPath | Mode::ExcludeAppVersion) {
  setWindowIcon(QIcon(LinphoneUtils::WindowIconPath));

  createParser();
  mParser->process(*this);

  // Initialize logger.
  shared_ptr<linphone::Config> config = getConfigIfExists(*mParser);
  Logger::init(config);
  if (mParser->isSet("verbose"))
    Logger::getInstance()->setVerbose(true);

  // List available locales.
  for (const auto &locale : QDir(LanguagePath).entryList())
    mAvailableLocales << QLocale(locale);

  // Init locale.
  mTranslator = new DefaultTranslator(this);
  initLocale(config);

  if (mParser->isSet("help")) {
    createParser();
    mParser->showHelp();
  }

  if (mParser->isSet("cli-help")) {
    Cli::showHelp();
    ::exit(EXIT_SUCCESS);
  }

  if (mParser->isSet("version"))
    mParser->showVersion();

  mAutoStart = autoStartEnabled();

  qInfo() << QStringLiteral("Starting " APPLICATION_NAME " (bin: " EXECUTABLE_NAME ")");
  qInfo() << QStringLiteral("Use locale: %1").arg(mLocale);
}

App::~App () {
  qInfo() << QStringLiteral("Destroying app...");
  delete mEngine;
  delete mParser;
}

// -----------------------------------------------------------------------------

static QQuickWindow *createSubWindow (QQmlApplicationEngine *engine, const char *path) {
  qInfo() << QStringLiteral("Creating subwindow: `%1`.").arg(path);

  QQmlComponent component(engine, QUrl(path));
  if (component.isError()) {
    qWarning() << component.errors();
    abort();
  }
  qInfo() << QStringLiteral("Subwindow status: `%1`.").arg(component.status());

  QObject *object = component.create();
  Q_ASSERT(object);

  QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
  object->setParent(engine);

  return qobject_cast<QQuickWindow *>(object);
}

// -----------------------------------------------------------------------------

void App::initContentApp () {
  shared_ptr<linphone::Config> config = getConfigIfExists(*mParser);
  bool mustBeIconified = false;

  // Destroy qml components and linphone core if necessary.
  if (mEngine) {
    setOpened(false);
    qInfo() << QStringLiteral("Restarting app...");
    delete mEngine;

    mNotifier = nullptr;
    mSystemTrayIcon = nullptr;

    CoreManager::uninit();

    initLocale(config);
  } else {
    // Update and download codecs.
    VideoCodecsModel::updateCodecs();
    VideoCodecsModel::downloadUpdatableCodecs(this);

    // Don't quit if last window is closed!!!
    setQuitOnLastWindowClosed(false);

    // Deal with received messages and CLI.
    QObject::connect(this, &App::receivedMessage, this, [](int, const QByteArray &byteArray) {
      QString command(byteArray);
      qInfo() << QStringLiteral("Received command from other application: `%1`.").arg(command);
      Cli::executeCommand(command);
    });

    #ifndef Q_OS_MACOS
      mustBeIconified = mParser->isSet("iconified");
    #endif // ifndef Q_OS_MACOS

    mColors = new Colors(this);
  }

  // Change colors if necessary.
  mColors->useConfig(config);

  // Init core.
  CoreManager::init(this, mParser->value("config"));

  // Execute command argument if needed.
  if (!mEngine) {
    const QString commandArgument = getCommandArgument();
    if (!commandArgument.isEmpty()) {
      Cli::CommandFormat format;
      Cli::executeCommand(commandArgument, &format);
      if (format == Cli::UriFormat)
        mustBeIconified = true;
    }
  }

  // Init engine content.
  mEngine = new QQmlApplicationEngine();

  // Provide `+custom` folders for custom components and `5.9` for old components.
  {
    QStringList selectors("custom");
    const QVersionNumber &version = QLibraryInfo::version();
    if (version.majorVersion() == 5 && version.minorVersion() == 9)
      selectors.push_back("5.9");
    (new QQmlFileSelector(mEngine, mEngine))->setExtraSelectors(selectors);
  }
  qInfo() << QStringLiteral("Activated selectors:") << QQmlFileSelector::get(mEngine)->selector()->allSelectors();

  // Set modules paths.
  mEngine->addImportPath(":/ui/modules");
  mEngine->addImportPath(":/ui/scripts");
  mEngine->addImportPath(":/ui/views");

  // Provide avatars/thumbnails providers.
  mEngine->addImageProvider(AvatarProvider::ProviderId, new AvatarProvider());
  mEngine->addImageProvider(ImageProvider::ProviderId, new ImageProvider());
  mEngine->addImageProvider(ThumbnailProvider::ProviderId, new ThumbnailProvider());

  registerTypes();
  registerSharedTypes();
  registerToolTypes();
  registerSharedToolTypes();

  // Enable notifications.
  mNotifier = new Notifier(mEngine);

  // Load main view.
  qInfo() << QStringLiteral("Loading main view...");
  mEngine->load(QUrl(QmlViewMainWindow));
  if (mEngine->rootObjects().isEmpty())
    qFatal("Unable to open main window.");

  QObject::connect(
    CoreManager::getInstance()->getHandlers().get(),
    &CoreHandlers::coreStarted,
    [this, mustBeIconified]() {
      openAppAfterInit(mustBeIconified);
    }
  );
}

// -----------------------------------------------------------------------------

QString App::getCommandArgument () {
  const QStringList &arguments = mParser->positionalArguments();
  return arguments.empty() ? QString("") : arguments[0];
}

// -----------------------------------------------------------------------------

#ifdef Q_OS_MACOS

  bool App::event (QEvent *event) {
    if (event->type() == QEvent::FileOpen) {
      const QString url = static_cast<QFileOpenEvent *>(event)->url().toString();
      if (isSecondary()) {
        sendMessage(url.toLocal8Bit(), -1);
        ::exit(EXIT_SUCCESS);
      }

      Cli::executeCommand(url);
    }

    return SingleApplication::event(event);
  }

#endif // ifdef Q_OS_MACOS

// -----------------------------------------------------------------------------

QQuickWindow *App::getCallsWindow () const {
  if (CoreManager::getInstance()->getCore()->getConfig()->getInt(
    SettingsModel::UiSection, "disable_calls_window", 0
  ))
    return nullptr;

  return mCallsWindow;
}

QQuickWindow *App::getMainWindow () const {
  return qobject_cast<QQuickWindow *>(
    const_cast<QQmlApplicationEngine *>(mEngine)->rootObjects().at(0)
  );
}

QQuickWindow *App::getSettingsWindow () const {
  return mSettingsWindow;
}

// -----------------------------------------------------------------------------

void App::smartShowWindow (QQuickWindow *window) {
  if (!window)
    return;

  window->setVisible(true);

  if (window->visibility() == QWindow::Minimized)
    window->show();

  window->raise();
  window->requestActivate();
}

// -----------------------------------------------------------------------------

bool App::hasFocus () const {
  return getMainWindow()->isActive() || (mCallsWindow && mCallsWindow->isActive());
}

// -----------------------------------------------------------------------------

void App::createParser () {
  delete mParser;

  mParser = new QCommandLineParser();
  mParser->setApplicationDescription(tr("applicationDescription"));
  mParser->addPositionalArgument("command", tr("commandLineDescription").replace("%1", APPLICATION_NAME), "[command]");
  mParser->addOptions({
    { { "h", "help" }, tr("commandLineOptionHelp") },
    { "cli-help", tr("commandLineOptionCliHelp").replace("%1", APPLICATION_NAME) },
    { { "v", "version" }, tr("commandLineOptionVersion") },
    { "config", tr("commandLineOptionConfig").replace("%1", EXECUTABLE_NAME), tr("commandLineOptionConfigArg") },
    #ifndef Q_OS_MACOS
      { "iconified", tr("commandLineOptionIconified") },
    #endif // ifndef Q_OS_MACOS
    { { "V", "verbose" }, tr("commandLineOptionVerbose") }
  });
}

// -----------------------------------------------------------------------------

template<typename T, T *(*function)()>
static QObject *makeSharedSingleton (QQmlEngine *, QJSEngine *) {
  QObject *object = (*function)();
  QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
  return object;
}

template<typename T, T *(*function)(void)>
static inline void registerSharedSingletonType (const char *name) {
  qmlRegisterSingletonType<T>(MainQmlUri, 1, 0, name, makeSharedSingleton<T, function>);
}

template<typename T, T *(CoreManager::*function)() const>
static QObject *makeSharedSingleton (QQmlEngine *, QJSEngine *) {
  QObject *object = (CoreManager::getInstance()->*function)();
  QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
  return object;
}

template<typename T, T *(CoreManager::*function)() const>
static inline void registerSharedSingletonType (const char *name) {
  qmlRegisterSingletonType<T>(MainQmlUri, 1, 0, name, makeSharedSingleton<T, function>);
}

template<typename T>
static inline void registerUncreatableType (const char *name) {
  qmlRegisterUncreatableType<T>(MainQmlUri, 1, 0, name, QLatin1String("Uncreatable"));
}

template<typename T>
static inline void registerSingletonType (const char *name) {
  qmlRegisterSingletonType<T>(MainQmlUri, 1, 0, name, [](QQmlEngine *engine, QJSEngine *) -> QObject *{
    return new T(engine);
  });
}

template<typename T>
static inline void registerType (const char *name) {
  qmlRegisterType<T>(MainQmlUri, 1, 0, name);
}

template<typename T>
static inline void registerToolType (const char *name) {
  qmlRegisterSingletonType<T>(name, 1, 0, name, [](QQmlEngine *engine, QJSEngine *) -> QObject *{
    return new T(engine);
  });
}

template<typename T, typename Owner, T *(Owner::*function)() const>
static QObject *makeSharedTool (QQmlEngine *, QJSEngine *) {
  QObject *object = (Owner::getInstance()->*function)();
  QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
  return object;
}

template<typename T, typename Owner, T *(Owner::*function)() const>
static inline void registerSharedToolType (const char *name) {
  qmlRegisterSingletonType<T>(name, 1, 0, name, makeSharedTool<T, Owner, function>);
}

void App::registerTypes () {
  qInfo() << QStringLiteral("Registering types...");

  qRegisterMetaType<shared_ptr<linphone::ProxyConfig>>();
  qRegisterMetaType<ChatModel::EntryType>();

  registerType<AssistantModel>("AssistantModel");
  registerType<AuthenticationNotifier>("AuthenticationNotifier");
  registerType<CallsListProxyModel>("CallsListProxyModel");
  registerType<Camera>("Camera");
  registerType<CameraPreview>("CameraPreview");
  registerType<ChatProxyModel>("ChatProxyModel");
  registerType<ConferenceHelperModel>("ConferenceHelperModel");
  registerType<ConferenceModel>("ConferenceModel");
  registerType<ContactsListProxyModel>("ContactsListProxyModel");
  registerType<FileDownloader>("FileDownloader");
  registerType<FileExtractor>("FileExtractor");
  registerType<SipAddressesProxyModel>("SipAddressesProxyModel");
  registerType<SoundPlayer>("SoundPlayer");
  registerType<TelephoneNumbersModel>("TelephoneNumbersModel");

  registerSingletonType<AudioCodecsModel>("AudioCodecsModel");
  registerSingletonType<OwnPresenceModel>("OwnPresenceModel");
  registerSingletonType<Presence>("Presence");
  registerSingletonType<TimelineModel>("TimelineModel");
  registerSingletonType<UrlHandlers>("UrlHandlers");
  registerSingletonType<VideoCodecsModel>("VideoCodecsModel");

  registerUncreatableType<CallModel>("CallModel");
  registerUncreatableType<ChatModel>("ChatModel");
  registerUncreatableType<ConferenceHelperModel::ConferenceAddModel>("ConferenceAddModel");
  registerUncreatableType<ContactModel>("ContactModel");
  registerUncreatableType<SipAddressObserver>("SipAddressObserver");
  registerUncreatableType<VcardModel>("VcardModel");
}

void App::registerSharedTypes () {
  qInfo() << QStringLiteral("Registering shared types...");

  registerSharedSingletonType<App, &App::getInstance>("App");
  registerSharedSingletonType<CoreManager, &CoreManager::getInstance>("CoreManager");
  registerSharedSingletonType<SettingsModel, &CoreManager::getSettingsModel>("SettingsModel");
  registerSharedSingletonType<AccountSettingsModel, &CoreManager::getAccountSettingsModel>("AccountSettingsModel");
  registerSharedSingletonType<SipAddressesModel, &CoreManager::getSipAddressesModel>("SipAddressesModel");
  registerSharedSingletonType<CallsListModel, &CoreManager::getCallsListModel>("CallsListModel");
  registerSharedSingletonType<ContactsListModel, &CoreManager::getContactsListModel>("ContactsListModel");
}

void App::registerToolTypes () {
  qInfo() << QStringLiteral("Registering tool types...");

  registerToolType<Clipboard>("Clipboard");
  registerToolType<DesktopTools>("DesktopTools");
  registerToolType<TextToSpeech>("TextToSpeech");
  registerToolType<Units>("Units");
}

void App::registerSharedToolTypes () {
  qInfo() << QStringLiteral("Registering shared tool types...");

  registerSharedToolType<Colors, App, &App::getColors>("Colors");
}

// -----------------------------------------------------------------------------

void App::setTrayIcon () {
  QQuickWindow *root = getMainWindow();
  QSystemTrayIcon *systemTrayIcon = new QSystemTrayIcon(mEngine);

  // trayIcon: Right click actions.
  QAction *settingsAction = new QAction(tr("settings"), root);
  root->connect(settingsAction, &QAction::triggered, root, [this] {
    App::smartShowWindow(getSettingsWindow());
  });

  QAction *aboutAction = new QAction(tr("about"), root);
  root->connect(aboutAction, &QAction::triggered, root, [root] {
    App::smartShowWindow(root);
    QMetaObject::invokeMethod(
      root, AttachVirtualWindowMethodName, Qt::DirectConnection,
      Q_ARG(QVariant, QUrl(AboutPath)), Q_ARG(QVariant, QVariant()), Q_ARG(QVariant, QVariant())
    );
  });

  QAction *restoreAction = new QAction(tr("restore"), root);
  root->connect(restoreAction, &QAction::triggered, root, [root] {
    smartShowWindow(root);
  });

  QAction *quitAction = new QAction(tr("quit"), root);
  root->connect(quitAction, &QAction::triggered, this, &App::quit);

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
  menu->addAction(settingsAction);
  menu->addAction(aboutAction);
  menu->addSeparator();
  menu->addAction(restoreAction);
  menu->addSeparator();
  menu->addAction(quitAction);

  systemTrayIcon->setContextMenu(menu);
  systemTrayIcon->setIcon(QIcon(LinphoneUtils::WindowIconPath));
  systemTrayIcon->setToolTip(APPLICATION_NAME);
  systemTrayIcon->show();

  mSystemTrayIcon = systemTrayIcon;
}

// -----------------------------------------------------------------------------

void App::initLocale (const shared_ptr<linphone::Config> &config) {
  // Try to use preferred locale.
  QString locale;
  if (config)
    locale = Utils::coreStringToAppString(config->getString(SettingsModel::UiSection, "locale", ""));

  if (!locale.isEmpty() && installLocale(*this, *mTranslator, QLocale(locale))) {
    mLocale = locale;
    return;
  }

  // Try to use system locale.
  QLocale sysLocale = QLocale::system();
  if (installLocale(*this, *mTranslator, sysLocale)) {
    mLocale = sysLocale.name();
    return;
  }

  // Use english.
  mLocale = DefaultLocale;
  if (!installLocale(*this, *mTranslator, QLocale(mLocale)))
    qFatal("Unable to install default translator.");
}

QString App::getConfigLocale () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getConfig()->getString(
      SettingsModel::UiSection, "locale", ""
    )
  );
}

void App::setConfigLocale (const QString &locale) {
  CoreManager::getInstance()->getCore()->getConfig()->setString(
    SettingsModel::UiSection, "locale", Utils::appStringToCoreString(locale)
  );

  emit configLocaleChanged(locale);
}

QString App::getLocale () const {
  return mLocale;
}

// -----------------------------------------------------------------------------

#ifdef Q_OS_LINUX

void App::setAutoStart (bool enabled) {
  if (enabled == mAutoStart)
    return;

  QDir dir(AutoStartDirectory);
  if (!dir.exists() && !dir.mkpath(AutoStartDirectory)) {
    qWarning() << QStringLiteral("Unable to build autostart dir path: `%1`.").arg(AutoStartDirectory);
    return;
  }

  QFile file(AutoStartDirectory + EXECUTABLE_NAME ".desktop");

  if (!enabled) {
    if (file.exists() && !file.remove()) {
      qWarning() << QLatin1String("Unable to remove autostart file: `" EXECUTABLE_NAME ".desktop`.");
      return;
    }

    mAutoStart = enabled;
    emit autoStartChanged(enabled);
    return;
  }

  if (!file.open(QFile::WriteOnly)) {
    qWarning() << "Unable to open autostart file: `" EXECUTABLE_NAME ".desktop`.";
    return;
  }

  QString fileContent(
    "[Desktop Entry]\n"
    "Name=" APPLICATION_NAME "\n"
    "GenericName=SIP Phone\n"
    "Comment=" APPLICATION_DESCRIPTION "\n"
    "Type=Application\n"
    "Exec=" + applicationFilePath() + "\n"
    "Icon=\n"
    "Terminal=false\n"
    "Categories=Network;Telephony;\n"
    "MimeType=x-scheme-handler/sip-linphone;x-scheme-handler/sip;x-scheme-handler/sips-linphone;x-scheme-handler/sips;\n"
  );
  QTextStream out(&file);
  out << fileContent;

  mAutoStart = enabled;
  emit autoStartChanged(enabled);
}

#elif defined(Q_OS_MACOS)

void App::setAutoStart (bool enabled) {
  if (enabled == mAutoStart)
    return;

  if (getMacOsBundlePath().isEmpty()) {
    qWarning() << QStringLiteral("Application is not installed. Unable to change autostart state.");
    return;
  }

  if (enabled)
    QProcess::execute(OsascriptExecutable, {
      "-e", "tell application \"System Events\" to make login item at end with properties"
      "{ path: \"" + getMacOsBundlePath() + "\", hidden: false }"
    });
  else
    QProcess::execute(OsascriptExecutable, {
      "-e", "tell application \"System Events\" to delete login item \"" + getMacOsBundleName() + "\""
    });

  mAutoStart = enabled;
  emit autoStartChanged(enabled);
}

#else

void App::setAutoStart (bool enabled) {
  if (enabled == mAutoStart)
    return;

  QSettings settings(AutoStartSettingsFilePath, QSettings::NativeFormat);
  if (enabled)
    settings.setValue(EXECUTABLE_NAME, QDir::toNativeSeparators(applicationFilePath()));
  else
    settings.remove(EXECUTABLE_NAME);

  mAutoStart = enabled;
  emit autoStartChanged(enabled);
}

#endif // ifdef Q_OS_LINUX

// -----------------------------------------------------------------------------

void App::openAppAfterInit (bool mustBeIconified) {
  qInfo() << QStringLiteral("Open " APPLICATION_NAME " app.");

  // Create other windows.
  mCallsWindow = createSubWindow(mEngine, QmlViewCallsWindow);
  mSettingsWindow = createSubWindow(mEngine, QmlViewSettingsWindow);
  QObject::connect(mSettingsWindow, &QWindow::visibilityChanged, this, [](QWindow::Visibility visibility) {
    if (visibility == QWindow::Hidden) {
      qInfo() << QStringLiteral("Update nat policy.");
      shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
      core->setNatPolicy(core->getNatPolicy());
    }
  });

  QQuickWindow *mainWindow = getMainWindow();

  #ifndef __APPLE__
    // Enable TrayIconSystem.
    if (!QSystemTrayIcon::isSystemTrayAvailable())
      qWarning("System tray not found on this system.");
    else
      setTrayIcon();

    if (!mustBeIconified)
      smartShowWindow(mainWindow);
  #else
    Q_UNUSED(mustBeIconified);
    smartShowWindow(mainWindow);
  #endif // ifndef __APPLE__

  // Display Assistant if it does not exist proxy config.
  if (CoreManager::getInstance()->getCore()->getProxyConfigList().empty())
    QMetaObject::invokeMethod(mainWindow, "setView", Q_ARG(QVariant, AssistantViewName), Q_ARG(QVariant, QString("")));

  #ifdef ENABLE_UPDATE_CHECK
    QTimer *timer = new QTimer(mEngine);
    timer->setInterval(VersionUpdateCheckInterval);

    QObject::connect(timer, &QTimer::timeout, this, &App::checkForUpdate);
    timer->start();

    checkForUpdate();
  #endif // ifdef ENABLE_UPDATE_CHECK

  setOpened(true);
}

// -----------------------------------------------------------------------------

void App::checkForUpdate () {
  CoreManager::getInstance()->getCore()->checkForUpdate(
    Utils::appStringToCoreString(applicationVersion())
  );
}
