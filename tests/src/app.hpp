#ifndef APP_H_
#define APP_H_

#include <QGuiApplication>
#include <QTranslator>

class App : public QGuiApplication {
public:
  App (int &argc, char **argv);
  virtual ~App () {}

private:
  QTranslator m_translator;
};

#endif // APP_H_
