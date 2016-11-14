#include <cstdlib>

#include <QIcon>
#include <QtDebug>

#include "App.hpp"

#define LANGUAGES_PATH ":/languages/"

// ===================================================================

App::App (int &argc, char **argv) : QApplication(argc, argv) {
  // Try to use default locale. Otherwise use english.
  if (m_translator.load(QString(LANGUAGES_PATH) + QLocale::system().name()) ||
      m_translator.load(LANGUAGES_PATH "en")) {
    this->installTranslator(&m_translator);
  } else {
    qWarning() << "No translation found.";
  }

  this->setWindowIcon(QIcon(":/assets/images/linphone.png"));
}
