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

#include "ParticipantImdnStateListModel.hpp"
#include "ParticipantImdnStateModel.hpp"
#include <QQmlApplicationEngine>

#include "app/App.hpp"


#include "utils/Utils.hpp"

#include "components/Components.hpp"

// =============================================================================

ParticipantImdnStateListModel::ParticipantImdnStateListModel (std::shared_ptr<linphone::ChatMessage> message, QObject *parent) : ProxyListModel(parent) {
	QVector<linphone::ChatMessage::State> states;
	states.push_back(linphone::ChatMessage::State::Delivered);
	states.push_back(linphone::ChatMessage::State::DeliveredToUser);
	states.push_back(linphone::ChatMessage::State::Displayed);
	states.push_back(linphone::ChatMessage::State::NotDelivered);
	for(int i = 0 ; i < states.size() ; ++i){
		std::list<std::shared_ptr<linphone::ParticipantImdnState>> imdns = message->getParticipantsByImdnState(states[i]);
		for(auto imdn : imdns){
			if(imdn->getParticipant()){
				auto deviceModel = QSharedPointer<ParticipantImdnStateModel>::create(imdn);
				mList << deviceModel;
			}
		}
	}
}
//--------------------------------------------------------------------------------

QSharedPointer<ParticipantImdnStateModel> ParticipantImdnStateListModel::getImdnState(const std::shared_ptr<const linphone::ParticipantImdnState> & state){
	QSharedPointer<ParticipantImdnStateModel> imdn;
	auto participant = state->getParticipant();
	auto it = mList.begin();
	if( participant){
		auto imdnAddress = state->getParticipant()->getAddress();
		while(it != mList.end() && !it->objectCast<ParticipantImdnStateModel>()->getAddress()->equal(imdnAddress))
			++it;
	}else
		it = mList.end();
	if(it != mList.end())
		imdn = it->objectCast<ParticipantImdnStateModel>();
	else{// Create the new one
		imdn = QSharedPointer<ParticipantImdnStateModel>::create(state);
		add(imdn);
	}
	return imdn;
}

//--------------------------------------------------------------------------------

void ParticipantImdnStateListModel::updateState(const std::shared_ptr<const linphone::ParticipantImdnState> & state){
	if(state->getParticipant())
		getImdnState(state)->update(state);
}

//--------------------------------------------------------------------------------

void ParticipantImdnStateListModel::onParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){
	updateState(state);	
}