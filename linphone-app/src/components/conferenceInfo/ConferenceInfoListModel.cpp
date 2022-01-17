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

#include "ConferenceInfoListModel.hpp"
#include "ConferenceInfoModel.hpp"

// =============================================================================

ConferenceInfoListModel::ConferenceInfoListModel (QObject *parent) : QAbstractListModel(parent) {
	//auto conferenceInfos = CoreManager::getInstance()->getCore()->getConferenceInformationList();
	//for(auto conferenceInfo : conferenceInfos){
//		auto conferenceInfoModel = ConferenceInfoModel::create( conferenceInfo );
//		mList << conferenceInfoModel;
		//mMappedList[conferenceInfoModel->getDateTime().date()].push_back(conferenceInfoModel.get());
//	}
}

int ConferenceInfoListModel::rowCount (const QModelIndex &) const {
	return mList.size();
}

QHash<int, QByteArray> ConferenceInfoListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$conferenceInfo";
	return roles;
}

QVariant ConferenceInfoListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.size())
		return QVariant();
	auto it = mList.begin() + row;
	
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(it->get());
	
	return QVariant();
}

ConferenceInfoModel* ConferenceInfoListModel::getAt(const int& index) const {
	return mList[index].get();
}

// -----------------------------------------------------------------------------
void ConferenceInfoListModel::add(std::shared_ptr<ConferenceInfoModel> conferenceInfoModel){
	int row = mList.size();
	beginInsertRows(QModelIndex(), row,row);
	mList << conferenceInfoModel;
	endInsertRows();
}
// Should not be called as item that need to be removed are usually a cell, not a row
bool ConferenceInfoListModel::removeRow (int row, const QModelIndex &parent) {
	return removeRows(row, 1, parent);
}

bool ConferenceInfoListModel::removeRows (int row, int count, const QModelIndex &parent) {
/*
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mMappedList.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mMappedList.takeAt(row)->deleteLater();
	
	endRemoveRows();
	*/
	return true;
}

// -----------------------------------------------------------------------------
