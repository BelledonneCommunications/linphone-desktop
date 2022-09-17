/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef PARTICIPANT_IMDN_STATE_LIST_MODEL_H_
#define PARTICIPANT_IMDN_STATE_LIST_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>

#include "app/proxyModel/ProxyListModel.hpp"

class ParticipantImdnStateModel;

class ParticipantImdnStateListModel : public ProxyListModel {
	Q_OBJECT
	
public:
	ParticipantImdnStateListModel (std::shared_ptr<linphone::ChatMessage> message, QObject *parent = nullptr);
	
	QSharedPointer<ParticipantImdnStateModel> getImdnState(const std::shared_ptr<const linphone::ParticipantImdnState> & state);
	
	void updateState(const std::shared_ptr<const linphone::ParticipantImdnState> & state);
		
public slots:
	void onParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state);

signals:
	void imdnStateChanged();
	void stateChangedFromIdle();
};

Q_DECLARE_METATYPE(QSharedPointer<ParticipantImdnStateListModel>)

#endif 
