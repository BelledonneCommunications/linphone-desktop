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

ParticipantImdnStateListModel::ParticipantImdnStateListModel (std::shared_ptr<linphone::ChatMessage> message, QObject *parent) : QAbstractListModel(parent) {
	QVector<linphone::ChatMessage::State> states;
	states.push_back(linphone::ChatMessage::State::Delivered);
	states.push_back(linphone::ChatMessage::State::DeliveredToUser);
	states.push_back(linphone::ChatMessage::State::Displayed);
	states.push_back(linphone::ChatMessage::State::NotDelivered);
	for(int i = 0 ; i < states.size() ; ++i){
		std::list<std::shared_ptr<linphone::ParticipantImdnState>> imdns = message->getParticipantsByImdnState(states[i]);
		for(auto imdn : imdns){
			if(imdn->getParticipant()){
				auto deviceModel = std::make_shared<ParticipantImdnStateModel>(imdn);
				mList << deviceModel;
			}
		}
	}
}

int ParticipantImdnStateListModel::rowCount (const QModelIndex &index) const{
	return mList.count();
}

QHash<int, QByteArray> ParticipantImdnStateListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$participantImdn";
	return roles;
}

QVariant ParticipantImdnStateListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(mList[row].get());
	
	return QVariant();
}

void ParticipantImdnStateListModel::add(std::shared_ptr<ParticipantImdnStateModel> imdn){
	int row = mList.count();
	beginInsertRows(QModelIndex(), row, row);
	mList << imdn;
	endInsertRows();
	emit countChanged();
	emit layoutChanged();
}

bool ParticipantImdnStateListModel::removeRow (int row, const QModelIndex &parent){
	return removeRows(row, 1, parent);
}

bool ParticipantImdnStateListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mList.takeAt(row);
	
	endRemoveRows();
	emit countChanged();
	return true;
}

//--------------------------------------------------------------------------------

std::shared_ptr<ParticipantImdnStateModel> ParticipantImdnStateListModel::getImdnState(const std::shared_ptr<const linphone::ParticipantImdnState> & state){
	std::shared_ptr<ParticipantImdnStateModel> imdn;
	auto participant = state->getParticipant();
	auto it = mList.begin();
	if( participant){
		auto imdnAddress = state->getParticipant()->getAddress();
		while(it != mList.end() && !(*it)->getAddress()->equal(imdnAddress))
			++it;
	}else
		it = mList.end();
	if(it != mList.end())
		imdn = *it;
	else{// Create the new one
		imdn = std::make_shared<ParticipantImdnStateModel>(state);
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