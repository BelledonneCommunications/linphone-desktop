/*
 * Copyright (c) 2024 Belledonne Communications SARL.
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

#include "Proxy.hpp"

Proxy::Proxy(QObject *parent) : QAbstractListModel(parent) {
	connect(this, &Proxy::rowsInserted, this, &Proxy::countChanged);
	connect(this, &Proxy::rowsRemoved, this, &Proxy::countChanged);
}

int Proxy::getCount() const {
	return rowCount();
}

int Proxy::getDisplayCount(int listCount) const {
	return mMaxDisplayItems >= 0 ? qMin(listCount, mMaxDisplayItems) : listCount;
}

bool Proxy::remove(QObject *itemToRemove) {
	return false;
}

void Proxy::clearData() {
}

void Proxy::resetData() {
}

int Proxy::getInitialDisplayItems() const {
	return mInitialDisplayItems;
}

void Proxy::setInitialDisplayItems(int initialItems) {
	if (mInitialDisplayItems != initialItems) {
		mInitialDisplayItems = initialItems;
		if(getMaxDisplayItems() == -1)
			setMaxDisplayItems(initialItems);
		emit initialDisplayItemsChanged();
	}
}

int Proxy::getMaxDisplayItems() const {
	return mMaxDisplayItems;
}
void Proxy::setMaxDisplayItems(int maxItems) {
	if (mMaxDisplayItems != maxItems) {
		mMaxDisplayItems = maxItems;
		if( getInitialDisplayItems() == -1)
			setInitialDisplayItems(maxItems);
		emit maxDisplayItemsChanged();
	}
}

int Proxy::getDisplayItemsStep() const {
	return mDisplayItemsStep;
}

void Proxy::setDisplayItemsStep(int step) {
	if (mDisplayItemsStep != step) {
		mDisplayItemsStep = step;
		emit displayItemsStepChanged();
	}
}
