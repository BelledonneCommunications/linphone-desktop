/*
 * utils.cpp
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
 *  Created on: March 24, 2017
 *      Author: Ronan Abhamon
 */

#include <QFileInfo>

#include "Utils.hpp"

// =============================================================================

namespace {
  constexpr int SafeFilePathLimit = 100;
}

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

QString Utils::getSafeFilePath (const QString &filePath, bool *soFarSoGood) {
  if (soFarSoGood)
    *soFarSoGood = true;

  QFileInfo info(filePath);
  if (!info.exists())
    return filePath;

  const QString prefix = QStringLiteral("%1/%2").arg(info.absolutePath()).arg(info.baseName());
  const QString ext = info.completeSuffix();

  for (int i = 1; i < SafeFilePathLimit; ++i) {
    QString safePath = QStringLiteral("%1 (%3).%4").arg(prefix).arg(i).arg(ext);
    if (!QFileInfo::exists(safePath))
      return safePath;
  }

  if (soFarSoGood)
    *soFarSoGood = false;

  return QString("");
}
// Data to retrieve WIN32 process
#ifdef _WIN32
#include <windows.h>
struct EnumData {
	DWORD dwProcessId;
	HWND hWnd;
};
// Application-defined callback for EnumWindows
BOOL CALLBACK EnumProc(HWND hWnd, LPARAM lParam) {
// Retrieve storage location for communication data
  EnumData& ed = *(EnumData*)lParam;
  DWORD dwProcessId = 0x0;
// Query process ID for hWnd
  GetWindowThreadProcessId(hWnd, &dwProcessId);
// Apply filter - if you want to implement additional restrictions,
// this is the place to do so.
  if (ed.dwProcessId == dwProcessId) {
	// Found a window matching the process ID
    ed.hWnd = hWnd;
	// Report success
    SetLastError(ERROR_SUCCESS);
	// Stop enumeration
    return FALSE;
  }
// Continue enumeration
  return TRUE;
}
// Main entry
HWND FindWindowFromProcessId(DWORD dwProcessId) {
	EnumData ed = { dwProcessId };
	if (!EnumWindows(EnumProc, (LPARAM)&ed) &&
		(GetLastError() == ERROR_SUCCESS)) {
		return ed.hWnd;
	}
	return NULL;
}

// Helper method for convenience
HWND FindWindowFromProcess(HANDLE hProcess) {
	return FindWindowFromProcessId(GetProcessId(hProcess));
}
#endif

bool Utils::processExists(const quint64& p_processId)
{
#ifdef _WIN32
	return FindWindowFromProcessId(p_processId) != NULL;
#else
	return false;
#endif
}