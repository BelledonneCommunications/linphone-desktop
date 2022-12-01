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

#include <QDebug>

#include "TemporaryFile.hpp"

#include "components/core/CoreManager.hpp"
#include "components/content/ContentModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/Utils.hpp"

// =============================================================================

using namespace std;

TemporaryFile::TemporaryFile (QObject *parent) : QObject(parent) {

}

TemporaryFile::~TemporaryFile () {
	deleteFile();
}

void TemporaryFile::createFileFromContent(ContentModel * contentModel, const bool& exportPlainFile){
	if(contentModel){
		QString filePath;
		if( exportPlainFile || CoreManager::getInstance()->getSettingsModel()->getVfsEncrypted() )
			filePath = Utils::coreStringToAppString(contentModel->getContent()->exportPlainFile());
		bool toDelete = true;
		if(filePath.isEmpty()){
			filePath = contentModel->getFilePath();
			toDelete = false;
		}
		setFilePath(filePath, toDelete);
	}
}

QString TemporaryFile::getFilePath () const{
	return mFilePath;
}
void TemporaryFile::setFilePath(const QString& path, const bool& toDelete){
	if(path != mFilePath) {
		deleteFile();
		mFilePath = path;
		mDeleteFile = toDelete;
		emit filePathChanged();
	}
}

void TemporaryFile::deleteFile(){
	if(mDeleteFile && !mFilePath.isEmpty())
		QFile::remove(mFilePath);
	mFilePath = "";
}


