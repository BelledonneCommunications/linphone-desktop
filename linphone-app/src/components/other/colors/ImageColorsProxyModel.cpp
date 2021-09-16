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
#include "ImageColorsProxyModel.hpp"
#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "ColorListModel.hpp"
#include "ColorModel.hpp"

// =============================================================================

ImageColorsProxyModel::ImageColorsProxyModel (QObject *parent) : QSortFilterProxyModel(parent){
	setSourceModel(App::getInstance()->getColorListModel());
	sort(0);
}

void ImageColorsProxyModel::setImageId(const QString& imageId){
	if(mImageId != imageId){
		mImageId = imageId;
		emit imageIdChanged();
		invalidate();
	}
}

//---------------------------------------------------------------------------------
bool ImageColorsProxyModel::filterAcceptsRow (
		int sourceRow,
		const QModelIndex &sourceParent
		) const {
	Q_UNUSED(sourceRow)
	Q_UNUSED(sourceParent)
	const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
	const ColorModel *model= index.data().value<ColorModel *>();
	return mImageId != "" && model->getLinkedToImage() == mImageId;// Remove linked to image from list
}

bool ImageColorsProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	ColorListModel * model = static_cast<ColorListModel*>(sourceModel());
	const ColorModel *a = model->data(left).value<ColorModel *>();
	const ColorModel *b = model->data(right).value<ColorModel *>();
	
	//return model->getLinkIndex(a->getName()) < model->getLinkIndex(b->getName());
	return a->getName() < b->getName() ;
}
//---------------------------------------------------------------------------------
