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

#include "ConferenceInfoMapModel.hpp"

#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>

#include "app/App.hpp"
#include "components/conference/ConferenceAddModel.hpp"
#include "components/conference/ConferenceHelperModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/Utils.hpp"

#include "ConferenceInfoProxyModel.hpp"
#include "ConferenceInfoModel.hpp"
#include "ConferenceInfoProxyListModel.hpp"

// =============================================================================

ConferenceInfoMapModel::ConferenceInfoMapModel (QObject *parent) : ProxyAbstractMapModel<QDate,SortFilterAbstractProxyModel<ProxyListModel>*>(parent) {
	auto conferenceInfos = CoreManager::getInstance()->getCore()->getConferenceInformationList();
	for(auto conferenceInfo : conferenceInfos){
		add(conferenceInfo, false);
	}
}

// -----------------------------------------------------------------------------

void ConferenceInfoMapModel::add(const std::shared_ptr<linphone::ConferenceInfo> & conferenceInfo, const bool& sendEvents){
	auto me = CoreManager::getInstance()->getCore()->getDefaultAccount()->getParams()->getIdentityAddress();
	std::list<std::shared_ptr<linphone::Address>> participants = conferenceInfo->getParticipants();
		bool haveMe = conferenceInfo->getOrganizer()->weakEqual(me);
		if(!haveMe)
			haveMe = (std::find_if(participants.begin(), participants.end(), [me](const std::shared_ptr<linphone::Address>& address){
				return me->weakEqual(address);
			}) != participants.end());
		if(haveMe){
			auto conferenceInfoModel = ConferenceInfoModel::create( conferenceInfo );
			QDate conferenceDateTimeSystem = conferenceInfoModel->getDateTimeSystem().date();
			if( !mMappedList.contains(conferenceDateTimeSystem)){
				auto proxy = new ConferenceInfoProxyListModel(this);
				connect(this, &ConferenceInfoMapModel::filterTypeChanged, proxy, &ConferenceInfoProxyListModel::setFilterType);
				if(sendEvents){
					int row = 0;
					auto it = mMappedList.begin();
					while(it != mMappedList.end() && it.key() < conferenceDateTimeSystem){
						++row;
						++it;
					}
					beginInsertColumns(QModelIndex(), row, row);	
				}
				mMappedList[conferenceDateTimeSystem] = proxy;
				if(sendEvents)
					endInsertColumns();
			}
			mMappedList[conferenceDateTimeSystem]->add(conferenceInfoModel);
			connect(conferenceInfoModel.get(), &ConferenceInfoModel::removed, qobject_cast<ConferenceInfoProxyListModel*>(mMappedList[conferenceDateTimeSystem]), &ConferenceInfoProxyListModel::onRemoved);
		}
}