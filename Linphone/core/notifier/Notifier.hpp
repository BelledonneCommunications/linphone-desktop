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

#ifndef NOTIFIER_H_
#define NOTIFIER_H_

#include <memory>

#include "core/setting/SettingsCore.hpp"
#include "tool/AbstractObject.hpp"
#include <QHash>
#include <QObject>
#include <linphone++/linphone.hh>
// =============================================================================

class QMutex;
class QQmlComponent;

class Notifier : public QObject, public AbstractObject {
	Q_OBJECT

public:
	Notifier(QObject *parent = Q_NULLPTR);
	~Notifier();

	enum NotificationType {
		ReceivedMessage,
		// ReceivedFileMessage,
		ReceivedCall
		// NewVersionAvailable,
		// SnapshotWasTaken,
		// RecordingCompleted
	};

	// void notifyReceivedCall(Call *call);
	void notifyReceivedCall(const std::shared_ptr<linphone::Call> &call); // Call from Linphone

	void notifyReceivedMessages(const std::shared_ptr<linphone::ChatRoom> &room,
	                            const std::list<std::shared_ptr<linphone::ChatMessage>> &messages);
	/*
	    void notifyReceivedReactions(
	        const QList<QPair<std::shared_ptr<linphone::ChatMessage>, std::shared_ptr<const
	   linphone::ChatMessageReaction>>> &reactions); void notifyReceivedFileMessage(const
	   std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> &content);

	    void notifyNewVersionAvailable(const QString &version, const QString &url);
	    void notifySnapshotWasTaken(const QString &filePath);
	    void notifyRecordingCompleted(const QString &filePath);
	    */

public slots:
	void deleteNotificationOnTimeout(QVariant notification);
	void deleteNotification(QVariant notification);

private:
	struct Notification {
		Notification(const int &type = 0, const QString &filename = QString(""), int timeout = 0) {
			this->type = type;
			this->filename = filename;
			this->timeout = timeout;
		}
		int getTimeout() const {
			if (type == Notifier::ReceivedCall) {
				// return CoreManager::getInstance()->getSettingsModel()->getIncomingCallTimeout();
				return 30;
			} else return timeout;
		}
		QString filename;

	private:
		int timeout;
		int type;
	};

	bool createNotification(NotificationType type, QVariantMap data);
	void showNotification(QObject *notification, int timeout);

	QHash<QString, int> mScreenHeightOffset;
	int mInstancesNumber = 0;

	QMutex *mMutex = nullptr;
	// QQmlComponent **mComponents = nullptr;
	QVector<QQmlComponent *> mComponents;

	static const QHash<int, Notification> Notifications;

	DECLARE_ABSTRACT_OBJECT
};

#endif // NOTIFIER_H_
