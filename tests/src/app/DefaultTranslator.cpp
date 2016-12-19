#include <QDirIterator>
#include <QtDebug>

#include "DefaultTranslator.hpp"

// =============================================================================

DefaultTranslator::DefaultTranslator () {
  QDirIterator it(":", QDirIterator::Subdirectories);
  while (it.hasNext()) {
    QFileInfo info(it.next());

    if (info.suffix() == "qml") {
      QString basename = info.baseName();

      if (m_contexts.contains(basename))
        qWarning() << QStringLiteral("QML context `%1` already exists in contexts list.").arg(basename);
      else
        m_contexts << basename;
    }
  }
}

QString DefaultTranslator::translate (
  const char *context,
  const char *source_text,
  const char *disambiguation,
  int n
) const {
  QString translation = QTranslator::translate(context, source_text, disambiguation, n);

  if (translation.length() == 0 && m_contexts.contains(context))
    qWarning() << QStringLiteral("Unable to find a translation. (context=%1, label=%2)")
      .arg(context).arg(source_text);

  return translation;
}
