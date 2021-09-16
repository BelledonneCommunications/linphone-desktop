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

void ColorProxyModel::updateLink(const QString& id, const QString& newLink){
	App::getInstance()->getColorListModel()->updateLink(id, newLink);
	invalidate();
}

void ColorProxyModel::changeSort(){
	mSortMode = (mSortMode+1)%3;
	invalidate();
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
	return true;
}

bool ColorProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	ColorListModel * model = static_cast<ColorListModel*>(sourceModel());
	const ColorModel *a = model->data(left).value<ColorModel *>();
	const ColorModel *b = model->data(right).value<ColorModel *>();
	switch(mSortMode){
	case 0 : 
		return model->getLinkIndex(a->getName()) < model->getLinkIndex(b->getName());
	case 1:
		return a->getName() < b->getName();
	case 2:
		return a->getDescription() < b->getDescription();
	default:
		return a->getName() < b->getName();
	}
}
//---------------------------------------------------------------------------------
