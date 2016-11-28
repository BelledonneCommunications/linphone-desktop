#ifndef DEFAULT_TRANSLATOR_H_
#define DEFAULT_TRANSLATOR_H_

#include <QTranslator>

// ===================================================================

class DefaultTranslator : public QTranslator {
  QString translate (
    const char *context,
    const char *source_text,
    const char *disambiguation = Q_NULLPTR,
    int n = -1
  ) const override;
};

#endif
