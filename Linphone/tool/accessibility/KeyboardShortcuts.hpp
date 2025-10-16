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

#include "tool/AbstractObject.hpp"
#include <QObject>
#include <QQuickWindow>
#include <QSharedPointer>
#include <QShortcut>
#include <linphone++/linphone.hh>

#ifndef KEYBOARD_SHORTCUTS_H_
#define KEYBOARD_SHORTCUTS_H_

class KeyboardShortcuts : public QObject, public AbstractObject {
	Q_OBJECT

public:
	KeyboardShortcuts(QQuickWindow *window);
	~KeyboardShortcuts();
	static std::shared_ptr<KeyboardShortcuts> create(QQuickWindow *window);
	static std::shared_ptr<KeyboardShortcuts> getInstance();

private:
	static std::shared_ptr<KeyboardShortcuts> gKeyboardShortcuts;

	// Window where to put the shortcuts
	QQuickWindow *mWindow = nullptr;

	// The shortcuts
	QShortcut *mAcceptCallShortcut;
	QShortcut *mDeclineCallShortcut;

	// Actions callable with the shortcuts
	static void onAcceptCallShortcut();
	static void onDeclineCallShortcut();

	DECLARE_ABSTRACT_OBJECT
};

#endif // KEYBOARD_SHORTCUTS_H_