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

#ifndef CALL_HISTORY_CORE_H_
#define CALL_HISTORY_CORE_H_

#include "core/conference/ConferenceInfoGui.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QDateTime>
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class CallHistoryModel;
class FriendModel;

class CallHistoryCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString displayName MEMBER mDisplayName NOTIFY displayNameChanged)
	Q_PROPERTY(QString remoteAddress MEMBER mRemoteAddress CONSTANT)
	Q_PROPERTY(bool isOutgoing MEMBER mIsOutgoing CONSTANT)
	Q_PROPERTY(bool isConference MEMBER mIsConference CONSTANT)
	Q_PROPERTY(ConferenceInfoGui *conferenceInfo READ getConferenceInfoGui CONSTANT)
	Q_PROPERTY(QDateTime date MEMBER mDate CONSTANT)
	Q_PROPERTY(LinphoneEnums::CallStatus status MEMBER mStatus CONSTANT)
	Q_PROPERTY(QString duration READ getDuration WRITE setDuration NOTIFY durationChanged)

public:
	static QSharedPointer<CallHistoryCore> create(const std::shared_ptr<linphone::CallLog> &callLogs);
	CallHistoryCore(const std::shared_ptr<linphone::CallLog> &callLog);
	~CallHistoryCore();

	void setSelf(QSharedPointer<CallHistoryCore> me);
	ConferenceInfoGui *getConferenceInfoGui() const;

	QString getDuration() const;
	void setDuration(const QString &duration);

	void onRemoved(const std::shared_ptr<linphone::Friend> &updatedFriend);

	Q_INVOKABLE void remove();

	QString mRemoteAddress;
	QString mDisplayName;
	QDateTime mDate;
	bool mIsOutgoing;
	bool mIsConference = false;
	LinphoneEnums::CallStatus mStatus;
	QString mCallId;

signals:
	void durationChanged(QString duration);
	void displayNameChanged();
	void friendUpdated(); // When a friend is created, this log is linked to it.
	void removed();

private:
	QString mDuration;
	QSharedPointer<ConferenceInfoCore> mConferenceInfo = nullptr;
	std::shared_ptr<CallHistoryModel> mCallHistoryModel;
	std::shared_ptr<FriendModel> mFriendModel;
	QSharedPointer<SafeConnection<CallHistoryCore, FriendModel>> mFriendModelConnection;
	QSharedPointer<SafeConnection<CallHistoryCore, CallHistoryModel>> mHistoryModelConnection;
	QSharedPointer<SafeConnection<CallHistoryCore, CoreModel>> mCoreModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(CallHistoryCore *)
#endif
