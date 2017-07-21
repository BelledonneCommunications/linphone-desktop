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

#include <QQmlApplicationEngine>
#include <QQuickWindow>

#include "../components/notifier/Notifier.hpp"
#include "../components/other/colors/Colors.hpp"
#include "single-application/SingleApplication.hpp"

#define APP_CODE_RESTART 1000

// =============================================================================

class QCommandLineParser;

class Cli;
class DefaultTranslator;

class App : public SingleApplication {
  Q_OBJECT;

  Q_PROPERTY(QString configLocale READ getConfigLocale WRITE setConfigLocale NOTIFY configLocaleChanged);
  Q_PROPERTY(QString locale READ getLocale CONSTANT);
  Q_PROPERTY(QVariantList availableLocales READ getAvailableLocales CONSTANT);
  Q_PROPERTY(QString qtVersion READ getQtVersion CONSTANT);

public:
  App (int &argc, char *argv[]);
  ~App ();

  void initContentApp ();

  QString getCommandArgument ();

  QQmlEngine *getEngine () {
    return mEngine;
  }

  Notifier *getNotifier () const {
    return mNotifier;
  }

  const Colors *getColors () const {
    return mColors;
  }

  QQuickWindow *getMainWindow () const;

  bool hasFocus () const;

  static App *getInstance () {
    return static_cast<App *>(QApplication::instance());
  }

  Q_INVOKABLE void restart () {
    exit(APP_CODE_RESTART);
  }

  Q_INVOKABLE QQuickWindow *getCallsWindow ();
  Q_INVOKABLE QQuickWindow *getSettingsWindow ();

  Q_INVOKABLE static void smartShowWindow (QQuickWindow *window);

signals:
  void configLocaleChanged (const QString &locale);

private:
  void createParser ();

  void registerTypes ();
  void registerSharedTypes ();
  void registerToolTypes ();
  void registerSharedToolTypes ();

  void setTrayIcon ();
  void createNotifier ();

  void initLocale (const std::shared_ptr<linphone::Config> &config);

  QString getConfigLocale () const;
  void setConfigLocale (const QString &locale);

  QString getLocale () const;

  QVariantList getAvailableLocales () const {
    return mAvailableLocales;
  }

  void openAppAfterInit ();

  static void checkForUpdate ();

  static QString getQtVersion () {
    return qVersion();
  }

  QCommandLineParser *mParser = nullptr;

  QVariantList mAvailableLocales;
  QString mLocale;

  QQmlApplicationEngine *mEngine = nullptr;

  DefaultTranslator *mTranslator = nullptr;
  Notifier *mNotifier = nullptr;

  QQuickWindow *mCallsWindow = nullptr;
  QQuickWindow *mSettingsWindow = nullptr;

  Colors *mColors = nullptr;

  Cli *mCli = nullptr;
};

#endif // APP_H_
