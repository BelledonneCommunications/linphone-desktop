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

#include "PhoneNumberProxy.hpp"
#include "PhoneNumber.hpp"

DEFINE_ABSTRACT_OBJECT(PhoneNumberProxy)

PhoneNumberProxy::PhoneNumberProxy(QObject *parent) : LimitProxy(parent) {
	mPhoneNumberList = PhoneNumberList::create();
	setSourceModels(new SortFilterList(mPhoneNumberList.get(), Qt::AscendingOrder));
}

PhoneNumberProxy::~PhoneNumberProxy() {
}

int PhoneNumberProxy::findIndexByCountryCallingCode(const QString &countryCallingCode) {
	auto model = getListModel<PhoneNumberList>();
	if (!model) return -1;
	if (countryCallingCode.isEmpty()) return -1;

	auto list = model->getSharedList<PhoneNumber>();
	auto it = std::find_if(list.begin(), list.end(), [countryCallingCode](const QSharedPointer<QObject> &a) {
		return a.objectCast<PhoneNumber>()->mCountryCallingCode == countryCallingCode;
	});
	auto proxyModelIndex =
	    dynamic_cast<SortFilterList *>(sourceModel())->mapFromSource(model->index(it - list.begin()));
	return proxyModelIndex.row();
}

bool PhoneNumberProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	bool show = (mFilterText.isEmpty() || mFilterText == "*");
	if (!show) {
		QRegularExpression search(QRegularExpression::escape(mFilterText),
		                          QRegularExpression::CaseInsensitiveOption |
		                              QRegularExpression::UseUnicodePropertiesOption);
		auto phoneNumber = getItemAtSource<PhoneNumberList, PhoneNumber>(sourceRow);
		show = phoneNumber->mCountry.contains(search) || phoneNumber->mCountryCallingCode.contains(search);
	}

	return show;
}

bool PhoneNumberProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<PhoneNumberList, PhoneNumber>(sourceLeft.row());
	auto r = getItemAtSource<PhoneNumberList, PhoneNumber>(sourceRight.row());
	return l->mCountry < r->mCountry;
}
