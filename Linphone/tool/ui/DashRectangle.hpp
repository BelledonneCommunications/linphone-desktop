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

#ifndef DASHRECTANGLE_H
#define DASHRECTANGLE_H

#include <QObject>
#include <QPainter>
#include <QQuickPaintedItem>

class DashRectangle : public QQuickPaintedItem {
	Q_OBJECT
	Q_PROPERTY(float radius READ getRadius WRITE setRadius NOTIFY radiusChanged)
	Q_PROPERTY(QColor color READ getColor WRITE setColor NOTIFY colorChanged)
public:
	explicit DashRectangle(QQuickItem *parent = nullptr);

	virtual void paint(QPainter *painter);

	float getRadius() const;
	void setRadius(float radius);

	QColor getColor() const;
	void setColor(QColor color);

signals:
	void radiusChanged();
	void colorChanged();

private:
	float mRadius = 0;
	QColor mColor;
};

#endif // DASHRECTANGLE_H
