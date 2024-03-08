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
#include "components/core/CoreManager.hpp"
#include "components/videoSource/VideoSourceDescriptorModel.hpp"
#include "config.h"

#include <QDebug>
#include <QRect>
#include <QThread>
#include <X11/Xlib.h>
#include <fcntl.h>
#include <unistd.h>
// #include <X11/Xutil.h>

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

#ifdef ENABLE_SCREENSHARING
class T : public QThread {
public:
	Display *mDisplay;
	Window mWindow;
	VideoSourceDescriptorModel *mVideoSourceDescriptorModel = nullptr;
	DesktopTools *mParent;
	T() {
	}
	virtual void run() {
		bool endLoop = false;
		unsigned char data[3];
		const char *pDevice = "/dev/input/event6";
		int fd = open(pDevice, O_RDONLY), bytes;
		XEvent event;
		endLoop = (fd == -1);
		int left, middle, right;
		XEvent report;
		XButtonEvent *xb = (XButtonEvent *)&report;

		auto cursor = XCreateFontCursor(mDisplay, XC_crosshair);
		auto i = XGrabPointer(mDisplay, mWindow, False, ButtonReleaseMask | ButtonPressMask | Button1MotionMask,
		                      GrabModeSync, GrabModeAsync, mWindow, cursor, CurrentTime);

		endLoop = (i != GrabSuccess);
		if (endLoop) qCritical() << "Cannot open mouse events";
		while (!endLoop) {
			XAllowEvents(mDisplay, SyncPointer, CurrentTime);
			XWindowEvent(mDisplay, mWindow, ButtonPressMask | ButtonReleaseMask, &report);
			if (report.type == ButtonPress) {
				printf("Press @ (%d, %d)\n", xb->x_root, xb->y_root);
				XQueryPointer(mDisplay, mWindow, &event.xbutton.root, &event.xbutton.subwindow, &event.xbutton.x_root,
				              &event.xbutton.y_root, &event.xbutton.x, &event.xbutton.y, &event.xbutton.state);
				auto id = event.xbutton.subwindow;
				QMetaObject::invokeMethod(CoreManager::getInstance(), [id, this]() mutable {
					mVideoSourceDescriptorModel->setScreenSharingWindow(reinterpret_cast<void *>(id));
				});
				endLoop = true;
			}
		}
		XFlush(mDisplay);
		XUngrabServer(mDisplay);
		XCloseDisplay(mDisplay);
		deleteLater();
	}
};
#endif
void DesktopTools::getWindowIdFromMouse(VideoSourceDescriptorModel *model) {
	Q_UNUSED(model)
#ifdef ENABLE_SCREENSHARING
	const char *displayStr = getenv("DISPLAY");
	if (displayStr == NULL) displayStr = ":0";
	Display *display = XOpenDisplay(displayStr); // QX11Info::display();
	if (display == NULL) {
		qCritical() << "Can't open X display!";
		return;
	}
	emit windowIdSelectionStarted();
	T *t = new T();
	connect(t, &QThread::finished, this, &DesktopTools::windowIdSelectionEnded);
	t->mVideoSourceDescriptorModel = model;
	t->mDisplay = display;
	auto screen = DefaultScreen(display);     // QX11Info::appScreen();
	t->mWindow = RootWindow(display, screen); // QX11Info::appRootWindow(m_x11_screen);
	t->mParent = this;
	t->start();
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
