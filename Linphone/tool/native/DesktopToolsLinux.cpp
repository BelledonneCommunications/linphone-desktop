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

#include "DesktopToolsLinux.hpp"
#include "config.h"

#include <QDebug>
#include <QPixmap>
#include <QRect>
#include <QThread>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <fcntl.h>
#include <unistd.h>

#include <X11/cursorfont.h>

// =============================================================================

DesktopTools::~DesktopTools() {
	setScreenSaverStatus(true);
}

bool DesktopTools::getScreenSaverStatus() const {
	return mScreenSaverStatus;
}

void DesktopTools::setScreenSaverStatus(bool status) {
	screenSaverDBus.setScreenSaverStatus(status);
	screenSaverXdg.setScreenSaverStatus(status);

	bool newStatus = screenSaverDBus.getScreenSaverStatus() || screenSaverXdg.getScreenSaverStatus();
	if (newStatus != mScreenSaverStatus) {
		mScreenSaverStatus = newStatus;
		emit screenSaverStatusChanged(mScreenSaverStatus);
	}
}

#define ACTIVE_WINDOWS "_NET_CLIENT_LIST"
QList<QVariantMap> DesktopTools::getWindows() {
#ifdef ENABLE_SCREENSHARING
	QList<QVariantMap> windowsMaps;
	const char *displayStr = getenv("DISPLAY");
	if (displayStr == NULL) displayStr = ":0";
	Display *display = XOpenDisplay(displayStr);
	if (display == NULL) {
		qCritical() << "Can't open X display!";
		return windowsMaps;
	}

	auto screen = DefaultScreen(display);
	auto rootWindow = RootWindow(display, screen);

	// Algo 1
	Atom actualType;
	int format;
	unsigned long numItems;
	unsigned long bytesAfter;
	unsigned char *data = nullptr;
	Window *list;
	char *windowName;
	Atom atom = XInternAtom(display, ACTIVE_WINDOWS, true);
	int status = XGetWindowProperty(display, rootWindow, atom, 0L, (~0L), false, AnyPropertyType, &actualType, &format,
	                                &numItems, &bytesAfter, &data);
	list = (Window *)data;
	if (status >= Success && numItems) {
		for (size_t i = 0; i < numItems; ++i) {
			status = XFetchName(display, list[i], &windowName);
			if (status >= Success) {
				QVariantMap windowMap;
				windowMap["name"] = QString(windowName);
				windowMap["windowId"] = (quint64)list[i];
				windowsMaps << windowMap;
				XFree(windowName);
			}
		}
	}
	XFree(data);

	/* //Algo2
	    Window root_return;
	    Window parent_return;
	    Window *children_return;
	    unsigned int nchildren_return;

	    XQueryTree(display, rootWindow, &root_return, &parent_return, &children_return, &nchildren_return);
	    for (size_t i = 0; i < nchildren_return; ++i) {
	        XWindowAttributes attributes;
	        XGetWindowAttributes(display, children_return[i], &attributes);
	        // XTextProperty name;
	        // XGetWMName(display, children_return[i], &name);
	        char *name;
	        XFetchName(display, children_return[i], &name);
	        if (attributes.c_class == InputOutput && attributes.map_state == IsViewable) {
	            qDebug() << name << attributes.depth << attributes.root;
	            QVariantMap windowMap;
	            windowMap["name"] = QString(name);
	            windowMap["windowId"] = (quint64)children_return[i];
	            windowsMaps << windowMap;
	        }
	        XFree(name);
	    }

	    if (children_return) XFree(children_return);
	    qDebug() << "Found " << nchildren_return << "Windows";
	*/

	return windowsMaps;
#else
	return QList<QVariantMap>();
#endif
}

QImage DesktopTools::takeScreenshot(void *window) {
#ifdef ENABLE_SCREENSHARING
	Display *display = XOpenDisplay(NULL);
	Window rootWindow = (Window)window;
	XWindowAttributes attributes;
	XGetWindowAttributes(display, rootWindow, &attributes);

	int width = attributes.width;
	int height = attributes.height;

	XColor colors;
	XImage *image;
	QImage screenshot(width, height, QImage::Format_RGB32);
	unsigned long red_mask;
	unsigned long green_mask;
	unsigned long blue_mask;

	image = XGetImage(display, rootWindow, 0, 0, width, height, AllPlanes, ZPixmap);
	if (!image) return QImage();
	red_mask = image->red_mask;
	green_mask = image->green_mask;
	blue_mask = image->blue_mask;

	for (int i = 0; i < height; ++i) {
		for (int j = 0; j < width; ++j) {
			colors.pixel = XGetPixel(image, j, i);
			screenshot.setPixel(
			    j, i,
			    qRgb((colors.pixel & red_mask) >> 16, (colors.pixel & green_mask) >> 8, colors.pixel & blue_mask));
		}
	}

	XFree(image);

	return screenshot;
#else
	Q_UNUSED(window)
	return QImage();
#endif
}

QImage DesktopTools::getWindowIcon(void *window) {
#ifdef ENABLE_SCREENSHARING
	Window rootWindow = (Window)window;

	QList<QVariantMap> windowsMaps;
	const char *displayStr = getenv("DISPLAY");
	if (displayStr == NULL) displayStr = ":0";
	Display *display = XOpenDisplay(displayStr);
	if (display == NULL) {
		qCritical() << "Can't open X display!";
		return QImage();
	}

	auto screen = DefaultScreen(display);

	// Algo 1
	Atom actualType;
	int format;
	unsigned long numItems;
	unsigned long bytesAfter;
	unsigned char *data = nullptr;
	Window *list;
	char *windowName;
	Atom atom = XInternAtom(display, "_NET_WM_ICON", true);
	int status = XGetWindowProperty(display, rootWindow, atom, 0L, 1, 0, AnyPropertyType, &actualType, &format,
	                                &numItems, &bytesAfter, &data);
	if (!data) return QImage();
	int width = *(int *)data;
	XFree(data);
	XGetWindowProperty(display, rootWindow, atom, 1, 1, 0, AnyPropertyType, &actualType, &format, &numItems,
	                   &bytesAfter, &data);
	if (!data) return QImage();
	int height = *(int *)data;
	XFree(data);
	int size = width * height;
	XGetWindowProperty(display, rootWindow, atom, 2, size, 0, AnyPropertyType, &actualType, &format, &numItems,
	                   &bytesAfter, &data);
	if (!data) return QImage();
	QImage icon(width, height, QImage::Format_ARGB32);

	unsigned int *imgData = new unsigned int[size];
	unsigned long *ul = (unsigned long *)data;
	for (int i = 0; i < numItems; ++i) {
		imgData[i] = (unsigned int)ul[i];
	}
	unsigned char *argb = (unsigned char *)imgData;
	// qDebug() << bytesAfter << " / " << numItems << height << "x" << width << " == " << height * width << " : "
	//        << height * width * 4;
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			unsigned char a = argb[3];
			unsigned char r = argb[2] * a / 255;
			unsigned char g = argb[1] * a / 255;
			unsigned char b = argb[0] * a / 255;
			icon.setPixel(x, y, qRgba(r, g, b, a));
			argb += 4;
		}
	}
	XFree(data);
	delete[] imgData;
	return icon;
#else
	Q_UNUSED(window)
	return QImage();
#endif
}

uintptr_t DesktopTools::getDisplayIndex(void *screenSharing) {
	Q_UNUSED(screenSharing)
#ifdef ENABLE_SCREENSHARING
	return *(uintptr_t *)(&screenSharing);
#else
	return 0;
#endif
}

QRect DesktopTools::getWindowGeometry(void *screenSharing) {
	Q_UNUSED(screenSharing)
#ifdef ENABLE_SCREENSHARING
	const char *displayStr = getenv("DISPLAY");
	if (displayStr == NULL) displayStr = ":0";
	Display *display = XOpenDisplay(displayStr);
	if (display == NULL) {
		qCritical() << "Can't open X display!";
		return QRect();
	}
	Window windowId = (Window)screenSharing;
	XWindowAttributes attributes;
	XGetWindowAttributes(display, windowId, &attributes);
	return QRect(attributes.x, attributes.y, attributes.width, attributes.height);
#else
	return QRect();
#endif
}
