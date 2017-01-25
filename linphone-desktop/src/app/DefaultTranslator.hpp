#ifndef DEFAULT_TRANSLATOR_H_
#define DEFAULT_TRANSLATOR_H_

#include <QSet>
#include <QTranslator>

// =============================================================================

class DefaultTranslator : public QTranslator {
public:
  DefaultTranslator ();
  ~DefaultTranslator () = default;

  QString translate (
    const char *context,
    const char *source_text,
    const char *disambiguation = Q_NULLPTR,
    int n = -1
  ) const override;

private:
  QSet<QString> m_contexts;
};

#endif // DEFAULT_TRANSLATOR_H_
