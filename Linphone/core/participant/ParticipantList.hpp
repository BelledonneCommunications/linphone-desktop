/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#ifndef PARTICIPANT_LIST_H_
#define PARTICIPANT_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "core/participant/ParticipantCore.hpp"
#include "model/conference/ConferenceModel.hpp"

class ConferenceModel;

// =============================================================================

class ParticipantList : public ListProxy, public AbstractObject {
	Q_OBJECT
public:
	static QSharedPointer<ParticipantList> create();

	// ParticipantList(ChatRoomModel *chatRoomModel, QObject *parent = Q_NULLPTR);
	// ParticipantList(ConferenceModel *conferenceModel, QObject *parent = Q_NULLPTR);
	ParticipantList(QObject *parent = Q_NULLPTR);
	virtual ~ParticipantList();

	void setSelf(QSharedPointer<ParticipantList> me);

	// Q_PROPERTY(ChatRoomModel *chatRoomModel READ getChatRoomModel CONSTANT)
	Q_PROPERTY(QString addressesToString READ addressesToString NOTIFY participantsChanged)
	Q_PROPERTY(QString displayNamesToString READ displayNamesToString NOTIFY participantsChanged)
	Q_PROPERTY(QString usernamesToString READ usernamesToString NOTIFY participantsChanged)

	void reset();
	// void updateParticipants(); // Update list from Chat Room
	// const QSharedPointer<ParticipantCore>
	// getParticipant(const std::shared_ptr<const linphone::Address> &address) const;
	// const QSharedPointer<ParticipantCore> const QSharedPointer<ParticipantCore>
	// getParticipant(const std::shared_ptr<const linphone::Participant> &participant) const;

	Q_INVOKABLE void remove(ParticipantCore *participant);
	std::list<std::shared_ptr<linphone::Address>> getParticipants() const;

	Q_INVOKABLE QString addressesToString() const;
	Q_INVOKABLE QString displayNamesToString() const;
	Q_INVOKABLE QString usernamesToString() const;

	bool contains(const QString &address) const;

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

public slots:
	void setAdminStatus(const std::shared_ptr<linphone::Participant> participant, const bool &isAdmin);

	void onSecurityEvent(const std::shared_ptr<const linphone::EventLog> &eventLog);
	void onConferenceJoined();
	void onParticipantAdded(const std::shared_ptr<const linphone::Participant> &participant);
	void onParticipantAdded(const std::shared_ptr<const linphone::EventLog> &eventLog);
	void onParticipantAdded(const std::shared_ptr<const linphone::Address> &address);
	void onParticipantRemoved(const std::shared_ptr<const linphone::Participant> &participant);
	void onParticipantRemoved(const std::shared_ptr<const linphone::EventLog> &eventLog);
	void onParticipantRemoved(const std::shared_ptr<const linphone::Address> &address);
	void onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::Participant> &participant);
	void onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::EventLog> &eventLog);
	void onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::Address> &address);
	void onParticipantDeviceAdded(const std::shared_ptr<const linphone::EventLog> &eventLog);
	void onParticipantDeviceRemoved(const std::shared_ptr<const linphone::EventLog> &eventLog);
	void
	onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<const linphone::Address> &participantAddress);
	void onParticipantRegistrationUnsubscriptionRequested(
	    const std::shared_ptr<const linphone::Address> &participantAddress);
	void onStateChanged();

signals:
	void securityLevelChanged();
	void deviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void participantsChanged();

	void lUpdateParticipants();

private:
	std::shared_ptr<ConferenceModel> mConferenceModel;
	QSharedPointer<SafeConnection<ParticipantList, ConferenceModel>> mModelConnection;

	// ChatRoomModel *mChatRoomModel = nullptr;
	// ConferenceCore *mConferenceCore = nullptr;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(QSharedPointer<ParticipantList>);
#endif // PARTICIPANT_LIST_H_
