#ifndef SYSTRAYNOTIFICATIONBACKEND_HPP
#define SYSTRAYNOTIFICATIONBACKEND_HPP

#include "AbstractNotificationBackend.hpp"
#include <QDebug>
#include <QLocalServer>
#include <QLocalSocket>
#include <QString>

class NotificationBackend : public AbstractNotificationBackend {

	Q_OBJECT
public:
	struct PendingNotification {
		NotificationType type;
		QVariantMap data;
	};

	NotificationBackend(QObject *parent = nullptr);
	~NotificationBackend() = default;

	void sendCallNotification(QVariantMap data);
	void sendMessageNotification(QVariantMap data);

	void sendNotification(NotificationType type, QVariantMap data) override;

	void flushPendingNotifications();

signals:
	void toastButtonTriggered(const QString &arg);
	void sessionLockedChanged(bool locked);

private:
	QList<PendingNotification> mPendingNotifications;
};

#endif // SYSTRAYNOTIFICATIONBACKEND_HPP
