/*
 * Copyright (c) 2023 Belledonne Communications SARL.
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

#ifndef RECORDING_PROXY_MODEL_H_
#define RECORDING_PROXY_MODEL_H_

#include "app/proxyModel/SortFilterProxyModel.hpp"
#include <memory>

// =============================================================================

class FileMediaModel;

class RecordingProxyModel : public SortFilterProxyModel {
	Q_OBJECT
	
public:
	RecordingProxyModel ( QObject *parent = Q_NULLPTR);
	
	//bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
	Q_INVOKABLE void remove(FileMediaModel * file);
	//Q_INVOKABLE int getCount() const;
};

#endif
