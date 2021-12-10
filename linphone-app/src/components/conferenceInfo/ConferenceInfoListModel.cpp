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
	auto conferenceInfos = CoreManager::getInstance()->getCore()->getConferenceInformationList();
	for(auto conferenceInfo : conferenceInfos){
		mList << ConferenceInfoModel::create( conferenceInfo );
	}
}

int ConferenceInfoListModel::rowCount (const QModelIndex &) const {
	return mList.count();
}

QHash<int, QByteArray> ConferenceInfoListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$conferenceInfo";
	return roles;
}

QVariant ConferenceInfoListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(mList[row].get());
	
	//return QVariant();
}

// -----------------------------------------------------------------------------


bool ConferenceInfoListModel::removeRow (int row, const QModelIndex &parent) {
	return removeRows(row, 1, parent);
}

bool ConferenceInfoListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
	
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mList.takeAt(row)->deleteLater();
	
	endRemoveRows();
	
	return true;
}

// -----------------------------------------------------------------------------
