/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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

#include "FileMediaModel.hpp"

#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "components/call/CallModel.hpp"
#include "components/recorder/RecorderModel.hpp"
#include "components/sound-player/SoundPlayer.hpp"


// =============================================================================

FileMediaModel::FileMediaModel (const QString& path, QObject * parent) :mFileInfo(path), QObject(parent) {
	if(path.isEmpty()) return;
	init();
}

FileMediaModel::FileMediaModel (const QFileInfo& fileInfo, QObject * parent) :mFileInfo(fileInfo), QObject(parent) {
	init();
}

FileMediaModel::~FileMediaModel(){
}

QSharedPointer<FileMediaModel> FileMediaModel::create(const QString& path){
	return FileMediaModel::create(QFileInfo(path));
}

QSharedPointer<FileMediaModel> FileMediaModel::create(const QFileInfo& fileInfo){
	auto model = QSharedPointer<FileMediaModel>::create(fileInfo);
	return model;
}

void FileMediaModel::init(){
	QString baseName = getBaseName();
	SoundPlayer soundPlayer;
	soundPlayer.setSource(mFileInfo.absoluteFilePath());
	if(soundPlayer.open()){
		mDuration = soundPlayer.getDuration();
		if(CallModel::splitSavedFilename(baseName).size() > 1)
			mType = IS_CALL_RECORD;
		else if( RecorderModel::splitSavedFilename(baseName).size() > 1)
			mType = IS_VOICE_RECORD;
		else
			mType = IS_PLAYABLE;
	}else if(CallModel::splitSavedFilename(baseName).size() > 1)
		mType = IS_SNAPSHOT;
	else
		mType = IS_UNKNOWN;
}
// -----------------------------------------------------------------------------

QString FileMediaModel::getBaseName() const{
	return mFileInfo.baseName();
}

QString FileMediaModel::getFilePath() const{
	return mFileInfo.absoluteFilePath();
}

int FileMediaModel::getDuration() const{
	return mDuration;
}

FileMediaModel::FILE_TYPE FileMediaModel::getType() const{
	return mType;
}

QString FileMediaModel::getFrom()const{
	QString baseName = getBaseName();
	switch(mType){
		case IS_CALL_RECORD: case IS_SNAPSHOT:
			return CallModel::getFromSavedFilename(baseName);
		break;
		case IS_VOICE_RECORD:
			return "";
		break;
		default:{
			return "";
		}
	}
}

QString FileMediaModel::getTo()const{
	QString baseName = getBaseName();
	switch(mType){
		case IS_CALL_RECORD: case IS_SNAPSHOT:
			return CallModel::getToSavedFilename(baseName);
		break;
		case IS_VOICE_RECORD:
			return "";
		break;
		default:{
			return "";
		}
	}
}

QDateTime FileMediaModel::getCreationDateTime() const{
	QString baseName;
	switch(mType){
		case IS_CALL_RECORD: case IS_SNAPSHOT:
			baseName = getBaseName();
			return CallModel::getDateTimeSavedFilename(baseName);
		break;
		case IS_VOICE_RECORD:
			baseName = getBaseName();
			return RecorderModel::getDateTimeSavedFilename(baseName);
		break;
		default:{
			QDateTime creationDate = mFileInfo.birthTime();
			return creationDate.isValid() ? creationDate : mFileInfo.lastModified();
		}
	}
}

QStringList FileMediaModel::getParsedBaseName() const{
	QString baseName = getBaseName();
	switch(mType){
		case IS_CALL_RECORD: case IS_SNAPSHOT:
			return CallModel::splitSavedFilename(baseName);
		break;
		case IS_VOICE_RECORD:
			return RecorderModel::splitSavedFilename(baseName);
		break;
		default:{
			return QStringList(baseName);
		}
	}
}
