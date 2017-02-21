/*
 * DefaultTranslator.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
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

DefaultTranslator::DefaultTranslator () {
  QDirIterator it(":", QDirIterator::Subdirectories);
  while (it.hasNext()) {
    QFileInfo info(it.next());

    if (info.suffix() == "qml") {
      // Ignore extra selectors.
      QString dir = info.absoluteDir().dirName();
      if (dir == "+linux" || dir == "+mac" || dir == "+windows")
        continue;

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
