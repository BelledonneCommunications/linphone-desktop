/*
 * SoundPlayer.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: April 25, 2017
 *      Author: Ronan Abhamon
 */

#include <QTimer>

#include "../../utils/Utils.hpp"
#include "../core/CoreManager.hpp"

#include "SoundPlayer.hpp"

#define FORCE_CLOSE_TIMER_INTERVAL 20

using namespace std;

// =============================================================================

class SoundPlayer::Handlers : public linphone::PlayerListener {
public:
  Handlers (SoundPlayer *soundPlayer) {
    mSoundPlayer = soundPlayer;
  }

private:
  void onEofReached (const shared_ptr<linphone::Player> &) override {
    QMutex &mutex = mSoundPlayer->mForceCloseMutex;

    // Workaround.
    // This callback is called in a standard thread of mediastreamer, not a QThread.
    // Signals, connect functions, timers... are unavailable.
    mutex.lock();
    mSoundPlayer->mForceClose = true;
    mutex.unlock();
  }

  SoundPlayer *mSoundPlayer;
};

// -----------------------------------------------------------------------------

SoundPlayer::SoundPlayer (QObject *parent) : QObject(parent) {
  mForceCloseTimer = new QTimer(this);
  mForceCloseTimer->setInterval(FORCE_CLOSE_TIMER_INTERVAL);

  QObject::connect(mForceCloseTimer, &QTimer::timeout, this, &SoundPlayer::handleEof);

  mHandlers = make_shared<SoundPlayer::Handlers>(this);

  buildInternalPlayer();
}

SoundPlayer::~SoundPlayer () {
  mForceCloseTimer->stop();
  mInternalPlayer->close();
}

// -----------------------------------------------------------------------------

void SoundPlayer::pause () {
  if (mPlaybackState == SoundPlayer::PausedState)
    return;

  if (mInternalPlayer->pause()) {
    setError(QStringLiteral("Unable to pause: `%1`").arg(mSource));
    return;
  }

  mForceCloseTimer->stop();
  mPlaybackState = SoundPlayer::PausedState;

  emit paused();
  emit playbackStateChanged(mPlaybackState);
}

void SoundPlayer::play () {
  if (mPlaybackState == SoundPlayer::PlayingState)
    return;

  if (
    (mPlaybackState == SoundPlayer::StoppedState || mPlaybackState == SoundPlayer::ErrorState) &&
    mInternalPlayer->open(::Utils::appStringToCoreString(mSource))
  ) {
    qWarning() << QStringLiteral("Unable to open: `%1`").arg(mSource);
    return;
  }

  if (mInternalPlayer->start()
  ) {
    setError(QStringLiteral("Unable to play: `%1`").arg(mSource));
    return;
  }

  mForceCloseTimer->start();
  mPlaybackState = SoundPlayer::PlayingState;

  emit playing();
  emit playbackStateChanged(mPlaybackState);
}

void SoundPlayer::stop () {
  stop(false);
}

// -----------------------------------------------------------------------------

void SoundPlayer::seek (int offset) {
  mInternalPlayer->seek(offset);
}

// -----------------------------------------------------------------------------

int SoundPlayer::getPosition () const {
  return mInternalPlayer->getCurrentPosition();
}

// -----------------------------------------------------------------------------

void SoundPlayer::buildInternalPlayer () {
  CoreManager *coreManager = CoreManager::getInstance();
  SettingsModel *settingsModel = coreManager->getSettingsModel();

  mInternalPlayer = coreManager->getCore()->createLocalPlayer(
      ::Utils::appStringToCoreString(settingsModel->getRingerDevice()), "", nullptr
    );
  mInternalPlayer->setListener(mHandlers);

  QObject::connect(settingsModel, &SettingsModel::ringerDeviceChanged, this, [this] {
    rebuildInternalPlayer();
  });
}

void SoundPlayer::rebuildInternalPlayer () {
  stop(true);
  buildInternalPlayer();
}

void SoundPlayer::stop (bool force) {
  if (mPlaybackState == SoundPlayer::StoppedState && !force)
    return;

  mForceCloseTimer->stop();
  mPlaybackState = SoundPlayer::StoppedState;

  mInternalPlayer->close();

  emit stopped();
  emit playbackStateChanged(mPlaybackState);
}

// -----------------------------------------------------------------------------

void SoundPlayer::handleEof () {
  mForceCloseMutex.lock();

  if (mForceClose) {
    mForceClose = false;
    stop();
  }

  mForceCloseMutex.unlock();
}

// -----------------------------------------------------------------------------

void SoundPlayer::setError (const QString &message) {
  qWarning() << message;
  mInternalPlayer->close();

  if (mPlaybackState != SoundPlayer::ErrorState) {
    mPlaybackState = SoundPlayer::ErrorState;
    emit playbackStateChanged(mPlaybackState);
  }
}

// -----------------------------------------------------------------------------

QString SoundPlayer::getSource () const {
  return mSource;
}

void SoundPlayer::setSource (const QString &source) {
  if (source == mSource)
    return;

  stop();
  mSource = source;

  emit sourceChanged(source);
}

// -----------------------------------------------------------------------------

SoundPlayer::PlaybackState SoundPlayer::getPlaybackState () const {
  return mPlaybackState;
}

void SoundPlayer::setPlaybackState (PlaybackState playbackState) {
  switch (playbackState) {
    case PlayingState:
      play();
      break;
    case PausedState:
      pause();
      break;
    case StoppedState:
      stop();
      break;
    case ErrorState:
      break;
  }
}

// -----------------------------------------------------------------------------

int SoundPlayer::getDuration () const {
  return mInternalPlayer->getDuration();
}
