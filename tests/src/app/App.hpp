#ifndef APP_H_
#define APP_H_

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlFileSelector>
#include <QTranslator>

// ===================================================================

class App : public QApplication {
public:
  App (int &argc, char **argv);
  virtual ~App () {}

private:
  void registerTypes ();
  void addContextProperties ();
  void setTrayIcon ();

  QQmlApplicationEngine m_engine;
  QQmlFileSelector *m_file_selector;
  QTranslator m_translator;
};

#endif // APP_H_
