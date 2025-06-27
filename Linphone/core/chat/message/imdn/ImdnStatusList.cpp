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

#include "ImdnStatusList.hpp"
#include "core/App.hpp"

#include <QSharedPointer>

#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ImdnStatusList)

QSharedPointer<ImdnStatusList> ImdnStatusList::create() {
	auto model = QSharedPointer<ImdnStatusList>(new ImdnStatusList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	return model;
}

ImdnStatusList::ImdnStatusList(QObject *parent) : AbstractListProxy<ImdnStatus>(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ImdnStatusList::~ImdnStatusList() {
	mustBeInMainThread("~" + getClassName());
	mList.clear();
}

QList<ImdnStatus> ImdnStatusList::getImdnStatusList() {
	return mList;
}

void ImdnStatusList::setImdnStatusList(QList<ImdnStatus> imdnStatusList) {
	resetData(imdnStatusList);
}

QVariant ImdnStatusList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) return QVariant::fromValue(mList.at(row));
	return QVariant();
}