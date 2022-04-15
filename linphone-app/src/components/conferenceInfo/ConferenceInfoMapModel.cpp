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
#include "ConferenceInfoListModel.hpp"
#include "ConferenceInfoModel.hpp"
#include "ConferenceInfoProxyListModel.hpp"

// =============================================================================

ConferenceInfoMapModel::ConferenceInfoMapModel (QObject *parent) : ProxyAbstractMapModel<QDate,SortFilterAbstractProxyModel<ConferenceInfoListModel>*>(parent) {
	auto conferenceInfos = CoreManager::getInstance()->getCore()->getConferenceInformationList();
	auto me = CoreManager::getInstance()->getCore()->getDefaultAccount()->getParams()->getIdentityAddress();
	for(auto conferenceInfo : conferenceInfos){
		std::list<std::shared_ptr<linphone::Address>> participants = conferenceInfo->getParticipants();
		bool haveMe = conferenceInfo->getOrganizer()->weakEqual(me);
		if(!haveMe)
			haveMe = (std::find_if(participants.begin(), participants.end(), [me](const std::shared_ptr<linphone::Address>& address){
				return me->weakEqual(address);
			}) != participants.end());
		if(haveMe){
			auto conferenceInfoModel = ConferenceInfoModel::create( conferenceInfo );
			QDate t = conferenceInfoModel->getDateTime().date();
			if( !mMappedList.contains(t)){
				//auto proxy = new SortFilterAbstractProxyModel<ConferenceInfoListModel>(new ConferenceInfoListModel(), this);
				auto proxy = new ConferenceInfoProxyListModel(this);
				connect(this, &ConferenceInfoMapModel::filterTypeChanged, proxy, &ConferenceInfoProxyListModel::setFilterType);
				mMappedList[t] = proxy;
			}
				//mMappedList[t] = new ConferenceInfoProxyModel(new ConferenceInfoListModel(), this);
			mMappedList[t]->add(conferenceInfoModel);
		}
	}
}

// -----------------------------------------------------------------------------