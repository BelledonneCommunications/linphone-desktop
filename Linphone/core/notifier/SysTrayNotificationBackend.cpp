#include "tool/Utils.hpp"

// #include "NotificationActivator.hpp"
#include "WindowsNotificationBackend.hpp"
#include "core/App.hpp"
#include "core/call/CallGui.hpp"
#include "core/chat/ChatGui.hpp"
#include "core/event-filter/LockEventFilter.hpp"
#include "tool/Utils.hpp"
#include <QDebug>

NotificationBackend::NotificationBackend(QObject *parent) : AbstractNotificationBackend(parent) {
	// connect(App::getInstance(), &App::sessionLockedChanged, this, [this] {
	// 	if (!App::getInstance()->getSessionLocked()) {
	// 		qDebug() << "Session unlocked, flush pending notifications";
	// 		flushPendingNotifications();
	// 	}
	// });
}

void NotificationBackend::flushPendingNotifications() {
	for (const auto &notif : mPendingNotifications) {
		sendNotification(notif.type, notif.data);
	}
	mPendingNotifications.clear();
}

void NotificationBackend::sendMessageNotification(QVariantMap data) {
}

void NotificationBackend::sendCallNotification(QVariantMap data) {
}

void NotificationBackend::sendNotification(NotificationType type, QVariantMap data) {
	// if (App::getInstance()->getSessionLocked()) {
	// 	mPendingNotifications.append({type, data});
	// 	return;
	// }
	switch (type) {
		case NotificationType::ReceivedCall:
			sendCallNotification(data);
			break;
		case NotificationType::ReceivedMessage:
			sendMessageNotification(data);
			break;
	}
}
