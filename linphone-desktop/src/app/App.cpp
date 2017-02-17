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

#include "App.hpp"

#include <QMenu>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickView>
#include <QtDebug>

#define LANGUAGES_PATH ":/languages/"
#define WINDOW_ICON_PATH ":/assets/images/linphone_logo.svg"

// The main windows of Linphone desktop.
#define QML_VIEW_MAIN_WINDOW "qrc:/ui/views/App/Main/MainWindow.qml"
#define QML_VIEW_CALLS_WINDOW "qrc:/ui/views/App/Calls/CallsWindow.qml"
#define QML_VIEW_SETTINGS_WINDOW "qrc:/ui/views/App/Settings/SettingsWindow.qml"

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

  // Don't quit if last window is closed!!!
  setQuitOnLastWindowClosed(false);
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

void App::initContentApp () {
  // Init core.
  CoreManager::init();
  qInfo() << "Core manager initialized.";

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
