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

#ifndef SOUND_PLAYER_MODEL_H_
#define SOUND_PLAYER_MODEL_H_

#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "model/sound-player/SoundPlayerModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"

#include <QMutex>
#include <QObject>
#include <linphone++/linphone.hh>

// =============================================================================

class QTimer;

class SoundPlayerCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString source READ getSource WRITE setSource NOTIFY sourceChanged)
	Q_PROPERTY(QString baseName READ getBaseName NOTIFY sourceChanged)
	Q_PROPERTY(LinphoneEnums::PlaybackState playbackState READ getPlaybackState WRITE setPlaybackState NOTIFY
	               playbackStateChanged)
	Q_PROPERTY(int duration READ getDuration NOTIFY sourceChanged)
	Q_PROPERTY(int position READ getPosition WRITE setPosition NOTIFY positionChanged)
	Q_PROPERTY(bool isRinger MEMBER mIsRinger)
	Q_PROPERTY(QDateTime creationDateTime READ getCreationDateTime NOTIFY sourceChanged)

public:
	static QSharedPointer<SoundPlayerCore> create();
	SoundPlayerCore(QObject *parent = Q_NULLPTR);
	~SoundPlayerCore();
	void setSelf(QSharedPointer<SoundPlayerCore> me);

	int getPosition() const;
	void setPosition(int position);
	bool hasVideo() const; // Call it after playing a video because the detection is not outside this scope.

	int getDuration() const;
	QDateTime getCreationDateTime() const;
	QString getBaseName() const;

	QString getSource() const;
	void setSource(const QString &source);

	LinphoneEnums::PlaybackState getPlaybackState() const;
	void setPlaybackState(LinphoneEnums::PlaybackState playbackState);

signals:
	bool lOpen();
	void lPause();
	bool lPlay();
	bool lRestart();
	void lStop(bool force = false);
	void lSeek(int offset);
	void lRefreshPosition();

	void paused();
	void playing();
	void stopped();
	void errorChanged(QString error);
	void eofReached();

	void sourceChanged(const QString &source);
	void playbackStateChanged(LinphoneEnums::PlaybackState playbackState);
	void positionChanged();

private:
	DECLARE_ABSTRACT_OBJECT

	void buildInternalPlayer(QSharedPointer<SoundPlayerCore> me);

	void handleEof();
	void setError(const QString &message);

	QString mSource;
	LinphoneEnums::PlaybackState mPlaybackState = LinphoneEnums::PlaybackState::StoppedState;
	bool mIsRinger = false;

	bool mHasVideo = false;
	int mPosition = 0;
	int mDuration = 0;
	QString mError;

	bool mForceClose = false;
	QMutex mForceCloseMutex;

	QTimer *mForceCloseTimer = nullptr;

	std::shared_ptr<SoundPlayerModel> mSoundPlayerModel;
	QSharedPointer<SafeConnection<SoundPlayerCore, SoundPlayerModel>> mSoundPlayerModelConnection;
	QSharedPointer<SafeConnection<SoundPlayerCore, CoreModel>> mCoreModelConnection;
	QSharedPointer<SafeConnection<SoundPlayerCore, SettingsModel>> mSettingsModelConnection;
};

#endif // SOUND_PLAYER_MODEL_H_
