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

#include "DashRectangle.hpp"
#include "core/App.hpp"

DashRectangle::DashRectangle(QQuickItem *parent) : QQuickPaintedItem(parent) {
	connect(this, &DashRectangle::radiusChanged, this, [this] { update(); });
	connect(this, &DashRectangle::colorChanged, this, [this] { update(); });
}

void DashRectangle::paint(QPainter *painter) {
	QPen pen(Qt::DotLine);
	pen.setColor(mColor);
	pen.setWidthF(4 * App::getInstance()->getScreenRatio());
	painter->setPen(pen);
	painter->drawRoundedRect(x(), y(), width(), height(), mRadius, mRadius);
}

float DashRectangle::getRadius() const {
	return mRadius;
}

void DashRectangle::setRadius(float radius) {
	if (mRadius != radius) {
		mRadius = radius;
		emit radiusChanged();
	}
}

QColor DashRectangle::getColor() const {
	return mColor;
}

void DashRectangle::setColor(QColor Color) {
	if (mColor != Color) {
		mColor = Color;
		emit colorChanged();
	}
}