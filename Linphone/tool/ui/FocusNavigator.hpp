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

#pragma once

#include <QObject>
#include <QQuickItem>

class FocusNavigator : public QObject {
	Q_OBJECT

public:
	explicit FocusNavigator(QObject *parent = nullptr);
	Q_INVOKABLE bool doesLastFocusWasKeyboard();

protected:
	bool eventFilter(QObject *obj, QEvent *event) override;

signals:
	void focusChanged(QQuickItem *item, bool keyboardFocus);

private:
	bool mLastFocusWasKeyboard = false;
	void onFocusObjectChanged(QObject *obj);
};
