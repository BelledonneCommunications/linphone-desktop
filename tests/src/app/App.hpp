#ifndef APP_H_
#define APP_H_

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlFileSelector>
#include <QSystemTrayIcon>

#include "DefaultTranslator.hpp"

class Notifier;

// ===================================================================

class App : public QApplication {
  Q_OBJECT;

public:
  static void init (int &argc, char **argv) {
    if (!m_instance) {
      // Instance must be exists before content.
      m_instance = new App(argc, argv);
      m_instance->initContentApp();
    }
  }

  static App *getInstance () {
    return m_instance;
  }

  QQmlEngine *getEngine () {
    return &m_engine;
  }

public slots:
  QString locale () const {
    return m_locale;
  }

private:
  App (int &argc, char **argv);
  ~App () = default;

  void initContentApp ();

  void registerTypes ();
  void addContextProperties ();
  void setTrayIcon ();

  QQmlApplicationEngine m_engine;
  QQmlFileSelector *m_file_selector = nullptr;
  QSystemTrayIcon *m_system_tray_icon = nullptr;

  DefaultTranslator m_default_translator;
  QTranslator m_english_translator;

  Notifier *m_notifier = nullptr;
  QString m_locale = "en";

  static App *m_instance;
};

#endif // APP_H_
