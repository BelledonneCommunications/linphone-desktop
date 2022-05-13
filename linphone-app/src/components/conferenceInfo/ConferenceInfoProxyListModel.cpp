/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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
 
#include "app/proxyModel/ProxyListModel.hpp"
#include "ConferenceInfoProxyListModel.hpp"

#include "components/call/CallModel.hpp"
#include "components/core/CoreManager.hpp"

#include "ConferenceInfoMapModel.hpp"

#include "utils/Utils.hpp"


// =============================================================================

using namespace std;

//---------------------------------------------------------------------------------------------

ConferenceInfoProxyListModel::ConferenceInfoProxyListModel (QObject *parent) : SortFilterAbstractProxyModel<ProxyListModel>(new ProxyListModel(parent), parent) {
}

bool ConferenceInfoProxyListModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	auto listModel = qobject_cast<ProxyListModel*>(sourceModel());
	if(listModel){
		QModelIndex index = listModel->index(sourceRow, 0, QModelIndex());
		const ConferenceInfoModel* ics = sourceModel()->data(index).value<ConferenceInfoModel*>();
		if(ics){
			QDateTime currentDateTime = QDateTime::currentDateTime();
			if( mFilterType == 0){
				return ics->getEndDateTime() < currentDateTime;
			}else if( mFilterType == 1){
				return ics->getEndDateTime() >= currentDateTime;
			}else if( mFilterType == 2){
				return !Utils::isMe(ics->getOrganizer());
			}else
				return mFilterType == -1;
		}
	}
	return true;
}

bool ConferenceInfoProxyListModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	return true;
}