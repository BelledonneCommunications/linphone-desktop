#ifndef APP_H_
#define APP_H_

#include <QApplication>
#include <QTranslator>

// TODO: Make it Singleton.
class App : public QApplication {
public:
  App (int &argc, char **argv);
  virtual ~App () {}

private slots:

private:
  QTranslator m_translator;
};

#endif // APP_H_
