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

#include "FocusHelper.hpp"
#include <iostream>

FocusHelperAttached::FocusHelperAttached(QObject *parent) : QObject(parent) {
	if (auto item = qobject_cast<QQuickItem *>(parent)) {
		m_item = item;
		m_item->installEventFilter(this);
	}
}

bool FocusHelperAttached::eventFilter(QObject *watched, QEvent *event) {
	if (watched == m_item) {
		if (event->type() == QEvent::FocusIn) {
			auto fe = static_cast<QFocusEvent *>(event);
			if (fe) {
				int focusReason = fe->reason();
				m_keyboardFocus = (focusReason == Qt::TabFocusReason || focusReason == Qt::BacktabFocusReason);
				m_otherFocus = focusReason == Qt::OtherFocusReason;
				emit keyboardFocusChanged();
				emit otherFocusChanged();
			}
		} else if (event->type() == QEvent::FocusOut) {
			m_keyboardFocus = false;
			m_otherFocus = false;
			emit keyboardFocusChanged();
			emit otherFocusChanged();
		}
	}
	return QObject::eventFilter(watched, event);
}

FocusHelperAttached *FocusHelper::qmlAttachedProperties(QObject *obj) {
	return new FocusHelperAttached(obj);
}
