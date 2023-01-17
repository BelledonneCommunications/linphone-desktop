/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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
 
#include "app/App.hpp"
#include "components/core/CoreManager.hpp"
#include "components/file/FileMediaModel.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#include "RecordingListModel.hpp"

#include <QDebug>
#include <QQmlApplicationEngine>


// =============================================================================

RecordingListModel::RecordingListModel (QObject *parent) : ProxyListModel(parent) {
	load();
}

RecordingListModel::~RecordingListModel(){
	mList.clear();
}

// -----------------------------------------------------------------------------

void RecordingListModel::load(){
	resetData();
	QString folder = CoreManager::getInstance()->getSettingsModel()->getSavedCallsFolder();
	qInfo() << "[Recordings] looking for recordings in " << CoreManager::getInstance()->getSettingsModel()->getSavedCallsFolder();
	QDir dir( folder );
	QList<QSharedPointer<FileMediaModel>> files;
	foreach(QFileInfo file, dir.entryInfoList(QDir::Files | QDir::NoDotAndDotDot)) {
		auto recording = FileMediaModel::create(file);
		if(recording) {
			App::getInstance()->getEngine()->setObjectOwnership(recording.get(), QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
			files << recording;
		}
	}
	if(files.size() > 0)
		add<FileMediaModel>(files);
}

QHash<int, QByteArray> RecordingListModel::roleNames () const {
	QHash<int, QByteArray> roles = ProxyListModel::roleNames();
	roles[Qt::DisplayRole+1] = "$sectionDate";
	return roles;
}

QVariant RecordingListModel::data (const QModelIndex &index, int role) const{
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	if(role == Qt::DisplayRole +1){
		return QVariant::fromValue(mList[row].objectCast<FileMediaModel>()->getCreationDateTime().date());
	}else
		return ProxyListModel::data(index, role);
}
