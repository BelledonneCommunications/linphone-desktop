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
#include "tool/native/DesktopTools.hpp"
#include <QGuiApplication>
#include <QScreen>
#include <QThread>
#include <QWindow>

// =============================================================================

const QString ScreenProvider::ProviderId = "screen";

ScreenProvider::ScreenProvider()
    : QQuickImageProvider(QQmlImageProviderBase::Image, QQmlImageProviderBase::ForceAsynchronousImageLoading) {
}

QImage ScreenProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize) {
	if (!requestedSize.isNull()) {
		int index = id.toInt();
		auto screens = QGuiApplication::screens();
		if (index >= 0 && index < screens.size()) {
			auto screen = screens[index];
			auto geometry = screen->geometry();
#if __APPLE__
			auto image = screen->grabWindow(0, geometry.x(), geometry.y(), geometry.width(), geometry.height());
#else
			auto image = screen->grabWindow(0, 0, 0, geometry.width(), geometry.height());
#endif
			if (requestedSize.isValid() && requestedSize.height() > 0 && requestedSize.width() > 0 && !image.isNull()) {
				image = image.scaled(requestedSize, Qt::KeepAspectRatio,
				                     Qt::FastTransformation); // Qt::SmoothTransformation);
			}
			*size = image.size();
			qDebug() << "Screen(" << index << ") = " << screen->geometry() << " VG:" << screen->virtualGeometry()
			         << " / " << screen->size() << " VS:" << screen->virtualSize()
			         << " DeviceRatio: " << screen->devicePixelRatio() << ", " << *size << " / " << requestedSize;
			return image.toImage();
		}
	}
	QImage image(10, 10, QImage::Format_Indexed8);
	image.fill(Qt::gray);
	*size = image.size();
	return image;
}

// =============================================================================

const QString WindowProvider::ProviderId = "window";

WindowProvider::WindowProvider()
    : QQuickImageProvider(QQmlImageProviderBase::Image, QQmlImageProviderBase::ForceAsynchronousImageLoading) {
}

// Note: Using WId don't work with Window/Mac (For Mac, NSView cannot be used while we are working with CGWindowID)
// Also WId only work for the current application.
QImage WindowProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize) {
	if (!requestedSize.isNull()) {
		auto winId = id.toLongLong();
		if (winId > 0) {
			auto image = DesktopTools::takeScreenshot((void *)winId);
			if (requestedSize.isValid() && !image.isNull())
				image = image.scaled(requestedSize, Qt::KeepAspectRatio,
				                     Qt::FastTransformation); // Qt::SmoothTransformation);
			*size = image.size();
			return image;
		}
	}
	QImage image(10, 10, QImage::Format_Indexed8);
	image.fill(Qt::gray);
	*size = image.size();
	return image;
}

// =============================================================================

const QString WindowIconProvider::ProviderId = "window_icon";

WindowIconProvider::WindowIconProvider()
    : QQuickImageProvider(QQmlImageProviderBase::Image, QQmlImageProviderBase::ForceAsynchronousImageLoading) {
}

// Note: Using WId don't work with Window/Mac (For Mac, NSView cannot be used while we are working with CGWindowID)
// Also WId only work for the current application.
QImage WindowIconProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize) {
	if (!requestedSize.isNull()) {
		auto winId = id.toLongLong();
		if (winId > 0) {
			auto image = DesktopTools::getWindowIcon((void *)winId);
			if (requestedSize.isValid() && !image.isNull())
				image = image.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
			*size = image.size();
			return image;
		}
	}
	QImage image(10, 10, QImage::Format_Indexed8);
	image.fill(Qt::gray);
	*size = image.size();
	return image;
}
