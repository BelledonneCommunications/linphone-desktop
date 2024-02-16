/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#include "ScreenListModel.hpp"
#include <QGuiApplication>
#include <QPixmap>
#include <QScreen>

ScreenListModel::ScreenListModel(QObject *parent) : ProxyAbstractListModel(parent) {
	mList = QGuiApplication::screens();
}

ScreenListModel::~ScreenListModel() {
}

QVariant ScreenListModel::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		auto screen = mList[row];
		QVariantMap data;
		data["name"] = screen->name();
		data["screenshot"] = QVariant::fromValue(screen->grabWindow(0));
		return data;
	}
	return QVariant();
}
