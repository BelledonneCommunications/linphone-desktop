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

#include "ConferenceInfoProxyModel.hpp"

#include "components/call/CallModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/settings/AccountSettingsModel.hpp"

#include "ConferenceInfoMapModel.hpp"
#include "ConferenceInfoProxyListModel.hpp"

// =============================================================================

using namespace std;

//---------------------------------------------------------------------------------------------

ConferenceInfoProxyModel::ConferenceInfoProxyModel (QObject *parent) : SortFilterAbstractProxyModel<ConferenceInfoMapModel>(new ConferenceInfoMapModel(parent), parent) {
	connect(CoreManager::getInstance()->getAccountSettingsModel(), &AccountSettingsModel::primarySipAddressChanged, this, &ConferenceInfoProxyModel::update);
	connect(this, &ConferenceInfoProxyModel::filterTypeChanged, qobject_cast<ConferenceInfoMapModel*>(sourceModel()), &ConferenceInfoMapModel::filterTypeChanged);
	connect(CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::conferenceInfoReceived, this, &ConferenceInfoProxyModel::onConferenceInfoReceived);
	setFilterType((int)Scheduled);
}

void ConferenceInfoProxyModel::update(){
	int oldFilter = getFilterType();
	SortFilterAbstractProxyModel<ConferenceInfoMapModel>::update(new ConferenceInfoMapModel(parent()));
	setFilterType(oldFilter+1);
	connect(this, &ConferenceInfoProxyModel::filterTypeChanged, qobject_cast<ConferenceInfoMapModel*>(sourceModel()), &ConferenceInfoMapModel::filterTypeChanged);
	setFilterType(oldFilter);
}

bool ConferenceInfoProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	QModelIndex index = sourceModel()->index(sourceRow, 0, QModelIndex());
	const ConferenceInfoMapModel* ics = sourceModel()->data(index).value<ConferenceInfoMapModel*>();
	if(ics){
		int r = ics->rowCount();
		return r > 0;
	}
	const ConferenceInfoProxyListModel* listModel = sourceModel()->data(index).value<ConferenceInfoProxyListModel*>();
	if(listModel){
		int r = listModel->rowCount();
		return r > 0;
	}
	return false;
}

void ConferenceInfoProxyModel::onConferenceInfoReceived(const std::shared_ptr<const linphone::ConferenceInfo> & conferenceInfo){
	auto realConferenceInfo = ConferenceInfoModel::findConferenceInfo(conferenceInfo);
	if( realConferenceInfo ){
		auto model =  qobject_cast<ConferenceInfoMapModel*>(sourceModel());
		model->add(realConferenceInfo);
	}else
		qWarning() << "No conferenceInfo have beend found for " << conferenceInfo->getUri()->asString().c_str();
}
