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

// =============================================================================

const QString ScreenProvider::ProviderId = "screen";

ScreenProvider::ScreenProvider () : QQuickImageProvider(
	QQmlImageProviderBase::Image,
	QQmlImageProviderBase::ForceAsynchronousImageLoading
) {}

QImage ScreenProvider::requestImage (const QString &id, QSize *size, const QSize &) {
	int index = id.toInt();
	auto screens = QGuiApplication::screens();
	if(index >= 0 && index < screens.size()){
		auto image = screens[index]->grabWindow(0);
		*size = image.size();
		return image.toImage();
	}else
		return QImage();
}
