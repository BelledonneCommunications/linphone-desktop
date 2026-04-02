/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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

#include "SysTrayNotificationBackend.hpp"

#include "core/App.hpp"
#include "core/call/CallGui.hpp"
#include "core/chat/ChatGui.hpp"
#include "core/event-filter/LockEventFilter.hpp"
#include "tool/Utils.hpp"
#include "tool/providers/ImageProvider.hpp"

#include <QDBusReply>
#include <QDebug>
#include <QQuickItem>
#include <QQuickWindow>

static constexpr const char *SERVICE = "org.freedesktop.Notifications";
static constexpr const char *PATH = "/org/freedesktop/Notifications";
static constexpr const char *INTERFACE = "org.freedesktop.Notifications";

NotificationBackend::NotificationBackend(QObject *parent) : AbstractNotificationBackend(parent) {
	mInterface = new QDBusInterface(SERVICE, PATH, INTERFACE, QDBusConnection::sessionBus(), this);

	if (!mInterface->isValid()) {
		qWarning() << "Notification service unavailable:" << mInterface->lastError().message();
		return;
	}

	// Connecte les signaux D-Bus entrants
	QDBusConnection::sessionBus().connect(SERVICE, PATH, INTERFACE, "ActionInvoked", this,
	                                      SLOT(onActionInvoked(uint, QString)));

	QDBusConnection::sessionBus().connect(SERVICE, PATH, INTERFACE, "NotificationClosed", this,
	                                      SLOT(onNotificationClosed(uint, uint)));
}

void NotificationBackend::sendMessageNotification(QVariantMap data) {
}

uint NotificationBackend::sendCallNotification(QVariantMap data) {
	if (!mInterface->isValid()) return 0;

	auto displayName = data["displayName"].toString();
	CallGui *call = data["call"].value<CallGui *>();

	// Corps de la notification
	QString title = tr("incoming_call");

	qDebug() << "isValid:" << mInterface->isValid();
	qDebug() << "lastError:" << mInterface->lastError().message();

	// Hints
	QVariantMap hints;
	hints["urgency"] = QVariant::fromValue(uchar(2)); // critical
	hints["resident"] = true;                         // reste visible jusqu'à action
	hints["x-gnome-priority"] = int(2);               // force banner display
	hints["x-gnome-stack"] = QString("persistent");
	hints["transient"] = false;
	hints["category"] = QString("call.incoming");

	// Actions : paires (clé, label)
	QStringList actions = {"accept", tr("accept_button"), "decline", tr("decline_button")};

	QString appIcon = getIconAsPng(Utils::getAppIcon("logo").toString());
	// QString appIcon = QString("call-start"); // icône freedesktop standard

	QDBusReply<uint> reply = mInterface->call(QString("Notify"),
	                                          APPLICATION_NAME,         // app_name
	                                          uint(mActiveCallNotifId), // replaces_id (0 = nouvelle notif)
	                                          appIcon,                  // app_icon (nom d'icône freedesktop)
	                                          title, displayName, actions, hints,
	                                          int(-1) // expire_timeout (-1 = jamais)
	);

	if (!reply.isValid()) {
		qWarning() << "Notify() failed:" << reply.error().message();
		return 0;
	}

	uint id = reply.value();
	mActiveCallNotifId = id;

	mCurrentNotifications.insert({id}, {AbstractNotificationBackend::NotificationType::ReceivedCall, data});
	connect(call->mCore.get(), &CallCore::stateChanged, this, [this, call, id] {
		if (call->mCore->getState() == LinphoneEnums::CallState::End ||
		    call->mCore->getState() == LinphoneEnums::CallState::Error) {
			qDebug() << "Call ended or error, remove toast";
			auto callId = call->mCore->getCallId();
			call->deleteLater();
			closeNotification(id);
		}
	});
	qDebug() << "Notification d'appel envoyée, id =" << id;

	// qDebug() << "Reply valid:" << reply.isValid();
	// qDebug() << "Reply value:" << reply.value();
	// qDebug() << "Reply error:" << reply.error().name() << reply.error().message();
	// qDebug() << "Interface valid:" << mInterface->isValid();
	// qDebug() << "Interface service:" << mInterface->service();

	return id;
}

void NotificationBackend::closeNotification(uint id) {
	if (!mInterface->isValid()) {
		qWarning() << "invalid interface, return";
		return;
	}
	mInterface->call("CloseNotification", id);
	mCurrentNotifications.remove(id);

	if (mActiveCallNotifId == id) mActiveCallNotifId = 0;
}

void NotificationBackend::onActionInvoked(uint id, const QString &actionKey) {
	if (!mCurrentNotifications.contains(id)) return; // pas notre notification

	qDebug() << "Action invoquée — id:" << id << "key:" << actionKey;
	auto notif = mCurrentNotifications.value(id);
	if (notif.type == AbstractNotificationBackend::NotificationType::ReceivedCall) {
		auto callGui = notif.data["call"].value<CallGui *>();
		if (!callGui) {
			qWarning() << "Could not retrieve call associated to notification, return";
			return;
		}
		if (actionKey == "accept") {
			qDebug() << "Accept call";
			Utils::openCallsWindow(callGui);
			callGui->mCore->lAccept(false);
		} else if (actionKey == "decline") {
			qDebug() << "Decline call";
			callGui->mCore->lDecline();
		}
	} else if (notif.type == AbstractNotificationBackend::NotificationType::ReceivedMessage) {
	}

	qDebug() << "Close notification";
	mCurrentNotifications.remove(id);
	closeNotification(id);
}

void NotificationBackend::onNotificationClosed(uint id, uint reason) {
	// Raisons : 1=expired, 2=dismissed, 3=CloseNotification(), 4=undefined
	if (mCurrentNotifications.contains(id)) {
		qDebug() << "Notification fermée — id:" << id << "raison:" << reason;
		mCurrentNotifications.remove(id);
		if (mActiveCallNotifId == id) mActiveCallNotifId = 0;
		emit notificationClosed(id, reason);

		auto notif = mCurrentNotifications.value(id);
		if (notif.type == AbstractNotificationBackend::NotificationType::ReceivedCall) {
			auto callGui = notif.data["call"].value<CallGui *>();
			if (!callGui) {
				qWarning() << "Could not retrieve call associated to notification, return";
				return;
			}
			callGui->mCore->lDecline();
		}
	}
}

void NotificationBackend::sendNotification(NotificationType type, QVariantMap data) {
	switch (type) {
		case NotificationType::ReceivedCall:
			sendCallNotification(data);
			break;
		case NotificationType::ReceivedMessage:
			sendMessageNotification(data);
			break;
	}
}

// =============================================================================

namespace {
constexpr char ServiceName[] = "org.freedesktop.Notifications";
constexpr char ServicePath[] = "/org/freedesktop/Notifications";
} // namespace

QDBusArgument &operator<<(QDBusArgument &arg, const QImage &image) {
	QImage scaledImage;
	if (!image.isNull()) {
		scaledImage = image.scaled(200, 100, Qt::KeepAspectRatio, Qt::SmoothTransformation);
		if (scaledImage.format() != QImage::Format_ARGB32)
			scaledImage = scaledImage.convertToFormat(QImage::Format_ARGB32);
		scaledImage = scaledImage.rgbSwapped();
	}

	const int channels = 4; // ARGB32 has 4 channels

	arg.beginStructure();
	arg << scaledImage.width();
	arg << scaledImage.height();
	arg << scaledImage.bytesPerLine();
	arg << true; // ARGB32 has alpha
	arg << scaledImage.depth() / channels;
	arg << channels;
	arg << QByteArray::fromRawData((const char *)scaledImage.constBits(),
	                               scaledImage.height() * scaledImage.bytesPerLine());
	arg.endStructure();

	return arg;
}
const QDBusArgument &operator>>(const QDBusArgument &arg, QImage &image) {
	Q_UNUSED(image)
	return arg;
}

// static void openUrl(QFileInfo info) {
// 	bool showDirectory = showDirectory || !info.exists();
// 	if (!QDesktopServices::openUrl(
// 	        QUrl(QStringLiteral("file:///%1").arg(showDirectory ? info.absolutePath() : info.absoluteFilePath()))) &&
// 	    !showDirectory) {
// 		QDesktopServices::openUrl(QUrl(QStringLiteral("file:///%1").arg(info.absolutePath())));
// 	}
// }

// void NotificationsDBus::onNotificationClosed(quint32 id, quint32 reason) {
// 	if (!mProcessed) { // Is was closed from system.
// 		if (reason != 2)
// 			qWarning() << "Notification has been closed by system. If this is an issue, please deactivate native "
// 			              "notifications ["
// 			           << id << reason << "]";
// 		// open();// Not a workaround because of infinite openning loop.
// 	}
// }

// // QDBusMessage
// NotificationsDBus::createMessage(const QString &title, const QString &message, QVariantMap hints, QStringList
// actions) {

// 	QDBusMessage msg = QDBusMessage::createMethodCall("org.freedesktop.Notifications", "/org/freedesktop/Notifications",
// 	                                                  "org.freedesktop.Notifications", "Notify");
// 	hints["urgency"] = 2; // if not 2, it can be timeout without taking account of custom timeout
// 	hints["category"] = "im";
// 	// hints["resident"] = true;
// 	hints["transient"] = true;
// 	// hints["desktop-entry"] = "com.belledonnecommunications.linphone";
// 	hints["suppress-sound"] = true;

// 	msg << APPLICATION_NAME;                         // Application name
// 	msg << quint32(0);                               // ID
// 	msg << "";                                       // Icon to display
// 	msg << APPLICATION_NAME + QString(": ") + title; // Summary / Header of the message to display
// 	msg << message;                                  // Body of the message to display
// 	msg << actions;                                  // Actions from which the user may choose
// 	msg << hints;                                    // Hints to the server displaying the message
// 	msg << qint32(0);                                // Timeout in milliseconds

// 	return msg;
// }

// void NotificationsDBus::open() {
// 	QDBusPendingReply<quint32> asyncReply(QDBusConnection::sessionBus().asyncCall(
// 	    mMessage)); // Would return a message containing the id of this notification
// 	asyncReply.waitForFinished();
// 	if (asyncReply.isValid()) mId = asyncReply.argumentAt(0).toInt();
// 	else qWarning() << asyncReply.error();
// }

// void NotificationsDBus::closeNotification() {
// 	QDBusMessage msg = QDBusMessage::createMethodCall("org.freedesktop.Notifications", "/org/freedesktop/Notifications",
// 	                                                  "org.freedesktop.Notifications", "CloseNotification");
// 	msg << quint32(mId);
// 	QDBusConnection::sessionBus().call(msg);
// }
