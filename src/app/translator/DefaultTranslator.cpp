/*
 * DefaultTranslator.cpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#include <QDirIterator>
#include <QtDebug>

#include "DefaultTranslator.hpp"

// =============================================================================

DefaultTranslator::DefaultTranslator (QObject *parent) : QTranslator(parent) {
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
      if (mContexts.contains(basename))
        qWarning() << QStringLiteral("QML context `%1` already exists in contexts list.").arg(basename);
      else
        mContexts << basename;
    }
    end:;
  }
}

QString DefaultTranslator::translate (
  const char *context,
  const char *sourceText,
  const char *disambiguation,
  int n
) const {
  if (!context)
    return QString("");

  QString translation = QTranslator::translate(context, sourceText, disambiguation, n);

  if (translation.length() == 0 && mContexts.contains(context))
    qWarning() << QStringLiteral("Unable to find a translation. (context=%1, label=%2)")
      .arg(context).arg(sourceText);

  return translation;
}
