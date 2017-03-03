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

#include <QCommandLineParser>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

#include "../externals/single-application/SingleApplication.hpp"

// =============================================================================

class DefaultTranslator;

class App : public SingleApplication {
  Q_OBJECT;

  Q_PROPERTY(QString configLocale READ getConfigLocale WRITE setConfigLocale NOTIFY configLocaleChanged);
  Q_PROPERTY(QString locale READ getLocale CONSTANT);
  Q_PROPERTY(QVariantList availableLocales READ getAvailableLocales CONSTANT);

public:
  App (int &argc, char *argv[]);
  ~App ();

  void initContentApp ();
  void parseArgs ();

  QQmlEngine *getEngine () {
    return &m_engine;
  }

  Notifier *getNotifier () const {
    return m_notifier;
  }

  QQuickWindow *getCallsWindow () const;
  QQuickWindow *getMainWindow () const;

  bool hasFocus () const;

  Q_INVOKABLE QQuickWindow *getSettingsWindow () const;

  static App *getInstance () {
    return static_cast<App *>(QApplication::instance());
  }

public slots:
  void quit ();

signals:
  void configLocaleChanged (const QString &locale);

private:
  void registerTypes ();
  void createSubWindows ();
  void setTrayIcon ();

  QString getConfigLocale () const;
  void setConfigLocale (const QString &locale);

  QString getLocale () const;

  QVariantList getAvailableLocales () const {
    return m_available_locales;
  }

  QCommandLineParser m_parser;
  QQmlApplicationEngine m_engine;

  DefaultTranslator *m_translator = nullptr;

  Notifier *m_notifier = nullptr;

  QVariantList m_available_locales;
  QString m_locale;

  QQuickWindow *m_calls_window = nullptr;
  QQuickWindow *m_settings_window = nullptr;
};

#endif // APP_H_
