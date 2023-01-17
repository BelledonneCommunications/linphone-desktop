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

#include "RecordingProxyModel.hpp"

#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "components/conference/ConferenceModel.hpp"
#include "components/conferenceInfo/ConferenceInfoModel.hpp"
#include "components/file/FileMediaModel.hpp"
#include "components/sound-player/SoundPlayer.hpp"
#include "utils/Utils.hpp"

#include "RecordingListModel.hpp"

#include <QDebug>


// =============================================================================

// -----------------------------------------------------------------------------

RecordingProxyModel::RecordingProxyModel (QObject *parent) : SortFilterProxyModel(parent) {
	auto list = new RecordingListModel(this);
	setSourceModel(list);
	sort(0);
}

// -----------------------------------------------------------------------------

void RecordingProxyModel::remove(FileMediaModel * fileModel){
	QFile file(fileModel->getFilePath());
	if(file.remove())
		qobject_cast<RecordingListModel*>(sourceModel())->remove(fileModel);
}

bool RecordingProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	const FileMediaModel* a = sourceModel()->data(left).value<FileMediaModel*>();
	const FileMediaModel* b = sourceModel()->data(right).value<FileMediaModel*>();
	
	return a->getCreationDateTime() > b->getCreationDateTime();
}
