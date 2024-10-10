/*
 * Copyright (c) 2020 Belledonne Communications SARL.
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

#ifndef PARTICIPANT_PROXY_H_
#define PARTICIPANT_PROXY_H_

#include "../proxy/LimitProxy.hpp"
#include "core/call/CallGui.hpp"
#include "tool/AbstractObject.hpp"

#include <memory>

class ParticipantCore;
class ChatRoomModel;
class ParticipantList;
class ConferenceModel;
class ConferenceInfoModel;
// =============================================================================

class QWindow;

class ParticipantProxy : public LimitProxy, public AbstractObject {

	Q_OBJECT
	Q_PROPERTY(CallGui *currentCall READ getCurrentCall WRITE setCurrentCall NOTIFY currentCallChanged)
	Q_PROPERTY(bool showMe READ getShowMe WRITE setShowMe NOTIFY showMeChanged)

public:
	DECLARE_SORTFILTER_CLASS(bool mShowMe;)

	ParticipantProxy(QObject *parent = Q_NULLPTR);
	~ParticipantProxy();

	CallGui *getCurrentCall() const;
	void setCurrentCall(CallGui *callGui);

	bool getShowMe() const;
	void setShowMe(const bool &show);

	Q_INVOKABLE void addAddress(const QString &address);
	Q_INVOKABLE void addAddresses(const QStringList &addresses);
	Q_INVOKABLE void removeParticipant(ParticipantCore *participant);
	Q_INVOKABLE void setParticipantAdminStatus(ParticipantCore *participant, bool status);

signals:
	void chatRoomModelChanged();
	void conferenceModelChanged();
	void participantListChanged();
	void countChanged();
	void showMeChanged();
	void addressAdded(QString sipAddress);
	void addressRemoved(QString sipAddress);
	void currentCallChanged();

private:
	CallGui *mCurrentCall = nullptr;
	QSharedPointer<ParticipantList> mParticipants;
	DECLARE_ABSTRACT_OBJECT
};

#endif // PARTICIPANT_PROXY_H_
