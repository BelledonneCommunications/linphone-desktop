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

#include <QFocusEvent>
#include <QObject>
#include <QPointer>
#include <QQuickItem>

class FocusHelperAttached : public QObject {
	Q_OBJECT
	Q_PROPERTY(bool keyboardFocus READ keyboardFocus NOTIFY keyboardFocusChanged)
	Q_PROPERTY(bool otherFocus READ otherFocus NOTIFY otherFocusChanged)

public:
	explicit FocusHelperAttached(QObject *parent = nullptr);

	bool keyboardFocus() const {
		return m_keyboardFocus;
	}
	bool otherFocus() const {
		return m_otherFocus;
	}

signals:
	void keyboardFocusChanged();
	void otherFocusChanged();

protected:
	bool eventFilter(QObject *watched, QEvent *event) override;

private:
	QPointer<QQuickItem> m_item;
	bool m_keyboardFocus = false;
	bool m_otherFocus = false;

	friend class FocusHelper;
};

class FocusHelper : public QObject {
	Q_OBJECT
public:
	using QObject::QObject;

	static FocusHelperAttached *qmlAttachedProperties(QObject *obj);
};

QML_DECLARE_TYPEINFO(FocusHelper, QML_HAS_ATTACHED_PROPERTIES)
