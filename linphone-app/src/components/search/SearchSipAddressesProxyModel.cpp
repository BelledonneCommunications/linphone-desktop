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

#include "SearchSipAddressesProxyModel.hpp"

#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "components/sip-addresses/SipAddressesSorter.hpp"

#include "SearchSipAddressesModel.hpp"
#include "SearchResultModel.hpp"
#include "utils/Utils.hpp"
#include <QVariantMap>


// -----------------------------------------------------------------------------

SearchSipAddressesProxyModel::SearchSipAddressesProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	setSourceModel(new SearchSipAddressesModel(this));
	sort(0);
}

// -----------------------------------------------------------------------------

SearchSipAddressesModel * SearchSipAddressesProxyModel::getModel(){
	return qobject_cast<SearchSipAddressesModel*>(sourceModel());
}

void SearchSipAddressesProxyModel::setFilter (const QString &pattern){
	mFilter = pattern;
	getModel()->setFilter(pattern);
}

void SearchSipAddressesProxyModel::addAddressToIgnore(const QString& address){
	std::shared_ptr<linphone::Address> a = Utils::interpretUrl(address);
	mResultsToIgnore[Utils::coreStringToAppString(a->asStringUriOnly())] = true;
	invalidate();
}

void SearchSipAddressesProxyModel::removeAddressToIgnore(const QString& address){
	std::shared_ptr<linphone::Address> a = Utils::interpretUrl(address);
	mResultsToIgnore.remove(Utils::coreStringToAppString(a->asStringUriOnly()));
	invalidate();
}

bool SearchSipAddressesProxyModel::isIgnored(const QString& address) const{
	if(address != ""){
		std::shared_ptr<linphone::Address> a = Utils::interpretUrl(address);
		return mResultsToIgnore.contains(Utils::coreStringToAppString(a->asStringUriOnly()));
	}
	return false;
}

bool SearchSipAddressesProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
	const SearchResultModel * model = sourceModel()->data(index).value<SearchResultModel*>();
	if(!model)
		return false;
	else
		return !mResultsToIgnore.contains(Utils::coreStringToAppString(model->getAddress()->asStringUriOnly()));
}

bool SearchSipAddressesProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	const SearchResultModel * modelA = sourceModel()->data(left).value<SearchResultModel*>();
	const SearchResultModel * modelB = sourceModel()->data(right).value<SearchResultModel*>();
	return SipAddressesSorter::lessThan(mFilter, modelA, modelB);
}

