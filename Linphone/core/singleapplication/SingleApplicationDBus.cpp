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

#include <signal.h>

#include <QDBusInterface>

#include "config.h"

#include "SingleApplicationDBusPrivate.hpp"
#include "singleapplication.h"

// =============================================================================

namespace {
constexpr char ServiceName[] = "org." EXECUTABLE_NAME ".SingleApplication";
}

SingleApplicationPrivate::SingleApplicationPrivate(SingleApplication *q_ptr)
    : QDBusAbstractAdaptor(q_ptr), q_ptr(q_ptr) {
}

QDBusConnection SingleApplicationPrivate::getBus() const {
	if (options & SingleApplication::Mode::User) return QDBusConnection::sessionBus();

	return QDBusConnection::systemBus();
}

void SingleApplicationPrivate::startPrimary() {
	signal(SIGINT, SingleApplicationPrivate::terminate);
	if (!getBus().registerObject("/", this, QDBusConnection::ExportAllSlots))
		qWarning() << QStringLiteral("Failed to register single application object on DBus.");
	instanceNumber = 0;
}

void SingleApplicationPrivate::startSecondary() {
	signal(SIGINT, SingleApplicationPrivate::terminate);
	instanceNumber = 1;
}

void SingleApplicationPrivate::terminate(int signum) {
	SingleApplication::instance()->exit(signum);
}

SingleApplication::SingleApplication(
    int &argc, char *argv[], bool allowSecondary, Options options, int, const QString &userData)
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

SingleApplication::~SingleApplication() {
	Q_D(SingleApplication);
	delete d;
}

bool SingleApplication::isPrimary() const {
	auto d = d_func();
	return d->instanceNumber == 0;
}

bool SingleApplication::isSecondary() const {
	auto d = d_func();
	return d->instanceNumber != 0;
}

quint32 SingleApplication::instanceId() const {
	auto d = d_func();
	return d->instanceNumber;
}

bool SingleApplication::sendMessage(const QByteArray &message, int timeout, SendMode sendMode) {
	auto d = d_func();

	if (isPrimary()) return false;

	QDBusInterface iface(ServiceName, "/", "", d->getBus());
	if (iface.isValid()) {
		iface.setTimeout(timeout);
		iface.call(QDBus::Block, "handleMessageReceived", instanceId(), message);
		return true;
	}

	return false;
}

void SingleApplicationPrivate::handleMessageReceived(quint32 instanceId, QByteArray message) {
	Q_Q(SingleApplication);
	emit q->receivedMessage(instanceId, message);
}

void SingleApplicationPrivate::kill() {
	terminate(0);
}
