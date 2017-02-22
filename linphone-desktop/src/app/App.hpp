/*
 * App.hpp
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

#ifndef APP_H_
#define APP_H_

#include "../components/notifier/Notifier.hpp"
#include "AvatarProvider.hpp"
#include "DefaultTranslator.hpp"
#include "ThumbnailProvider.hpp"

#include <QApplication>
#include <QCommandLineParser>
#include <QQmlApplicationEngine>
#include <QQmlFileSelector>
#include <QQuickWindow>
#include <QSystemTrayIcon>

// =============================================================================

class App : public QApplication {
  Q_OBJECT;

public:
  QQmlEngine *getEngine () {
    return &m_engine;
  }

  Notifier *getNotifier () const {
    return m_notifier;
  }

  QQuickWindow *getCallsWindow () const;
  QQuickWindow *getMainWindow () const;

  bool hasFocus () const;

  void initContentApp ();

  Q_INVOKABLE QQuickWindow *getSettingsWindow () const;

  Q_INVOKABLE QString locale () const {
    return m_locale;
  }

  void parseArgs ();

  static void create (int &argc, char **argv) {
    if (!m_instance) {
      // Instance must be exists before content.
      m_instance = new App(argc, argv);
    }
  }

  static App *getInstance () {
    return m_instance;
  }

public slots:
  void quit ();

private:
  App (int &argc, char **argv);
  ~App () = default;

  void registerTypes ();
  void createSubWindows ();
  void setTrayIcon ();

  QCommandLineParser m_parser;
  QQmlApplicationEngine m_engine;
  QQmlFileSelector *m_file_selector = nullptr;
  QSystemTrayIcon *m_system_tray_icon = nullptr;

  AvatarProvider m_avatar_provider;
  ThumbnailProvider m_thumbnail_provider;
  DefaultTranslator m_default_translator;
  QTranslator m_english_translator;

  Notifier *m_notifier = nullptr;
  QString m_locale = "en";

  QQuickWindow *m_calls_window = nullptr;
  QQuickWindow *m_settings_window = nullptr;

  static App *m_instance;
};

#endif // APP_H_
