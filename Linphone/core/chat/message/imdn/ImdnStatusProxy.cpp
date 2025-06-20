
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

#include "ImdnStatusProxy.hpp"
#include "ImdnStatusList.hpp"
#include "core/App.hpp"
// #include "core/chat/message/ChatMessageGui.hpp"

DEFINE_ABSTRACT_OBJECT(ImdnStatusProxy)

ImdnStatusProxy::ImdnStatusProxy(QObject *parent) : LimitProxy(parent) {
	mList = ImdnStatusList::create();
	setSourceModel(mList.get());
	connect(mList.get(), &ImdnStatusList::modelReset, this, &ImdnStatusProxy::imdnStatusListChanged);
	connect(this, &ImdnStatusProxy::filterChanged, this, [this] { invalidate(); });
}

ImdnStatusProxy::~ImdnStatusProxy() {
}

QList<ImdnStatus> ImdnStatusProxy::getImdnStatusList() {
	return mList->getImdnStatusList();
}

void ImdnStatusProxy::setImdnStatusList(QList<ImdnStatus> statusList) {
	mList->setImdnStatusList(statusList);
}

LinphoneEnums::ChatMessageState ImdnStatusProxy::getFilter() const {
	return mFilter;
}

void ImdnStatusProxy::setFilter(LinphoneEnums::ChatMessageState filter) {
	if (mFilter != filter) {
		mFilter = filter;
		emit filterChanged();
	}
}

bool ImdnStatusProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	auto imdn = mList->getAt(sourceRow);
	return imdn.mState == mFilter;
}

bool ImdnStatusProxy::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	return true;
}
