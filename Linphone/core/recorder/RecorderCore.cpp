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

#include <QFile>

#include "core/App.hpp"
#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "tool/Utils.hpp"

#include "RecorderCore.hpp"

DEFINE_ABSTRACT_OBJECT(RecorderCore)

// =============================================================================

QSharedPointer<RecorderCore> RecorderCore::create(QObject *parent) {
	auto sharedPointer = QSharedPointer<RecorderCore>(new RecorderCore(), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

RecorderCore::RecorderCore(QObject *parent) : QObject(parent) {
	App::getInstance()->mEngine->setObjectOwnership(
	    this, QQmlEngine::CppOwnership); // Avoid QML to destroy it when passing by Q_INVOKABLE
}

RecorderCore::~RecorderCore() {
}

void RecorderCore::buildRecorder(QSharedPointer<RecorderCore> me) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	std::shared_ptr<linphone::RecorderParams> params = core->createRecorderParams();
	params->setFileFormat(linphone::MediaFileFormat::Mkv);
	params->setVideoCodec("");
	auto recorder = core->createRecorder(params);
	if (recorder) {
		mDuration = recorder->getDuration();
		mCaptureVolume = recorder->getCaptureVolume();
		if (mRecorderModelConnection) mRecorderModelConnection->disconnect();
		mRecorderModel = Utils::makeQObject_ptr<RecorderModel>(recorder);
		mRecorderModelConnection = SafeConnection<RecorderCore, RecorderModel>::create(me, mRecorderModel);
		mRecorderModelConnection->makeConnectToCore(&RecorderCore::lStart, [this] {
			mRecorderModelConnection->invokeToModel([this] { mRecorderModel->start(); });
		});
		mRecorderModelConnection->makeConnectToCore(&RecorderCore::lPause, [this] {
			mRecorderModelConnection->invokeToModel([this] { mRecorderModel->pause(); });
		});
		mRecorderModelConnection->makeConnectToCore(&RecorderCore::lStop, [this] {
			mRecorderModelConnection->invokeToModel([this] { mRecorderModel->stop(); });
		});
		mRecorderModelConnection->makeConnectToCore(&RecorderCore::lRefresh, [this] {
			mRecorderModelConnection->invokeToModel([this] {
				auto duration = mRecorderModel->getDuration();
				auto volume = mRecorderModel->getCaptureVolume();
				mRecorderModelConnection->invokeToModel([this, duration, volume] {
					setDuration(duration);
					setCaptureVolume(volume);
				});
			});
		});
		mRecorderModelConnection->makeConnectToModel(&RecorderModel::stateChanged, [this] {
			auto state = LinphoneEnums::fromLinphone(mRecorderModel->getState());
			mRecorderModelConnection->invokeToCore([this, state] { setState(state); });
		});
		mRecorderModelConnection->makeConnectToModel(&RecorderModel::fileChanged, [this] {
			auto file = mRecorderModel->getFile();
			mRecorderModelConnection->invokeToCore([this, file] { setFile(file); });
		});
		mRecorderModelConnection->makeConnectToModel(&RecorderModel::errorChanged, [this](QString error) {
			mRecorderModelConnection->invokeToCore([this, error] { emit errorChanged(error); });
		});
		emit ready();
	}
}

void RecorderCore::setSelf(QSharedPointer<RecorderCore> me) {
	auto coreModel = CoreModel::getInstance();

	mCoreModelConnection = SafeConnection<RecorderCore, CoreModel>::create(me, coreModel);
	mCoreModelConnection->invokeToModel([this, me, coreModel] { buildRecorder(me); });
}

void RecorderCore::setCaptureVolume(float volume) {
	if (mCaptureVolume != volume) {
		mCaptureVolume = volume;
		emit captureVolumeChanged();
	}
}

int RecorderCore::getDuration() const {
	return mDuration;
}

void RecorderCore::setDuration(int duration) {
	if (mDuration != duration) {
		mDuration = duration;
		emit durationChanged();
	}
}

float RecorderCore::getCaptureVolume() const {
	return mCaptureVolume;
}

LinphoneEnums::RecorderState RecorderCore::getState() const {
	return mState;
}

void RecorderCore::setState(LinphoneEnums::RecorderState state) {
	if (mState != state) {
		mState = state;
		emit stateChanged(state);
	}
}

QString RecorderCore::getFile() const {
	return mFile;
}

void RecorderCore::setFile(QString file) {
	if (mFile != file) {
		mFile = file;
		emit fileChanged();
	}
}

const std::shared_ptr<RecorderModel> &RecorderCore::getModel() const {
	return mRecorderModel;
}
