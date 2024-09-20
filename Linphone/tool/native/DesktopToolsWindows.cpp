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

#include "DesktopToolsWindows.hpp"
#include "config.h"

#include <QDebug>
#include <QRect>
#include <Windows.h>
#include <dwmapi.h>
// =============================================================================

DesktopTools::DesktopTools(QObject *parent) : QObject(parent) {
}

DesktopTools::~DesktopTools() {
	setScreenSaverStatus(true);
}

bool DesktopTools::getScreenSaverStatus() const {
	return mScreenSaverStatus;
}

void DesktopTools::setScreenSaverStatus(bool status) {
	if (status == mScreenSaverStatus) return;

	if (status) SetThreadExecutionState(ES_CONTINUOUS);
	else SetThreadExecutionState(ES_CONTINUOUS | ES_DISPLAY_REQUIRED);

	mScreenSaverStatus = status;
	emit screenSaverStatusChanged(status);
}

//-----------		Get Windows
void getWindowMap(HWND hwnd, LPARAM lParam) {
	const DWORD TITLE_SIZE = 1024;
	WCHAR windowTitle[TITLE_SIZE];

	GetWindowTextW(hwnd, windowTitle, TITLE_SIZE);
	std::wstring title(&windowTitle[0]);
	int length = ::GetWindowTextLength(hwnd);
	if (!IsWindowVisible(hwnd) || length == 0) {
		return;
	}
	QList<QVariantMap> &windowsMap = *reinterpret_cast<QList<QVariantMap> *>(lParam);
	QVariantMap windowMap;
	windowMap["name"] = QString::fromStdWString(title);
	windowMap["windowId"] = (quint64)hwnd;
	windowsMap << windowMap;
}

BOOL CALLBACK getChildWindowsCb(HWND hwnd, LPARAM lParam) {
	getWindowMap(hwnd, lParam);
	return TRUE;
}

BOOL CALLBACK getWindowsCb(HWND hwnd, LPARAM lParam) {
	getWindowMap(hwnd, lParam);
	// EnumChildWindows(hwnd, getChildWindowsCb, lParam);
	return TRUE;
}

QList<QVariantMap> DesktopTools::getWindows() {
#ifdef ENABLE_SCREENSHARING
	QList<QVariantMap> windowsMap;
	EnumWindows(getWindowsCb, reinterpret_cast<LPARAM>(&windowsMap));
	return windowsMap;
#else
	return QList<QVariantMap>();
#endif
}

//-----------------------------------------------------------

#ifndef GCL_HICON
#define GCL_HICON -14
#endif

QImage DesktopTools::getWindowIcon(void *window) {
#ifdef ENABLE_SCREENSHARING
	HICON icon = (HICON)GetClassLongPtr((HWND)window, GCL_HICON);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
	QPixmap pixmap = QtWin::fromHICON(icon);
	return pixmap.toImage();
#else
	return QImage::fromHICON(icon);
#endif

#else
	return QImage();
#endif
}

QImage DesktopTools::takeScreenshot(void *window) {
	QImage image;
#ifdef ENABLE_SCREENSHARING
	RECT rect = {0};

	if (!GetWindowRect((HWND)window, &rect)) {
		qCritical() << "[DesktopTools] Cannot get window size";
		return image;
	}
	HDC hDC = GetDC((HWND)window);
	if (hDC == NULL) {
		qCritical() << "[DesktopTools] GetDC failed.";
		return image;
	}
	HDC hTargetDC = CreateCompatibleDC(hDC);
	if (hTargetDC == NULL) {
		ReleaseDC((HWND)window, hDC);
		qCritical() << "[DesktopTools] CreateCompatibleDC failed.";
		return image;
	}
	HBITMAP hBitmap = CreateCompatibleBitmap(hDC, rect.right - rect.left, rect.bottom - rect.top);
	if (hBitmap == NULL) {
		ReleaseDC((HWND)window, hDC);
		ReleaseDC((HWND)window, hTargetDC);
		qCritical() << "[DesktopTools] CreateCompatibleBitmap failed.";
		return image;
	}
	if (!SelectObject(hTargetDC, hBitmap)) {
		DeleteObject(hBitmap);
		ReleaseDC((HWND)window, hDC);
		ReleaseDC((HWND)window, hTargetDC);
		qCritical() << "[DesktopTools] SelectObject failed.";
		return image;
	}

	if (!PrintWindow((HWND)window, hTargetDC, PW_RENDERFULLCONTENT)) {
		DeleteObject(hBitmap);
		ReleaseDC((HWND)window, hDC);
		ReleaseDC((HWND)window, hTargetDC);
		qCritical() << "[DesktopTools] PrintWindow failed.";
		return image;
	}

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
	QPixmap pixmap = QtWin::fromHBITMAP(hBitmap);
	image = pixmap.toImage();
#else
	image = QImage::fromHBITMAP(hBitmap);
#endif
	DeleteObject(hBitmap);
	ReleaseDC((HWND)window, hDC);
	ReleaseDC((HWND)window, hTargetDC);
#endif
	return image;
}

uintptr_t DesktopTools::getDisplayIndex(void *screenSharing) {
	Q_UNUSED(screenSharing)
#ifdef ENABLE_SCREENSHARING
	return *(uintptr_t *)(&screenSharing);
#else
	return NULL;
#endif
}

QRect DesktopTools::getWindowGeometry(void *screenSharing) {
	Q_UNUSED(screenSharing)
	QRect result;
#ifdef ENABLE_SCREENSHARING
	HWND windowId = *(HWND *)&screenSharing;
	RECT area;
	if (S_OK == DwmGetWindowAttribute(windowId, DWMWA_EXTENDED_FRAME_BOUNDS, &area, sizeof(RECT))) {
		result = QRect(area.left + 1, area.top, area.right - area.left, area.bottom - area.top); // +1 for border
	} else qWarning() << "Cannot get attributes from HWND: " << windowId;
#endif
	return result;
}
