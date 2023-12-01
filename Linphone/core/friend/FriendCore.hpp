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

#ifndef FRIEND_CORE_H_
#define FRIEND_CORE_H_

#include "model/friend/FriendModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeSharedPointer.hpp"
#include <QDateTime>
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class SafeConnection;

// This object is defferent from usual Core. It set internal data from directly from GUI.
// Values are saved on request.
// This allow revert feature.

class FriendCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
	Q_PROPERTY(QString address READ getAddress WRITE setAddress NOTIFY addressChanged)
	Q_PROPERTY(QDateTime presenceTimestamp READ getPresenceTimestamp NOTIFY presenceTimestampChanged)
	Q_PROPERTY(LinphoneEnums::ConsolidatedPresence consolidatedPresence READ getConsolidatedPresence NOTIFY
	               consolidatedPresenceChanged)
	Q_PROPERTY(bool isSaved READ getIsSaved NOTIFY isSavedChanged)
	Q_PROPERTY(QString pictureUri READ getPictureUri WRITE lSetPictureUri NOTIFY pictureUriChanged)

public:
	// Should be call from model Thread. Will be automatically in App thread after initialization
	static QSharedPointer<FriendCore> create(const std::shared_ptr<linphone::Friend> &contact);
	FriendCore(const std::shared_ptr<linphone::Friend> &contact);
	FriendCore(const FriendCore &friendCore);
	~FriendCore();
	void setSelf(QSharedPointer<FriendCore> me);
	void setSelf(SafeSharedPointer<QObject> me);
	void reset(const FriendCore &contact);

	QString getName() const;
	void setName(QString data);

	QString getAddress() const;
	void setAddress(QString address);

	LinphoneEnums::ConsolidatedPresence getConsolidatedPresence() const;
	void setConsolidatedPresence(LinphoneEnums::ConsolidatedPresence presence);

	QDateTime getPresenceTimestamp() const;
	void setPresenceTimestamp(QDateTime presenceTimestamp);

	bool getIsSaved() const;
	void setIsSaved(bool isSaved);

	QString getPictureUri() const;
	void onPictureUriChanged(QString uri);

	void onPresenceReceived(LinphoneEnums::ConsolidatedPresence consolidatedPresence, QDateTime presenceTimestamp);

	Q_INVOKABLE void remove();
	Q_INVOKABLE void save();
	Q_INVOKABLE void undo();

signals:
	void contactUpdated();
	void nameChanged(QString name);
	void addressChanged(QString address);
	void consolidatedPresenceChanged(LinphoneEnums::ConsolidatedPresence level);
	void presenceTimestampChanged(QDateTime presenceTimestamp);
	void sipAddressAdded(const QString &sipAddress);
	void sipAddressRemoved(const QString &sipAddress);
	void pictureUriChanged();
	void saved();
	void isSavedChanged(bool isSaved);
	void removed(FriendCore *contact);

	void lSetPictureUri(QString pictureUri);

protected:
	void writeInto(std::shared_ptr<linphone::Friend> contact) const;
	void writeFrom(const std::shared_ptr<linphone::Friend> &contact);

	LinphoneEnums::ConsolidatedPresence mConsolidatedPresence = LinphoneEnums::ConsolidatedPresence::Offline;
	QDateTime mPresenceTimestamp;
	QString mName;
	QString mAddress;
	QString mPictureUri;
	bool mIsSaved;
	std::shared_ptr<FriendModel> mFriendModel;
	QSharedPointer<SafeConnection> mFriendModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(FriendCore *)
#endif
