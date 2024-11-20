/*
 * Copyright (c) 2022-2024 Belledonne Communications SARL.
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

#include "LimitProxy.hpp"

LimitProxy::LimitProxy(QObject *parent) : QSortFilterProxyModel(parent) {
	connect(this, &LimitProxy::rowsInserted, this, &LimitProxy::countChanged);
	connect(this, &LimitProxy::rowsRemoved, this, &LimitProxy::countChanged);
	connect(this, &LimitProxy::modelReset, this, &LimitProxy::countChanged);
	connect(this, &LimitProxy::countChanged, this, &LimitProxy::haveMoreChanged);
}
/*
LimitProxy::LimitProxy(QAbstractItemModel *sortFilterProxy, QObject *parent) : QSortFilterProxyModel(parent) {
    setSourceModel(sortFilterProxy);
}*/
LimitProxy::~LimitProxy() {
	//	if (mDeleteSourceModel) deleteSourceModel();
}

bool LimitProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	return mMaxDisplayItems == -1 || sourceRow < mMaxDisplayItems;
}

void LimitProxy::setSourceModels(SortFilterProxy *firstList) {
	auto secondList = firstList->sourceModel();
	if (secondList) {
		connect(secondList, &QAbstractItemModel::rowsInserted, this, &LimitProxy::onAdded);
		connect(secondList, &QAbstractItemModel::rowsRemoved, this, &LimitProxy::onRemoved);
		connect(secondList, &QAbstractItemModel::modelReset, this, &LimitProxy::invalidateRowsFilter);
	}
	connect(firstList, &SortFilterProxy::filterTextChanged, this, &LimitProxy::filterTextChanged);
	connect(firstList, &SortFilterProxy::filterTypeChanged, this, &LimitProxy::filterTypeChanged);

	// Restore old values
	auto oldModel = dynamic_cast<SortFilterProxy *>(sourceModel());
	if (oldModel) {
		firstList->setFilterType(oldModel->getFilterType());
		firstList->setFilterText(oldModel->getFilterText());
	}

	QSortFilterProxyModel::setSourceModel(firstList);
}

/*
void LimitProxy::setSourceModels(SortFilterProxy *firstList, QAbstractItemModel *secondList) {
    connect(secondList, &QAbstractItemModel::rowsInserted, this, &LimitProxy::invalidateFilter);
    connect(secondList, &QAbstractItemModel::rowsRemoved, this, &LimitProxy::invalidateFilter);
    connect(firstList, &SortFilterProxy::filterTextChanged, this, &LimitProxy::filterTextChanged);
    setSourceModel(firstList);
}*/

QVariant LimitProxy::getAt(const int &atIndex) const {
	auto modelIndex = index(atIndex, 0);
	return sourceModel()->data(mapToSource(modelIndex), 0);
}

int LimitProxy::getCount() const {
	return rowCount();
}

int LimitProxy::getInitialDisplayItems() const {
	return mInitialDisplayItems;
}

void LimitProxy::setInitialDisplayItems(int initialItems) {
	if (mInitialDisplayItems != initialItems) {
		mInitialDisplayItems = initialItems;
		if (getMaxDisplayItems() <= mInitialDisplayItems) setMaxDisplayItems(initialItems);
		if (getDisplayItemsStep() <= 0) setDisplayItemsStep(initialItems);
		emit initialDisplayItemsChanged();
	}
}

int LimitProxy::getDisplayCount(int listCount, int maxCount) {
	return maxCount >= 0 ? qMin(listCount, maxCount) : listCount;
}

int LimitProxy::getDisplayCount(int listCount) const {
	return getDisplayCount(listCount, mMaxDisplayItems);
}

int LimitProxy::getMaxDisplayItems() const {
	return mMaxDisplayItems;
}
void LimitProxy::setMaxDisplayItems(int maxItems) {
	if (mMaxDisplayItems != maxItems) {
		auto model = sourceModel();
		int modelCount = model ? model->rowCount() : 0;
		int oldCount = getDisplayCount(modelCount);
		mMaxDisplayItems = maxItems;
		if (getInitialDisplayItems() > mMaxDisplayItems) setInitialDisplayItems(maxItems);
		if (getDisplayItemsStep() <= 0) setDisplayItemsStep(maxItems);
		emit maxDisplayItemsChanged();

		if (model && getDisplayCount(modelCount) != oldCount) {
			invalidateFilter();
		}
	}
}

int LimitProxy::getDisplayItemsStep() const {
	return mDisplayItemsStep;
}

void LimitProxy::setDisplayItemsStep(int step) {
	if (step > 0 && mDisplayItemsStep != step) {
		mDisplayItemsStep = step;
		emit displayItemsStepChanged();
	}
}

bool LimitProxy::getHaveMore() const {
	auto model = sourceModel();
	int modelCount = model ? model->rowCount() : 0;
	return getCount() < modelCount;
}

//--------------------------------------------------------------------------------------------------

QString LimitProxy::getFilterText() const {
	return dynamic_cast<SortFilterProxy *>(sourceModel())->getFilterText();
}

void LimitProxy::setFilterText(const QString &filter) {
	dynamic_cast<SortFilterProxy *>(sourceModel())->setFilterText(filter);
}

int LimitProxy::getFilterType() const {
	return dynamic_cast<SortFilterProxy *>(sourceModel())->getFilterType();
}

void LimitProxy::setFilterType(int filter) {
	dynamic_cast<SortFilterProxy *>(sourceModel())->setFilterType(filter);
}

//--------------------------------------------------------------------------------------------------

void LimitProxy::displayMore() {
	int oldCount = rowCount();
	auto model = sourceModel();
	int newCount = getDisplayCount(model ? model->rowCount() : 0, mMaxDisplayItems + mDisplayItemsStep);
	if (newCount != oldCount) {
		setMaxDisplayItems(mMaxDisplayItems + mDisplayItemsStep);
	}
}

void LimitProxy::onAdded() {
	int count = sourceModel()->rowCount();
	if (mMaxDisplayItems > 0 && mMaxDisplayItems <= count) setMaxDisplayItems(mMaxDisplayItems + 1);
}

void LimitProxy::onRemoved() {
	int count = sourceModel()->rowCount();
	if (mMaxDisplayItems > 0 && mMaxDisplayItems <= count) {
		invalidateFilter();
	}
}
