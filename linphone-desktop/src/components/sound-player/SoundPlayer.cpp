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

#include "../../Utils.hpp"
#include "../core/CoreManager.hpp"

#include "SoundPlayer.hpp"

// =============================================================================

SoundPlayer::SoundPlayer (QObject *parent) : QObject(parent) {
  mInternalPlayer = CoreManager::getInstance()->getCore()->createLocalPlayer("", "", nullptr);
}

// -----------------------------------------------------------------------------

void SoundPlayer::pause () {
  if (mPlaybackState == SoundPlayer::PausedState)
    return;

  if (mInternalPlayer->pause()) {
    setError(QStringLiteral("Unable to pause: `%1`").arg(mSource));
    return;
  }

  mPlaybackState = SoundPlayer::PausedState;

  emit paused();
  emit playbackStateChanged(mPlaybackState);
}

void SoundPlayer::play () {
  if (mPlaybackState == SoundPlayer::PlayingState)
    return;

  if (
    (mPlaybackState == SoundPlayer::StoppedState || mPlaybackState == SoundPlayer::ErrorState) &&
    mInternalPlayer->open(::Utils::qStringToLinphoneString(mSource))
  ) {
    qWarning() << QStringLiteral("Unable to open: `%1`").arg(mSource);
    return;
  }

  if (mInternalPlayer->start()
  ) {
    setError(QStringLiteral("Unable to play: `%1`").arg(mSource));
    return;
  }

  mPlaybackState = SoundPlayer::PlayingState;

  emit playing();
  emit playbackStateChanged(mPlaybackState);
}

void SoundPlayer::stop () {
  if (mPlaybackState == SoundPlayer::StoppedState)
    return;

  mInternalPlayer->close();
  mPlaybackState = SoundPlayer::StoppedState;

  emit stopped();
  emit playbackStateChanged(mPlaybackState);
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
