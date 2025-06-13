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

#include <QTimer>
#include <QtDebug>

#include "core/App.hpp"
#include "core/setting/SettingsCore.hpp"
#include "tool/Utils.hpp"

#include "SoundPlayerCore.hpp"

DEFINE_ABSTRACT_OBJECT(SoundPlayerCore)

// -----------------------------------------------------------------------------

QSharedPointer<SoundPlayerCore> SoundPlayerCore::create() {
	auto sharedPointer = QSharedPointer<SoundPlayerCore>(new SoundPlayerCore(), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

SoundPlayerCore::SoundPlayerCore(QObject *parent) {
	// connect(mForceCloseTimer, &QTimer::timeout, this, &SoundPlayerCore::handleEof);
}

SoundPlayerCore::~SoundPlayerCore() {
	// mForceCloseTimer->stop();
}

void SoundPlayerCore::setSelf(QSharedPointer<SoundPlayerCore> me) {
	auto settingsModel = SettingsModel::getInstance();
	auto coreModel = CoreModel::getInstance();

	mCoreModelConnection = SafeConnection<SoundPlayerCore, CoreModel>::create(me, coreModel);
	mSettingsModelConnection = SafeConnection<SoundPlayerCore, SettingsModel>::create(me, settingsModel);
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::ringerDeviceChanged, [this, me] {
		if (mSoundPlayerModel) mSoundPlayerModel->stop(true);
		else mSettingsModelConnection->invokeToCore([this, me] { buildInternalPlayer(me); });
	});

	mCoreModelConnection->invokeToModel([this, me, settingsModel, coreModel] { buildInternalPlayer(me); });
	// mCoreModelConnection->makeConnectToCore(&SoundPlayerCore::sourceChanged, [this, me] {
	// 	mCoreModelConnection->invokeToModel([this, me] { buildInternalPlayer(me); });
	// });
}

// -----------------------------------------------------------------------------

void SoundPlayerCore::buildInternalPlayer(QSharedPointer<SoundPlayerCore> me) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto coreModel = CoreModel::getInstance();
	auto settingsModel = SettingsModel::getInstance();

	if (mSoundPlayerModelConnection) mSoundPlayerModelConnection->disconnect();

	auto player = coreModel->getCore()->createLocalPlayer(
	    Utils::appStringToCoreString(mIsRinger ? settingsModel->getRingerDevice()["display_name"].toString()
	                                           : settingsModel->getPlaybackDevice()["display_name"].toString()),
	    "", nullptr);

	mHasVideo = player->getIsVideoAvailable();
	mDuration = player->getDuration();

	mSoundPlayerModel = Utils::makeQObject_ptr<SoundPlayerModel>(player);
	mSoundPlayerModel->setSelf(mSoundPlayerModel);
	mSoundPlayerModelConnection = SafeConnection<SoundPlayerCore, SoundPlayerModel>::create(me, mSoundPlayerModel);
	mSoundPlayerModelConnection->makeConnectToCore(&SoundPlayerCore::lStop, [this](bool force) {
		mSoundPlayerModelConnection->invokeToModel([this, force] {
			if (mPlaybackState == LinphoneEnums::PlaybackState::StoppedState && !force) return;
			mSoundPlayerModel->stop(force);
		});
	});
	mSoundPlayerModelConnection->makeConnectToModel(&SoundPlayerModel::stopped, [this, me](bool force) {
		if (force) buildInternalPlayer(me);
	});
	mSoundPlayerModelConnection->makeConnectToCore(&SoundPlayerCore::lPause, [this]() {
		mSoundPlayerModelConnection->invokeToModel([this] { mSoundPlayerModel->pause(); });
	});
	mSoundPlayerModelConnection->makeConnectToModel(
	    &SoundPlayerModel::playbackStateChanged, [this](LinphoneEnums::PlaybackState state) {
		    mSoundPlayerModelConnection->invokeToCore([this, state] { setPlaybackState(state); });
	    });
	mSoundPlayerModelConnection->makeConnectToCore(&SoundPlayerCore::lOpen, [this]() {
		mSoundPlayerModelConnection->invokeToModel([this] { mSoundPlayerModel->open(mSource); });
	});
	mSoundPlayerModelConnection->makeConnectToCore(&SoundPlayerCore::lPlay, [this]() {
		mSoundPlayerModelConnection->invokeToModel([this] { mSoundPlayerModel->play(mSource); });
	});
	mSoundPlayerModelConnection->makeConnectToCore(&SoundPlayerCore::lSeek, [this](int offset) {
		mSoundPlayerModelConnection->invokeToModel([this, offset] { mSoundPlayerModel->seek(mSource, offset); });
	});
	mSoundPlayerModelConnection->makeConnectToModel(&SoundPlayerModel::positionChanged, [this](int pos) {
		mSoundPlayerModelConnection->invokeToCore([this, pos] { setPosition(pos); });
	});
	mSoundPlayerModelConnection->makeConnectToCore(&SoundPlayerCore::lRefreshPosition, [this]() {
		mSoundPlayerModelConnection->invokeToModel([this] {
			auto pos = mSoundPlayerModel->getPosition();
			mSoundPlayerModelConnection->invokeToModel([this, pos] { setPosition(pos); });
		});
	});
	mSoundPlayerModelConnection->makeConnectToModel(&SoundPlayerModel::eofReached,
	                                                [this](const std::shared_ptr<linphone::Player> &player) {
		                                                mSoundPlayerModelConnection->invokeToCore([this] {
			                                                mForceClose = true;
			                                                handleEof();
		                                                });
	                                                });
	mSoundPlayerModelConnection->makeConnectToModel(&SoundPlayerModel::errorChanged, [this](QString error) {
		mSoundPlayerModelConnection->invokeToCore([this, error] { setError(error); });
	});
}

// -----------------------------------------------------------------------------

int SoundPlayerCore::getPosition() const {
	return mPosition;
}

void SoundPlayerCore::setPosition(int position) {
	if (mPosition != position) {
		mPosition = position;
		emit positionChanged();
	}
}

bool SoundPlayerCore::hasVideo() const {
	return mHasVideo;
}

void SoundPlayerCore::handleEof() {
	if (mForceClose) {
		mForceClose = false;
		lStop();
	}
}

void SoundPlayerCore::setError(const QString &message) {
	qWarning() << message;
	mError = message;
	emit errorChanged(message);
}

QString SoundPlayerCore::getSource() const {
	return mSource;
}

void SoundPlayerCore::setSource(const QString &source) {
	if (source == mSource) return;

	lStop(true);
	mSource = source;

	emit sourceChanged(source);
}

LinphoneEnums::PlaybackState SoundPlayerCore::getPlaybackState() const {
	return mPlaybackState;
}

void SoundPlayerCore::setPlaybackState(LinphoneEnums::PlaybackState playbackState) {
	if (mPlaybackState != playbackState) {
		mPlaybackState = playbackState;
		emit playbackStateChanged(playbackState);
	}
	// switch (playbackState) {
	// 	case PlayingState:
	// 		lPlay();
	// 		break;
	// 	case PausedState:
	// 		lPause();
	// 		break;
	// 	case StoppedState:
	// 		lStop();
	// 		break;
	// 	case ErrorState:
	// 		break;
	// }
}

// -----------------------------------------------------------------------------

int SoundPlayerCore::getDuration() const {
	return mDuration;
}

QDateTime SoundPlayerCore::getCreationDateTime() const {
	QFileInfo fileInfo(mSource);
	QDateTime creationDate = fileInfo.birthTime();
	return creationDate.isValid() ? creationDate : fileInfo.lastModified();
}

QString SoundPlayerCore::getBaseName() const {
	return QFileInfo(mSource).baseName();
}