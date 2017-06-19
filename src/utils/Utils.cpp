/*
 * utils.cpp
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
 *  Created on: March 24, 2017
 *      Author: Ronan Abhamon
 */

#include <QFileInfo>

#include "Utils.hpp"

// =============================================================================

char *Utils::rstrstr (const char *a, const char *b) {
  size_t a_len = strlen(a);
  size_t b_len = strlen(b);

  if (b_len > a_len)
    return nullptr;

  for (const char *s = a + a_len - b_len; s >= a; --s) {
    if (!strncmp(s, b, b_len))
      return const_cast<char *>(s);
  }

  return nullptr;
}

// -----------------------------------------------------------------------------

#define SAFE_FILE_PATH_LIMIT 100

QString Utils::getSafeFilePath (const QString &filePath, bool *soFarSoGood) {
  if (soFarSoGood)
    *soFarSoGood = true;

  QFileInfo info(filePath);
  if (!info.exists())
    return filePath;

  const QString prefix = QStringLiteral("%1/%2").arg(info.absolutePath()).arg(info.baseName());
  const QString ext = info.completeSuffix();

  for (int i = 1; i < SAFE_FILE_PATH_LIMIT; ++i) {
    QString safePath = QStringLiteral("%1 (%3).%4").arg(prefix).arg(i).arg(ext);
    if (!QFileInfo::exists(safePath))
      return safePath;
  }

  if (soFarSoGood)
    *soFarSoGood = false;

  return QString("");
}

#undef SAFE_FILE_PATH_LIMIT
