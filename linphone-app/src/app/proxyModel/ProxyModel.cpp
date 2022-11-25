/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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

#include "ProxyModel.hpp"

// =============================================================================

using namespace std;

ProxyModel::ProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	mFilterMode = 0;
	sort(0, Qt::DescendingOrder);
}

ProxyModel::ProxyModel (QAbstractItemModel * model, const int& defaultFilterMode, QObject *parent) : QSortFilterProxyModel(parent) {
	mFilterMode = defaultFilterMode;
	setSourceModel(model);
	sort(0, Qt::DescendingOrder);
}

ProxyModel::~ProxyModel(){
	if(mDeleteSourceModel)
		deleteSourceModel();
}

void ProxyModel::deleteSourceModel(){
	auto oldSourceModel = sourceModel();
	if(oldSourceModel) {
		oldSourceModel->deleteLater();
		setSourceModel(nullptr);
	}
}

int ProxyModel::getFilterMode () const {
	return mFilterMode;
}

void ProxyModel::setFilterMode (int filterMode) {
	if (getFilterMode() != filterMode) {
		mFilterMode = filterMode;
		invalidate();
		emit filterModeChanged(filterMode);
	}
}

bool ProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	return true;
}

bool ProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	Q_UNUSED(left)
	Q_UNUSED(right)
	return true;
}

QVariant ProxyModel::getAt(int row){
	QModelIndex sourceIndex = mapToSource(this->index(row, 0));
	return sourceModel()->data(sourceIndex);
}

QAbstractItemModel *ProxyModel::getModel(){
	return sourceModel();
}

void ProxyModel::setModel(QAbstractItemModel * model){
	setSourceModel(model);
	emit modelChanged();
}
	
void ProxyModel::add(std::shared_ptr<QAbstractItemModel> model){
	emit added(model);
}