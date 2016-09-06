#include <cstdlib>

#include <QtDebug>

#include "app.hpp"

#define LANGUAGES_PATH ":/languages/"

// ===================================================================

App::App(int &argc, char **argv) : QGuiApplication(argc, argv) {
  // Try to enable system translation by default. (else english)
  if (m_translator.load(QString(LANGUAGES_PATH) + QLocale::system().name()) ||
      m_translator.load(LANGUAGES_PATH "en")) {
    this->installTranslator(&m_translator);
  } else {
    qWarning() << "No translation found.";
  }
}
