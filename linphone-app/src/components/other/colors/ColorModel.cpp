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
#include "ColorModel.hpp"

#include <QQmlApplicationEngine>
#include "app/App.hpp"

#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "components/core/CoreManager.hpp"

// =============================================================================

ColorModel::ColorModel (const QString& name, const QColor& color, const QString& description, QObject * parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mName = name;
	setColor(color);
	setDescription(description) ;
}

// -----------------------------------------------------------------------------

QString ColorModel::getName() const{
	return mName;
}

QColor ColorModel::getColor() const{
	return mColor;
}
QString ColorModel::getDescription() const{
	return mDescription;
}


void ColorModel::setColor(const QColor& color){
	if(color != mColor){
		mColor = color;
		emit colorChanged();
	}
}

void ColorModel::setAlpha(const int& alpha){
	mColor.setAlpha(alpha);
	emit colorChanged();
}

void ColorModel::setDescription(const QString& description){
	if(description != mDescription){
		mDescription = description;
		emit descriptionChanged();
	}
}
