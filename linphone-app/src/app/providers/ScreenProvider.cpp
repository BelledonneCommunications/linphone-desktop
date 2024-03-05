/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#include "ScreenProvider.hpp"
#include <QGuiApplication>
#include <QScreen>
#include <QThread>
#include <QWindow>
#include "components/other/desktop-tools/DesktopTools.hpp"

// =============================================================================

const QString ScreenProvider::ProviderId = "screen";

ScreenProvider::ScreenProvider () : QQuickImageProvider(
	QQmlImageProviderBase::Image,
	QQmlImageProviderBase::ForceAsynchronousImageLoading
) {}

QImage ScreenProvider::requestImage (const QString &id, QSize *size, const QSize &requestedSize) {
	if(!requestedSize.isNull()) {
		int index = id.toInt();
		auto screens = QGuiApplication::screens();
		if(index >= 0 && index < screens.size()){
			auto screen = screens[index];
			auto geometry = screen->geometry();
	#if __APPLE__
			auto image = screen->grabWindow(0, geometry.x(), geometry.y() ,geometry.width(), geometry.height()).scaled(requestedSize, Qt::KeepAspectRatio,Qt::SmoothTransformation);
	#else
			auto image = screen->grabWindow(0, 0, 0,geometry.width(), geometry.height()).scaled(requestedSize, Qt::KeepAspectRatio,Qt::SmoothTransformation);
	#endif
			*size = image.size();
			qDebug() << "Screen(" << index << ") = " << screen->geometry() << " VG:" <<  screen->virtualGeometry() << " / " << screen->size() << " VS:" << screen->virtualSize() << " DeviceRatio: " << screen->devicePixelRatio();
			return image.toImage();
		}
	}
	QImage image(10,10, QImage::Format_Indexed8);
	image.fill(Qt::gray);
	*size = image.size();
	return image;
}

// =============================================================================

const QString WindowProvider::ProviderId = "window";

WindowProvider::WindowProvider () : QQuickImageProvider(
	QQmlImageProviderBase::Image,
	QQmlImageProviderBase::ForceAsynchronousImageLoading
) {}

// Note: Using WId don't work with Window/Mac (For Mac, NSView cannot be used while we are working with CGWindowID)
// Linux seems to be ok but we want to use the same code.
QImage WindowProvider::requestImage (const QString &id, QSize *size, const QSize &requestedSize) {
	if(!requestedSize.isNull()) {
		auto winId = id.toLongLong();
		if(winId > 0){
			QRect area = DesktopTools::getWindowGeometry(reinterpret_cast<void*>(winId));
			if(!area.isNull()) {
				qDebug() << "Window (" << winId << ") = " << area;
				auto screens = QGuiApplication::screens();
				for(auto screen : screens){
					auto geometry = screen->geometry();
					auto devicePixelRatio = screen->devicePixelRatio();
	// Warning: there are inconsistencies in geomtries from OS.
	#if defined(__APPLE__)
					devicePixelRatio = 1.0;// Doesn't apply device ratio.
					// Change area to be absolute
					area.setRect(area.x() + geometry.x(), area.y() + geometry.y(), area.width(), area.height());
	#endif
					geometry.setWidth(geometry.width() * devicePixelRatio);
					geometry.setHeight(geometry.height() * devicePixelRatio);
					if( geometry.contains(area.center())){
						QThread::msleep(40);// Let OS some time to display properly the Window after a click.
						qDebug() << "Grab (" << (area.x() - geometry.x())/devicePixelRatio<< ", " << (area.y() - geometry.y())/devicePixelRatio << ", " << area.width()/devicePixelRatio << ", " << area.height()/devicePixelRatio << ")";
						auto image = screen->grabWindow(0, (area.x() - geometry.x())/devicePixelRatio, (area.y() - geometry.y())/devicePixelRatio, area.width()/devicePixelRatio, area.height()/devicePixelRatio).scaled(requestedSize, Qt::KeepAspectRatio,Qt::SmoothTransformation);
						*size = image.size();
						return image.toImage();
					}
				}
				
			}
		}
	}
	QImage image(10,10, QImage::Format_Indexed8);
	image.fill(Qt::gray);
	*size = image.size();
	return image;
}
