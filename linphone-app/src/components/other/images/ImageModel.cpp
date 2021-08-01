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
#include "ImageModel.hpp"

#include <QQmlApplicationEngine>
#include "app/App.hpp"

#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "components/core/CoreManager.hpp"

// =============================================================================

ImageModel::ImageModel (const QString& id, const QString& path, const QString& description, QObject * parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mId = id;
	//setPath(path);
	mPath = path;
	setDescription(description) ;
}

// -----------------------------------------------------------------------------

QString ImageModel::getId() const{
	return mId;
}

QString ImageModel::getPath() const{
	return mPath;
}
QString ImageModel::getDescription() const{
	return mDescription;
}


void ImageModel::setPath(const QString& data){
	if(data != mPath){
		mPath = data;
		emit pathChanged();
		QString old = mId;
		mId="";// Force change
		emit idChanged();
		mId=old;
		emit idChanged();
	}
}

void ImageModel::setDescription(const QString& data){
	if(data != mDescription){
		mDescription = data;
		emit descriptionChanged();
	}
}

void ImageModel::setUrl(const QUrl& url){
	setPath(url.toString(QUrl::RemoveScheme));
}
