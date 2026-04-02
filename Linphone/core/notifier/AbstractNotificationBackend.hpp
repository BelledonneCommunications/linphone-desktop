#ifndef ABSTRACTNOTIFICATIONBACKEND_HPP
#define ABSTRACTNOTIFICATIONBACKEND_HPP

#include "tool/AbstractObject.hpp"
#include <QHash>
#include <QObject>
#include <QSize>
#include <QString>
struct ToastButton {
	QString label;
	QString argument;
	QString icon;
	ToastButton(QString label, QString arg, QString icon = QString()) {
		this->label = label;
		this->argument = arg;
		this->icon = icon;
	}
};

class AbstractNotificationBackend : public QObject, public AbstractObject {
	Q_OBJECT
public:
	AbstractNotificationBackend(QObject *parent = Q_NULLPTR);
	~AbstractNotificationBackend() = default;

	QString getIconAsPng(const QString &imagePath, const QSize &size = QSize(64, 64));

	enum NotificationType {
		ReceivedMessage,
		ReceivedCall
		// ReceivedFileMessage,
		// SnapshotWasTaken,
		// RecordingCompleted
	};
	struct Notification {
		Notification(int type, int timeout = 0) {
			this->type = NotificationType(type);
			this->timeout = timeout;
		}
		int getTimeout() const {
			return timeout;
		}

	private:
		int type;
		int timeout;
	};

protected:
	virtual void sendNotification(NotificationType type, QVariantMap data) = 0;
	static const QHash<int, Notification> Notifications;

signals:
	void toastActivated(const QString &args);

private:
	DECLARE_ABSTRACT_OBJECT
};

#endif // ABSTRACTNOTIFICATIONBACKEND_HPP
