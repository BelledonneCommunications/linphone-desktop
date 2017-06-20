/*
 * SingleApplicationDBusPrivate.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: June 20, 2017
 *      Author: Ghislain MARY
 */

#ifndef SINGLE_APPLICATION_DBUS_PRIVATE_H_
#define SINGLE_APPLICATION_DBUS_PRIVATE_H_

#include <QtDBus/QtDBus>

#include "SingleApplication.hpp"

// =============================================================================

struct InstancesInfo {
  bool primary;
  quint32 secondary;
};

class SingleApplicationPrivate : public QDBusAbstractAdaptor {
  Q_OBJECT
  Q_CLASSINFO("D-Bus Interface", "org.linphone.DBus.SingleApplication")

public:
  Q_DECLARE_PUBLIC(SingleApplication) SingleApplicationPrivate (SingleApplication *q_ptr);
  ~SingleApplicationPrivate () = default;

  QDBusConnection getBus () const;

  void startPrimary ();
  void startSecondary ();

  SingleApplication *q_ptr;
  SingleApplication::Options options;
  quint32 instanceNumber;

public Q_SLOTS:
  void messageReceived (quint32 instanceId, QByteArray message);
};

#endif // SINGLE_APPLICATION_DBUS_PRIVATE_H_
