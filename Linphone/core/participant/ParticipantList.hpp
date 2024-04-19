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
	static QSharedPointer<ParticipantList> create(const std::shared_ptr<ConferenceModel> &conferenceModel);

	// ParticipantList(ChatRoomModel *chatRoomModel, QObject *parent = Q_NULLPTR);
	// ParticipantList(ConferenceModel *conferenceModel, QObject *parent = Q_NULLPTR);
	ParticipantList(QObject *parent = Q_NULLPTR);
	virtual ~ParticipantList();

	void setSelf(QSharedPointer<ParticipantList> me);

	// Q_PROPERTY(ChatRoomModel *chatRoomModel READ getChatRoomModel CONSTANT)
	void reset();
	// void updateParticipants(); // Update list from Chat Room

	Q_INVOKABLE void remove(ParticipantCore *participant);
	void addAddress(const QString &address);

	std::list<std::shared_ptr<linphone::Address>> getParticipants() const;

	bool contains(const QString &address) const;

	void setConferenceModel(const std::shared_ptr<ConferenceModel> &conferenceModel);

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void securityLevelChanged();
	void deviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void participantsChanged();

	void lUpdateParticipants();
	void lSetParticipantAdminStatus(ParticipantCore *participant, bool status);

private:
	std::shared_ptr<ConferenceModel> mConferenceModel;
	QSharedPointer<SafeConnection<ParticipantList, ConferenceModel>> mConferenceModelConnection;

	// ChatRoomModel *mChatRoomModel = nullptr;
	// ConferenceCore *mConferenceCore = nullptr;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(QSharedPointer<ParticipantList>);
#endif // PARTICIPANT_LIST_H_
