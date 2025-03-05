/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <QDirIterator>
#include <QtDebug>

#include "DefaultTranslatorCore.hpp"

// =============================================================================

DefaultTranslatorCore::DefaultTranslatorCore (QObject *parent) : QTranslator(parent) {
  QDirIterator it(":", QDirIterator::Subdirectories);
  while (it.hasNext()) {
    QFileInfo info(it.next());

    if (info.suffix() == QLatin1String("qml")) {
      QString dir = info.absoluteDir().absolutePath();

      // Ignore extra selectors.
      // TODO: Remove 5.9 support in July 2019.
      for (const auto &selector : { "+linux", "+mac", "+windows", "+custom", "+5.9" })
        if (dir.contains(selector))
          goto end;

      // Ignore default imports.
      if (dir.startsWith(":/QtQuick"))
        continue;

      QString basename = info.baseName();
      if (!mContexts.contains(basename))
        mContexts << basename;
    }
    end:;
  }
}

QString DefaultTranslatorCore::translate (
  const char *context,
  const char *sourceText,
  const char *disambiguation,
  int n
) const {
  if (!context)
    return QString("");

  QString translation = QTranslator::translate(context, sourceText, disambiguation, n);

  if (translation.length() == 0 && mContexts.contains(context))
    qDebug() << QStringLiteral("Unable to find a translation. (context=%1, label=%2, disambiguation=%3)")
      .arg(context).arg(sourceText).arg(disambiguation);

  return translation;
}
