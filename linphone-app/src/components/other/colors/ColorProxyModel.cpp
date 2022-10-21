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
#include "ColorProxyModel.hpp"
#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "ColorListModel.hpp"
#include "ColorModel.hpp"

// =============================================================================

ColorProxyModel::ColorProxyModel (QObject *parent) : QSortFilterProxyModel(parent){
	setSourceModel(App::getInstance()->getColorListModel());
	mSortMode = 0;
	sort(0);
}

int ColorProxyModel::getShowPageIndex()const{
	return mShowPageIndex;
}
void ColorProxyModel::setShowPageIndex(const int& index){
	if(mShowPageIndex != index){
		mShowPageIndex = index;
		emit showPageIndexChanged();
		invalidate();
	}
}

bool ColorProxyModel::getShowAll()const{
	return mShowAll;
}
void ColorProxyModel::setShowAll(const bool& show){
	if(mShowAll != show){
		mShowAll = show;
		emit showAllChanged();
		invalidate();
	}
}

void ColorProxyModel::updateLink(const QString& id, const QString& newLink){
	App::getInstance()->getColorListModel()->updateLink(id, newLink);
	invalidate();
}

void ColorProxyModel::changeSort(){
	mSortMode = (mSortMode+1)%4;
	invalidate();
	emit sortChanged();
}

QString ColorProxyModel::getSortDescription() const{
	switch(mSortMode){
	case 0: return "Link name";
	case 1: return "Name";
	case 2: return "Description";
	case 3: return "Color";
	default:{
		return "Name";
	}
	}
}

bool ColorProxyModel::filterAcceptsRow (
		int sourceRow,
		const QModelIndex &sourceParent
		) const {
	Q_UNUSED(sourceRow)
	Q_UNUSED(sourceParent)
	const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
	const ColorModel *model= index.data().value<ColorModel *>();
	//return model->getLinkedToImage() == "";// Remove linked to image from list
	int currentPage = sourceRow / 50;
	return  mShowAll || currentPage == mShowPageIndex;
}

bool ColorProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	ColorListModel * model = static_cast<ColorListModel*>(sourceModel());
	const ColorModel *a = model->data(left).value<ColorModel *>();
	const ColorModel *b = model->data(right).value<ColorModel *>();
	switch(mSortMode){
	case 0 : 
		return a->getLinkIndex() < b->getLinkIndex();
	case 1:
		return a->getName() < b->getName();
	case 2:
		return a->getDescription() < b->getDescription();
	case 3:
		return a->getColor().name() < b->getColor().name();
	default:
		return a->getName() < b->getName();
	}
}
//---------------------------------------------------------------------------------
