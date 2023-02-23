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

#include <QQmlApplicationEngine>
#include <QTimer>

#include "app/App.hpp"
#include "components/core/CoreManager.hpp"

#include "RecorderManager.hpp"
#include "RecorderModel.hpp"

// =============================================================================

RecorderManager::RecorderManager (QObject * parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
}

RecorderManager::~RecorderManager(){
}


bool RecorderManager::haveVocalRecorder() const{
	return mVocalRecorder != nullptr;
}

RecorderModel* RecorderManager::getVocalRecorder(){
	if( !mVocalRecorder) {
		auto core = CoreManager::getInstance()->getCore();
		std::shared_ptr<linphone::RecorderParams> params = core->createRecorderParams();
		params->setFileFormat(linphone::Recorder::FileFormat::Mkv);
		params->setVideoCodec("");
		auto recorder = core->createRecorder(params);
		if(recorder)
			mVocalRecorder = RecorderModel::create(recorder, nullptr);
		emit haveVocalRecorderChanged();
	}
	return mVocalRecorder.get();
}

RecorderModel* RecorderManager::resetVocalRecorder(){
	if(mVocalRecorder)
		clearVocalRecorder();
	return getVocalRecorder();
}

void RecorderManager::clearVocalRecorder(){
	if( mVocalRecorder){
		mVocalRecorder = nullptr;
		emit haveVocalRecorderChanged();
	}
}

//--------------------------------------------------------------------------------------------------------------------------
