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

#include "ConferenceInfoListModel.hpp"

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

// =============================================================================

ConferenceInfoListModel::ConferenceInfoListModel (QObject *parent) : ProxyListModel(parent) {
	auto conferenceInfos = CoreManager::getInstance()->getCore()->getConferenceInformationList();
	QList<QSharedPointer<ConferenceInfoModel> > items;
	for(auto conferenceInfo : conferenceInfos){
		auto item = build(conferenceInfo);
		if(item)
			items << item;
	}
	if(items.size() > 0)
		ProxyListModel::add(items);
}

// -----------------------------------------------------------------------------

QSharedPointer<ConferenceInfoModel> ConferenceInfoListModel::build(const std::shared_ptr<linphone::ConferenceInfo> & conferenceInfo) const{
	auto me = CoreManager::getInstance()->getCore()->getDefaultAccount()->getParams()->getIdentityAddress();
	std::list<std::shared_ptr<linphone::Address>> participants = conferenceInfo->getParticipants();
	bool haveMe = conferenceInfo->getOrganizer()->weakEqual(me);
	if(!haveMe)
		haveMe = (std::find_if(participants.begin(), participants.end(), [me](const std::shared_ptr<linphone::Address>& address){
			return me->weakEqual(address);
		}) != participants.end());
	if(haveMe)
		return ConferenceInfoModel::create( conferenceInfo );
	else
		return nullptr;
}

void ConferenceInfoListModel::add(const std::shared_ptr<linphone::ConferenceInfo> & conferenceInfo, const bool& sendEvents){
	auto item = build(conferenceInfo);
	if( item)
		ProxyListModel::add(item);
}

QHash<int, QByteArray> ConferenceInfoListModel::roleNames () const{
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$modelData";
	roles[Qt::DisplayRole+1] = "$sectionDate";
	return roles;
}

QVariant ConferenceInfoListModel::data (const QModelIndex &index, int role ) const{
		int row = index.row();
		if (!index.isValid() || row < 0 || row >= mList.count())
			return QVariant();
		if (role == Qt::DisplayRole)
			return QVariant::fromValue(mList[row].get());
		else if (role == Qt::DisplayRole +1 )
			return QVariant::fromValue(mList[row].objectCast<ConferenceInfoModel>()->getDateTimeUtc().date());
		return QVariant();
	}