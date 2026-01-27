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

#include "AccessibilityHelper.hpp"
#include "tool/Utils.hpp"
#include <QAccessible>
#include <QAccessibleAnnouncementEvent>
#include <QQuickWindow>

DEFINE_ABSTRACT_OBJECT(AccessibilityHelper)

void AccessibilityHelper::announceMessage(const QString &message, QObject *context, bool assertive) {
	QObject *target = context ? context : static_cast<QObject *>(Utils::getMainWindow());
	if (!target) return;
	QAccessibleAnnouncementEvent event(target, message);
	event.setPoliteness(assertive ? QAccessible::AnnouncementPoliteness::Assertive
	                              : QAccessible::AnnouncementPoliteness::Polite);

	QAccessible::updateAccessibility(&event);
}
