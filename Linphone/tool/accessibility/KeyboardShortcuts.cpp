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

#include "KeyboardShortcuts.hpp"
#include "core/App.hpp"
#include "core/call/CallList.hpp"
#include "tool/Utils.hpp"
#include <QGuiApplication>
#include <QKeySequence>
#include <QQuickItem>
#include <linphone++/linphone.hh>

DEFINE_ABSTRACT_OBJECT(KeyboardShortcuts)

std::shared_ptr<KeyboardShortcuts> KeyboardShortcuts::gKeyboardShortcuts;

KeyboardShortcuts::KeyboardShortcuts(QQuickWindow *window) {
	mustBeInMainThread(getClassName());

	mWindow = window;

	// Define shortcuts
	mAcceptCallShortcut = new QShortcut(QKeySequence(Qt::CTRL | Qt::SHIFT | Qt::Key_A), mWindow);
	mDeclineCallShortcut = new QShortcut(QKeySequence(Qt::CTRL | Qt::SHIFT | Qt::Key_D), mWindow);
	mNextWindowShortcut = new QShortcut(QKeySequence(Qt::Key_F6), mWindow);
	mPreviousWindowShortcut = new QShortcut(QKeySequence(Qt::SHIFT | Qt::Key_F6), mWindow);

	// Make some shortcut active for the whole app
	mAcceptCallShortcut->setContext(Qt::ApplicationShortcut);
	mDeclineCallShortcut->setContext(Qt::ApplicationShortcut);
	mNextWindowShortcut->setContext(Qt::ApplicationShortcut);
	mPreviousWindowShortcut->setContext(Qt::ApplicationShortcut);

	// Link shortcuts to action
	QObject::connect(mAcceptCallShortcut, &QShortcut::activated, this, &KeyboardShortcuts::onAcceptCallShortcut);
	QObject::connect(mDeclineCallShortcut, &QShortcut::activated, this, &KeyboardShortcuts::onDeclineCallShortcut);
	QObject::connect(mNextWindowShortcut, &QShortcut::activated, this, [] { focusSiblingWindow(1); });
	QObject::connect(mPreviousWindowShortcut, &QShortcut::activated, this, [] { focusSiblingWindow(-1); });
}

KeyboardShortcuts::~KeyboardShortcuts() {
}

std::shared_ptr<KeyboardShortcuts> KeyboardShortcuts::create(QQuickWindow *window) {
	if (gKeyboardShortcuts) return gKeyboardShortcuts;
	auto model = std::make_shared<KeyboardShortcuts>(window);
	gKeyboardShortcuts = model;
	return model;
}

std::shared_ptr<KeyboardShortcuts> KeyboardShortcuts::getInstance() {
	return gKeyboardShortcuts;
}

// -----------------------------------------------------------------------------
//		Actions callable with the shortcuts
// -----------------------------------------------------------------------------

void KeyboardShortcuts::onAcceptCallShortcut() {
	// Retrieve the first pending call of the call list
	auto callList = App::getInstance()->getCallList();
	auto currentPendingCall = callList->getFirstIncommingPendingCall();
	if (!currentPendingCall.isNull()) {
		lInfo() << "Accept call with shortcut :" << currentPendingCall;
		auto gui = new CallGui(currentPendingCall);
		Utils::openCallsWindow(gui);
		currentPendingCall->lAccept(false);
	}
}

void KeyboardShortcuts::onDeclineCallShortcut() {
	// Retrieve the first pending call of the call list
	auto callList = App::getInstance()->getCallList();
	auto currentPendingCall = callList->getFirstIncommingPendingCall();
	if (!currentPendingCall.isNull()) {
		lInfo() << "Decline call with shortcut :" << currentPendingCall;
		currentPendingCall->lDecline();
	}
}

void KeyboardShortcuts::focusSiblingWindow(int step) {
	auto app = App::getInstance();
	QList<QQuickWindow *> windows;
	auto addWindow = [&windows](QQuickWindow *window) {
		if (window && window->isVisible() && !windows.contains(window)) windows.append(window);
	};
	addWindow(app->getMainWindow());
	for (auto window : QGuiApplication::topLevelWindows()) {
		auto quickWindow = qobject_cast<QQuickWindow *>(window);
		if (!quickWindow || (quickWindow->type() != Qt::Window && quickWindow->type() != Qt::Dialog) ||
		    quickWindow->flags().testFlag(Qt::WindowDoesNotAcceptFocus))
			continue;
		addWindow(quickWindow);
	}
	if (windows.size() < 2) return;
	auto current = qobject_cast<QQuickWindow *>(QGuiApplication::focusWindow());
	if (!windows.contains(current)) current = app->getLastActiveWindow();
	auto index = windows.indexOf(current);
	if (index < 0) index = 0;
	auto target = windows.at((index + step + windows.size()) % windows.size());
	Utils::smartShowWindow(target);
	auto focused = target->activeFocusItem();
	if (!focused || focused == target->contentItem()) {
		auto first = target->contentItem()->nextItemInFocusChain(true);
		if (first) first->forceActiveFocus(Qt::TabFocusReason);
	}
}
