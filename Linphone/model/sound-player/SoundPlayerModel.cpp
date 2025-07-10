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

#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"

#include "SoundPlayerModel.hpp"

DEFINE_ABSTRACT_OBJECT(SoundPlayerModel)

// =============================================================================

using namespace std;

namespace {
int ForceCloseTimerInterval = 20;
}

class SoundPlayerModel::Handlers : public linphone::PlayerListener {
public:
	Handlers(SoundPlayerModel *soundPlayerModel) {
		mSoundPlayerModel = soundPlayerModel;
	}

private:
	SoundPlayerModel *mSoundPlayerModel;
};

// -----------------------------------------------------------------------------

SoundPlayerModel::SoundPlayerModel(const std::shared_ptr<linphone::Player> &player, QObject *parent)
    : ::Listener<linphone::Player, linphone::PlayerListener>(player, parent) {
	mustBeInLinphoneThread(getClassName());
}

SoundPlayerModel::~SoundPlayerModel() {
	if (mMonitor) mMonitor->close();
}

// -----------------------------------------------------------------------------

void SoundPlayerModel::pause() {
	if (mMonitor->pause()) {
		//: Unable to pause
		emit errorChanged("sound_player_pause_error");
		emit playbackStateChanged(LinphoneEnums::PlaybackState::ErrorState);
		return;
	}
	emit paused();
	emit playbackStateChanged(LinphoneEnums::PlaybackState::PausedState);
}

bool SoundPlayerModel::open(QString source) {
	mMonitor->open(Utils::appStringToCoreString(source));
	emit open();
	return true;
	// }
	// return false;
}

bool SoundPlayerModel::play(QString source, bool fromStart) {
	if (source == "") return false;
	if (fromStart) stop();
	if (!open(source)) {
		qWarning() << QStringLiteral("Unable to open: `%1`").arg(source);
		//: Unable to open: `%1`
		emit errorChanged(QString("sound_player_open_error").arg(source));
		return false;
	}
	if (mMonitor->start()) {
		//: Unable to play %1
		emit errorChanged(QString("sound_player_play_error").arg(source));
		emit playbackStateChanged(LinphoneEnums::PlaybackState::ErrorState);
		return false;
	}
	emit playing();
	emit playbackStateChanged(LinphoneEnums::PlaybackState::PlayingState);
	return true;
}

// -----------------------------------------------------------------------------

void SoundPlayerModel::seek(QString source, int offset) {
	if (!open(source)) {
		qWarning() << QStringLiteral("Unable to open: `%1`").arg(source);
		//: Unable to open: `%1`
		emit errorChanged(QString("sound_player_open_error").arg(source));
		return;
	}
	mMonitor->seek(offset);
	emit positionChanged(mMonitor->getCurrentPosition());
}

// -----------------------------------------------------------------------------

int SoundPlayerModel::getPosition() const {
	return mMonitor->getCurrentPosition();
}

bool SoundPlayerModel::hasVideo() const {
	return mMonitor->getIsVideoAvailable();
}

void SoundPlayerModel::stop(bool force) {
	if (mMonitor) mMonitor->close();
	emit stopped(force);
	emit playbackStateChanged(LinphoneEnums::PlaybackState::StoppedState);
}

// -----------------------------------------------------------------------------

int SoundPlayerModel::getDuration() const {
	return mMonitor->getDuration();
}

/*------------------------------------------------------------------*/

void SoundPlayerModel::onEofReached(const shared_ptr<linphone::Player> &player) {
	if (player == mMonitor) emit eofReached(player);
}