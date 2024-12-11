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

#ifndef DESKTOP_TOOLS_MAC_OS_H_
#define DESKTOP_TOOLS_MAC_OS_H_

#include <QImage>
#include <QList>
#include <QObject>
#include <QVariantList>
// =============================================================================
class VideoSourceDescriptorModel;

class DesktopTools : public QObject {
	Q_OBJECT;

	Q_PROPERTY(
	    bool screenSaverStatus READ getScreenSaverStatus WRITE setScreenSaverStatus NOTIFY screenSaverStatusChanged);

public:
	DesktopTools(QObject *parent = Q_NULLPTR);
	~DesktopTools();

	bool getScreenSaverStatus() const;
	void setScreenSaverStatus(bool status);

	static void init(); // Do first initialization
	static void applicationStateChanged(Qt::ApplicationState currentState);

	// Not used yet because AVSession request automatically permissions when trying to record something.
	static void requestPermissions();

	static QList<QVariantMap> getWindows();
	static QImage takeScreenshot(void *window);
	static QImage getWindowIcon(void *window);

	static void *getDisplay(int screenIndex);
	static int getDisplayIndex(void *screenSharing);
	static QRect getWindowGeometry(void *screenSharing);

signals:
	void screenSaverStatusChanged(bool status);

private:
	bool mScreenSaverStatus = true;
};

#endif // DESKTOP_TOOLS_MAC_OS_H_
