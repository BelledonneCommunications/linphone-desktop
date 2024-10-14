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

#include "FPSCounter.hpp"

#include <QBrush>
#include <QDateTime>
#include <QPainter>

#include "tool/Utils.hpp"

FPSCounter::FPSCounter(QQuickItem *parent) : QQuickPaintedItem(parent), _currentFPS(0), _cacheCount(0) {
	_times.clear();
	setFlag(QQuickItem::ItemHasContents);
}

FPSCounter::~FPSCounter() {
}

void FPSCounter::recalculateFPS() {
	qint64 currentTime = QDateTime::currentDateTime().toMSecsSinceEpoch();
	_times.push_back(currentTime);

	while (_times[0] < currentTime - 1000) {
		_times.pop_front();
	}

	int currentCount = _times.length();
	_currentFPS = (currentCount + _cacheCount) / 2;
	// lDebug() << _currentFPS;

	if (currentCount != _cacheCount) fpsChanged(_currentFPS);

	_cacheCount = currentCount;
}

int FPSCounter::fps() const {
	return _currentFPS;
}

void FPSCounter::paint(QPainter *painter) {
	recalculateFPS();
	// lDebug()<< __FUNCTION__;
	/*
	QBrush brush(Qt::yellow);

	painter->setBrush(brush);
	painter->setPen(Qt::NoPen);
	painter->setRenderHint(QPainter::Antialiasing);
	painter->drawRoundedRect(0, 0, boundingRect().width(), boundingRect().height(), 0, 0);
*/
	update();
}
