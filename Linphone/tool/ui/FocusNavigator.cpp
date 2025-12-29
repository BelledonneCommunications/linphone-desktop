/*
 * Copyright (c) 2010-2025 Belledonne Communications SARL.
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

#include "FocusNavigator.hpp"

#include <QGuiApplication>
#include <QQuickItem>

FocusNavigator::FocusNavigator(QObject *parent) : QObject(parent) {
	connect(qApp, &QGuiApplication::focusObjectChanged, this, &FocusNavigator::onFocusObjectChanged);
	qApp->installEventFilter(this);
}

bool FocusNavigator::doesLastFocusWasKeyboard() {
	return mLastFocusWasKeyboard;
}

bool FocusNavigator::eventFilter(QObject *, QEvent *event) {
	switch (event->type()) {
		case QEvent::FocusIn: {
			auto fe = static_cast<QFocusEvent *>(event);
			if (fe) {
				int focusReason = fe->reason();
				mLastFocusWasKeyboard = (focusReason == Qt::TabFocusReason || focusReason == Qt::BacktabFocusReason);
			}
			break;
		}
		default:
			break;
	}
	return false;
}

void FocusNavigator::onFocusObjectChanged(QObject *obj) {
	// qDebug() << "New focus object" << obj; // Usefull to debug focus problems
	auto item = qobject_cast<QQuickItem *>(obj);
	if (!item) return;
	emit focusChanged(item, mLastFocusWasKeyboard);
}
