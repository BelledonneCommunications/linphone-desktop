/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include "EmojisSettingsModel.hpp"

#include <QSettings>

// =============================================================================

EmojisSettingsModel::EmojisSettingsModel (QObject *parent) : QObject(parent) {
}

EmojisSettingsModel::~EmojisSettingsModel() {
}

void EmojisSettingsModel::addLastUsed(const int& code){
	QList<int> lastFavorites = getLastUseds();
	int index = lastFavorites.indexOf(code);
	if(index >=0)
		lastFavorites.swapItemsAt(index, lastFavorites.size()-1);
	else {
		if(lastFavorites.size() > mMaxLastUseds){
			lastFavorites.pop_front();
		}
		lastFavorites.push_back(code);
	}
	setLastUseds(lastFavorites);
}

void EmojisSettingsModel::clear(){
	QSettings settings;
	settings.remove("emojis/lastUseds");
	emit lastUsedsChanged();
}

QList<int> EmojisSettingsModel::getLastUseds() const{
	QList<int> favorites;
	QSettings settings;
	settings.beginGroup("emojis");
	int size = settings.beginReadArray("lastUseds");
	for (int i = 0; i < size; ++i) {
		settings.setArrayIndex(i);
		favorites.push_back(settings.value("code").toInt());
	}
	settings.endArray();
	settings.endGroup();
	return favorites;
}

void EmojisSettingsModel::setLastUseds(QList<int> lastUsedCodes){
	QSettings settings;
	settings.remove("emojis/lastUseds");
	settings.beginGroup("emojis");
	settings.beginWriteArray("lastUseds");
	for(int i = 0 ; i < lastUsedCodes.size() ; ++i){
		settings.setArrayIndex(i);
		settings.setValue("code", lastUsedCodes[i]);
	}
	settings.endArray();
	settings.endGroup();
	emit lastUsedsChanged();
}