#ifndef SYSTRAYNOTIFICATIONBACKEND_HPP
#define SYSTRAYNOTIFICATIONBACKEND_HPP

#include "AbstractNotificationBackend.hpp"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDebug>
#include <QLocalServer>
#include <QLocalSocket>
#include <QObject>
#include <QString>
#include <QVariantMap>

class NotificationBackend : public AbstractNotificationBackend {

	Q_OBJECT
public:
	struct CurrentNotification {
		NotificationType type;
		QVariantMap data;
	};

	NotificationBackend(QObject *parent = nullptr);
	~NotificationBackend() = default;

	uint sendCallNotification(QVariantMap data);
	void closeNotification(uint id);
	void sendMessageNotification(QVariantMap data);

	void sendNotification(NotificationType type, QVariantMap data) override;

signals:
	void toastButtonTriggered(const QString &arg);
	void sessionLockedChanged(bool locked);
	void notificationClosed(uint id, uint reason);

private slots:
	void onActionInvoked(uint id, const QString &actionKey);
	void onNotificationClosed(uint id, uint reason);

private:
	QDBusInterface *mInterface = nullptr;
	uint mActiveCallNotifId = 0;
	QMap<uint, CurrentNotification> mCurrentNotifications; // IDs des notifs d'appel actives
};

#endif // SYSTRAYNOTIFICATIONBACKEND_HPP
