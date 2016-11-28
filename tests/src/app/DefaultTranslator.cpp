#include <QtDebug>

#include "DefaultTranslator.hpp"

// ===================================================================

QString DefaultTranslator::translate (
  const char *context,
  const char *source_text,
  const char *disambiguation,
  int n
) const {
  QString translation = QTranslator::translate(context, source_text, disambiguation, n);

  if (translation.length() == 0)
    qWarning() << QStringLiteral("Unable to found a translation. (context=%1, label=%2)")
      .arg(context).arg(source_text);

  return translation;
}
