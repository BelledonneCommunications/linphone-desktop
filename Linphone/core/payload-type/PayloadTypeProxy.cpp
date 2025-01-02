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

#include "PayloadTypeProxy.hpp"
#include "PayloadTypeGui.hpp"
#include "PayloadTypeList.hpp"

DEFINE_ABSTRACT_OBJECT(PayloadTypeProxy)

PayloadTypeProxy::PayloadTypeProxy(QObject *parent) : LimitProxy(parent) {
	mPayloadTypeList = PayloadTypeList::create();
	setSourceModels(new SortFilterList(mPayloadTypeList.get()));
}

PayloadTypeProxy::~PayloadTypeProxy() {
}

bool PayloadTypeProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	auto payload = qobject_cast<PayloadTypeList *>(sourceModel())->getAt<PayloadTypeCore>(sourceRow);
	int payloadFlag = PayloadTypeProxyFiltering::All;
	payloadFlag += payload->isDownloadable() ? PayloadTypeProxyFiltering::Downloadable
	                                         : PayloadTypeProxyFiltering::NotDownloadable;
	auto family = payload->getFamily();
	payloadFlag += family == PayloadTypeCore::Family::Audio ? PayloadTypeProxyFiltering::Audio : 0;
	payloadFlag += family == PayloadTypeCore::Family::Video ? PayloadTypeProxyFiltering::Video : 0;
	payloadFlag += family == PayloadTypeCore::Family::Text ? PayloadTypeProxyFiltering::Text : 0;
	return mFilterType == payloadFlag;
}

bool PayloadTypeProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<PayloadTypeList, PayloadTypeCore>(sourceLeft.row());
	auto r = getItemAtSource<PayloadTypeList, PayloadTypeCore>(sourceRight.row());

	return l->getMimeType() < r->getMimeType();
}

void PayloadTypeProxy::reload() {
	emit mPayloadTypeList->lUpdate();
}
