/*
 * SingleApplicationDBus.cpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
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

#include <signal.h>

#include <QDBusInterface>

#include "config.h"

#include "SingleApplication.hpp"
#include "SingleApplicationDBusPrivate.hpp"

// =============================================================================

namespace {
  constexpr char ServiceName[] = "org." EXECUTABLE_NAME ".SingleApplication";
}

SingleApplicationPrivate::SingleApplicationPrivate (SingleApplication *q_ptr)
  : QDBusAbstractAdaptor(q_ptr), q_ptr(q_ptr) {}

QDBusConnection SingleApplicationPrivate::getBus () const {
  if (options & SingleApplication::Mode::User)
    return QDBusConnection::sessionBus();

  return QDBusConnection::systemBus();
}

void SingleApplicationPrivate::startPrimary () {
  crashHandler();
  if (!getBus().registerObject("/", this, QDBusConnection::ExportAllSlots))
    qWarning() << QStringLiteral("Failed to register single application object on DBus.");
  instanceNumber = 0;
}

void SingleApplicationPrivate::startSecondary () {
  crashHandler();
  instanceNumber = 1;
}

void SingleApplicationPrivate::crashHandler () {
  signal(SIGHUP, SingleApplicationPrivate::terminate);  // 1
  signal(SIGINT, SingleApplicationPrivate::terminate);  // 2
  signal(SIGQUIT, SingleApplicationPrivate::terminate); // 3
  signal(SIGILL, SingleApplicationPrivate::terminate);  // 4
  signal(SIGABRT, SingleApplicationPrivate::terminate); // 6
  signal(SIGFPE, SingleApplicationPrivate::terminate);  // 8
  signal(SIGBUS, SingleApplicationPrivate::terminate);  // 10
  signal(SIGSEGV, SingleApplicationPrivate::terminate); // 11
  signal(SIGSYS, SingleApplicationPrivate::terminate);  // 12
  signal(SIGPIPE, SingleApplicationPrivate::terminate); // 13
  signal(SIGALRM, SingleApplicationPrivate::terminate); // 14
  signal(SIGTERM, SingleApplicationPrivate::terminate); // 15
  signal(SIGXCPU, SingleApplicationPrivate::terminate); // 24
  signal(SIGXFSZ, SingleApplicationPrivate::terminate); // 25
}

void SingleApplicationPrivate::terminate (int signum) {
  if (signum == SIGINT)
    SingleApplication::instance()->quit();
  else
    ::exit(128 + signum);
}

SingleApplication::SingleApplication (int &argc, char *argv[], bool allowSecondary, Options options, int)
  : QApplication(argc, argv), d_ptr(new SingleApplicationPrivate(this)) {
  Q_D(SingleApplication);

  // Store the current mode of the program.
  d->options = options;

  if (!d->getBus().isConnected()) {
    qWarning() << QStringLiteral("Cannot connect to the D-Bus session bus.");
    delete d;
    ::exit(EXIT_FAILURE);
  }

  if (d->getBus().registerService(ServiceName)) {
    d->startPrimary();
    return;
  }

  if (allowSecondary) {
    d->startSecondary();
    return;
  }

  delete d;
  ::exit(EXIT_SUCCESS);
}

SingleApplication::~SingleApplication () {
  Q_D(SingleApplication);
  delete d;
}

bool SingleApplication::isPrimary () {
  Q_D(SingleApplication);
  return d->instanceNumber == 0;
}

bool SingleApplication::isSecondary () {
  Q_D(SingleApplication);
  return d->instanceNumber != 0;
}

quint32 SingleApplication::instanceId () {
  Q_D(SingleApplication);
  return d->instanceNumber;
}

bool SingleApplication::sendMessage (QByteArray message, int timeout) {
  Q_D(SingleApplication);

  if (isPrimary()) return false;

  QDBusInterface iface(ServiceName, "/", "", d->getBus());
  if (iface.isValid()) {
    iface.setTimeout(timeout);
    iface.call(QDBus::Block, "handleMessageReceived", instanceId(), message);
    return true;
  }

  return false;
}

void SingleApplicationPrivate::handleMessageReceived (quint32 instanceId, QByteArray message) {
  Q_Q(SingleApplication);
  emit q->receivedMessage(instanceId, message);
}

void SingleApplication::quit () {
  QCoreApplication::quit();
}
