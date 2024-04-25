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

#ifndef DESKTOP_TOOLS_WINDOWS_H_
#define DESKTOP_TOOLS_WINDOWS_H_

#include <QImage>
#include <QObject>
#include <QVariantMap>
#include <windows.h>

class VideoSourceDescriptorModel;
// =============================================================================

class DesktopTools : public QObject {
	Q_OBJECT

	Q_PROPERTY(
	    bool screenSaverStatus READ getScreenSaverStatus WRITE setScreenSaverStatus NOTIFY screenSaverStatusChanged)

public:
	DesktopTools(QObject *parent = Q_NULLPTR);
	~DesktopTools();

	bool getScreenSaverStatus() const;
	void setScreenSaverStatus(bool status);

	static void init() {
	}
	static void applicationStateChanged(Qt::ApplicationState){};

	static QList<QVariantMap> getWindows();
	static QImage takeScreenshot(void *window);
	static QImage getWindowIcon(void *window);

	static void *getDisplay(uintptr_t screenIndex) {
		return reinterpret_cast<void *>(screenIndex);
	}
	static uintptr_t getDisplayIndex(void *screenSharing);
	static QRect getWindowGeometry(void *screenSharing);
	HWND mWindowId = 0; // Window
	VideoSourceDescriptorModel *mVideoSourceDescriptorModel = nullptr;

signals:
	void screenSaverStatusChanged(bool status);
	void windowIdSelectionStarted();
	void windowIdSelectionEnded();

private:
	bool mScreenSaverStatus = true;
};

#endif // DESKTOP_TOOLS_WINDOWS_H_
