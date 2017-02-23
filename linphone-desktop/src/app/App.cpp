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
#include "../components/contacts/ContactsListProxyModel.hpp"
#include "../components/core/CoreManager.hpp"
#include "../components/settings/AccountSettingsModel.hpp"
#include "../components/settings/SettingsModel.hpp"
#include "../components/smart-search-bar/SmartSearchBarModel.hpp"
#include "../components/timeline/TimelineModel.hpp"
#include "../utils.hpp"

#include "App.hpp"
#include "DefaultTranslator.hpp"
#include "Logger.hpp"

#include <QDir>
#include <QFileSelector>
#include <QMenu>
#include <QTimer>
#include <QtDebug>

#define DEFAULT_LOCALE "en"

#define LANGUAGES_PATH ":/languages/"
#define WINDOW_ICON_PATH ":/assets/images/linphone_logo.svg"

// The main windows of Linphone desktop.
#define QML_VIEW_MAIN_WINDOW "qrc:/ui/views/App/Main/MainWindow.qml"
#define QML_VIEW_CALLS_WINDOW "qrc:/ui/views/App/Calls/CallsWindow.qml"
#define QML_VIEW_SETTINGS_WINDOW "qrc:/ui/views/App/Settings/SettingsWindow.qml"

// =============================================================================

App *App::m_instance = nullptr;

inline bool installLocale (App &app, QTranslator &translator, const QLocale &locale) {
  return translator.load(locale, LANGUAGES_PATH) && app.installTranslator(&translator);
}

App::App (int &argc, char **argv) : QApplication(argc, argv) {
  setApplicationVersion("4.0");

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

// -----------------------------------------------------------------------------

void App::initContentApp () {
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

  // Don't quit if last window is closed!!!
  setQuitOnLastWindowClosed(false);

  // Init core.
  CoreManager::init(m_parser.value("config"));
  qInfo() << "Core manager initialized.";
  qInfo() << "Activated selectors:" << QQmlFileSelector::get(&m_engine)->selector()->allSelectors();

  // Try to use preferred locale.
  {
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

  // Register types ans make sub windows.
  registerTypes();
  createSubWindows();

  // Enable notifications.
  m_notifier = new Notifier();

  CoreManager::getInstance()->enableHandlers();

  // Load main view.
  qInfo() << "Loading main view...";
  m_engine.load(QUrl(QML_VIEW_MAIN_WINDOW));
  if (m_engine.rootObjects().isEmpty())
    qFatal("Unable to open main window.");

  #ifndef __APPLE__

    // Enable TrayIconSystem.
    if (!QSystemTrayIcon::isSystemTrayAvailable())
      qWarning("System tray not found on this system.");
    else
      setTrayIcon();

  #endif // ifndef __APPLE__

  if (!m_parser.isSet("iconified"))
    getMainWindow()->showNormal();

  if (m_parser.isSet("selftest"))
    QTimer::singleShot(300, this, &App::quit);
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
    #endif // __APPLE__
    { "selftest", tr("commandLineOptionSelftest") },
    { { "V", "verbose" }, tr("commandLineOptionVerbose") }
  });

  m_parser.process(*this);

  if (m_parser.isSet("verbose")) {
    Logger::instance()->setVerbose(true);
  }
}

// -----------------------------------------------------------------------------

QQuickWindow *App::getCallsWindow () const {
  return m_calls_window;
}

QQuickWindow *App::getMainWindow () const {
  QQmlApplicationEngine &engine = const_cast<QQmlApplicationEngine &>(m_engine);
  return qobject_cast<QQuickWindow *>(engine.rootObjects().at(0));
}

QQuickWindow *App::getSettingsWindow () const {
  return m_settings_window;
}

// -----------------------------------------------------------------------------

bool App::hasFocus () const {
  return getMainWindow()->isActive() || m_calls_window->isActive();
}

// -----------------------------------------------------------------------------

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
      return CoreManager::getInstance()->getCallsListModel();
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

// -----------------------------------------------------------------------------

inline QQuickWindow *createSubWindow (QQmlApplicationEngine &engine, const char *path) {
  QQmlComponent component(&engine, QUrl(path));
  if (component.isError()) {
    qWarning() << component.errors();
    abort();
  }

  // Default Ownership is Cpp: http://doc.qt.io/qt-5/qqmlengine.html#ObjectOwnership-enum
  return qobject_cast<QQuickWindow *>(component.create());
}

void App::createSubWindows () {
  qInfo() << "Create sub windows...";

  m_calls_window = createSubWindow(m_engine, QML_VIEW_CALLS_WINDOW);
  m_settings_window = createSubWindow(m_engine, QML_VIEW_SETTINGS_WINDOW);
}

// -----------------------------------------------------------------------------

void App::setTrayIcon () {
  QQuickWindow *root = getMainWindow();
  QMenu *menu = new QMenu();

  m_system_tray_icon = new QSystemTrayIcon(root);

  // trayIcon: Right click actions.
  QAction *quit_action = new QAction("Quit", root);
  root->connect(quit_action, &QAction::triggered, this, &App::quit);

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

void App::quit () {
  if (m_parser.isSet("selftest")) {
    cout << tr("selftestResult").toStdString() << endl;
  }
  QCoreApplication::quit();
}
