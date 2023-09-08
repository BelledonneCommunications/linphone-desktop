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

#ifndef CALL_HISTORY_MODEL_H_
#define CALL_HISTORY_MODEL_H_

#include <QObject>
#include <QDateTime>
#include <linphone++/linphone.hh>

#include "components/conferenceInfo/ConferenceInfoModel.hpp"
#include "utils/LinphoneEnums.hpp"

class CallHistoryModel : public QObject {
  Q_OBJECT

public:
	Q_PROPERTY(QString remoteAddress READ getRemoteAddress CONSTANT)	// strip from gruu/conf-id
	Q_PROPERTY(QString sipAddress READ getSipAddress NOTIFY conferenceInfoModelChanged)	// Use to call
	Q_PROPERTY(bool selected MEMBER mSelected WRITE setSelected NOTIFY selectedChanged)
	
	Q_PROPERTY(LinphoneEnums::CallStatus lastCallStatus MEMBER mLastCallStatus WRITE setLastCallStatus NOTIFY lastCallStatusChanged)
	Q_PROPERTY(QDateTime lastCallDate MEMBER mLastCallDate WRITE setLastCallDate NOTIFY lastCallDateChanged)
	Q_PROPERTY(bool lastCallIsStart MEMBER mLastCallIsStart WRITE setLastCallIsStart NOTIFY lastCallIsStartChanged)
	Q_PROPERTY(bool lastCallIsOutgoing MEMBER mLastCallIsOutgoing WRITE setLastCallIsOutgoing NOTIFY lastCallIsOutgoingChanged)
	Q_PROPERTY(ConferenceInfoModel * conferenceInfoModel READ getConferenceInfoModel NOTIFY conferenceInfoModelChanged)
	Q_PROPERTY(bool wasConference READ wasConference NOTIFY conferenceInfoModelChanged)
	Q_PROPERTY(QString title READ getTitle NOTIFY conferenceInfoModelChanged)
	
	CallHistoryModel(QObject *parent = nullptr);
	CallHistoryModel(const std::shared_ptr<linphone::CallLog> callLogs, QObject *parent = nullptr);
	
	QString getRemoteAddress() const;
	QString getSipAddress() const;
	ConferenceInfoModel * getConferenceInfoModel() const;
	bool wasConference() const;
	QString getTitle() const;
	
	void update(const std::shared_ptr<linphone::CallLog> callLog);
	
	void setLastCallStatus(LinphoneEnums::CallStatus status);
	void setLastCallDate(const QDateTime& date);
	void setLastCallIsStart(const bool& start);
	void setLastCallIsOutgoing(const bool& outgoing);
	
	void setSelected(const bool& selected);
	Q_INVOKABLE void selectOnly();	// Select this item and remove others in parent lists
	
	QDateTime mLastCallDate;
	bool mSelected = false;
	bool mLastCallIsOutgoing;
	LinphoneEnums::CallStatus mLastCallStatus;
	
signals:
	void selectOnlyRequested();
	void selectedChanged(bool selected, CallHistoryModel * model);
	void lastCallStatusChanged();
	void lastCallDateChanged();
	void lastCallIsStartChanged();
	void lastCallIsOutgoingChanged();
	void conferenceInfoModelChanged();
	void hasBeenRemoved();

private:
	std::shared_ptr<linphone::Address> mRemoteAddress;
	bool mLastCallIsStart;
	QSharedPointer<ConferenceInfoModel> mConferenceInfoModel;
	
	bool mShowEnd = false;	// Display ended call (start + duration)
};

#endif
