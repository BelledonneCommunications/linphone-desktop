#ifndef APP_H_
#define APP_H_

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlFileSelector>
#include <QSystemTrayIcon>
#include <QTranslator>

#include "../components/notification/Notification.hpp"

// ===================================================================

class App : public QApplication {
public:
  static void init (int &argc, char **argv) {
    if (!m_instance) {
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

private:
  App (int &argc, char **argv);

  void initContentApp ();

  void registerTypes ();
  void addContextProperties ();
  void setTrayIcon ();

  void setNotificationAttributes ();

  QQmlApplicationEngine m_engine;
  QQmlFileSelector *m_file_selector = nullptr;
  QSystemTrayIcon *m_system_tray_icon = nullptr;
  QTranslator m_translator;

  Notification *m_notification = nullptr;

  static App *m_instance;
};

#endif // APP_H_
