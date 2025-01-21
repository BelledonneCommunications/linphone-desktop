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

#ifndef SINGLE_APPLICATION_DBUS_PRIVATE_H_
#define SINGLE_APPLICATION_DBUS_PRIVATE_H_

#include <QDBusAbstractAdaptor>
#include <QDBusConnection>

#include "singleapplication.h"

// =============================================================================

struct InstancesInfo {
	bool primary;
	quint32 secondary;
};

class SingleApplicationPrivate : public QDBusAbstractAdaptor {
	Q_OBJECT
	Q_CLASSINFO("D-Bus Interface", "org.linphone.DBus.SingleApplication")

public:
	SingleApplicationPrivate(SingleApplication *q_ptr);

	QDBusConnection getBus() const;

	void startPrimary();
	void startSecondary();

	static void terminate(int signum);

	SingleApplication *q_ptr;
	SingleApplication::Options options;
	quint32 instanceNumber;

	// Explicit public slot. Cannot be private, must be exported as a method via D-Bus.
public slots:
	void handleMessageReceived(quint32 instanceId, QByteArray message);
	void kill();

private:
	Q_DECLARE_PUBLIC(SingleApplication)
};

#endif // SINGLE_APPLICATION_DBUS_PRIVATE_H_
