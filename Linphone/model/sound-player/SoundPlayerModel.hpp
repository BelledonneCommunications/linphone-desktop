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

#ifndef SOUND_PLAYER_H_
#define SOUND_PLAYER_H_

#include "tool/AbstractObject.hpp"
#include <memory>

#include <QMutex>
#include <QObject>

// =============================================================================

class QTimer;

class SoundPlayerModel : public ::Listener<linphone::Player, linphone::PlayerListener>,
                         public linphone::PlayerListener,
                         public AbstractObject {
	class Handlers;

	Q_OBJECT

public:
	SoundPlayerModel(const std::shared_ptr<linphone::Player> &player, QObject *parent = nullptr);
	~SoundPlayerModel();

	bool open(QString source);
	void pause();
	bool play(QString source);
	void stop(bool force = false);
	void seek(QString source, int offset);

	int getPosition() const;
	bool hasVideo() const; // Call it after playing a video because the detection is not outside this scope.

	int getDuration() const;

	void handleEof();

	void setError(const QString &message);

signals:
	void sourceChanged(const QString &source);

	void paused();
	void open();
	void playing();
	void stopped(bool force);
	void positionChanged(int position);
	void errorChanged(QString error);

	void playbackStateChanged(LinphoneEnums::PlaybackState playbackState);

	void eofReached(const std::shared_ptr<linphone::Player> &player);

private:
	DECLARE_ABSTRACT_OBJECT

	void onEofReached(const std::shared_ptr<linphone::Player> &player);
};

#endif // SOUND_PLAYER_H_
