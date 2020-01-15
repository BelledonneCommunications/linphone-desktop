/*
 * MediastreamerUtils.cpp
 * Copyright (C) 2017-2019  Belledonne Communications, Grenoble, France
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
 *  Created on: Nov 6, 2019
 *  Author: Nicolas Michon
 */

#include "linphone/linphonecore.h"
#include "mediastreamer2/msvolume.h"
#include "mediastreamer2/mssndcard.h"
#include "mediastreamer2/msticker.h"
#include "components/core/CoreManager.hpp"
#include "MediastreamerUtils.hpp"

using namespace MediastreamerUtils;

SimpleCaptureGraph::SimpleCaptureGraph(const std::string &capture, const std::string &playback)
	: captureCardId(capture), playbackCardId(playback)
{
	LinphoneCore *ccore = CoreManager::getInstance()->getCore()->cPtr();
	msFactory = linphone_core_get_ms_factory(ccore);

	playbackCard = ms_snd_card_manager_get_card(ms_factory_get_snd_card_manager(msFactory), playbackCardId.c_str());
	captureCard = ms_snd_card_manager_get_card(ms_factory_get_snd_card_manager(msFactory), captureCardId.c_str());

	init();
}

SimpleCaptureGraph::~SimpleCaptureGraph()
{
	destroy();
}

void SimpleCaptureGraph::init() {
	if (!audioCapture) {
		audioCapture = ms_snd_card_create_reader(captureCard);
	}
	if (!audioSink) {
		audioSink = ms_snd_card_create_writer(playbackCard);
	}
	if (!captureVolumeFilter) {
		captureVolumeFilter = ms_factory_create_filter(msFactory, MS_VOLUME_ID);
	}
	if (!playbackVolumeFilter) {
		playbackVolumeFilter = ms_factory_create_filter(msFactory, MS_VOLUME_ID);
	}

	ms_filter_link(audioCapture, 0, captureVolumeFilter, 0);
	ms_filter_link(captureVolumeFilter, 0, playbackVolumeFilter, 0);
	ms_filter_link(playbackVolumeFilter, 0, audioSink, 0);

	//Mute playback
	float muteGain = 0.0f;
	ms_filter_call_method(playbackVolumeFilter, MS_VOLUME_SET_GAIN, &muteGain);

	ticker = ms_ticker_new();
	running = false;
}

void SimpleCaptureGraph::start() {
	if (!running) {
		ms_ticker_attach(ticker, audioCapture);
		running = true;
	}
}

void SimpleCaptureGraph::stop() {
	if (running) {
		ms_ticker_detach(ticker, audioCapture);
		running = false;
	}
}

void SimpleCaptureGraph::destroy() {
	if (running) {
		stop();
	}
	ms_ticker_destroy(ticker);
	ms_filter_unlink(audioCapture, 0, captureVolumeFilter, 0);
	ms_filter_unlink(captureVolumeFilter, 0, playbackVolumeFilter, 0);
	ms_filter_unlink(playbackVolumeFilter, 0, audioSink, 0);

	ms_free(audioCapture);
	ms_free(captureVolumeFilter);
	ms_free(audioSink);
	ms_free(playbackVolumeFilter);
}

float SimpleCaptureGraph::getCaptureGain() {
	float gain = 0.0f;

	if (isRunning() && audioCapture) {
		ms_filter_call_method(audioCapture, MS_AUDIO_CAPTURE_GET_VOLUME_GAIN, &gain);
	}
	return gain;
}

void SimpleCaptureGraph::setCaptureGain(float gain) {
	if (isRunning() && audioCapture) {
		ms_filter_call_method(audioCapture, MS_AUDIO_CAPTURE_SET_VOLUME_GAIN, &gain);
	}
}

float SimpleCaptureGraph::getPlaybackGain() {
	float gain = 0.0f;
	if (isRunning() && audioSink) {
		ms_filter_call_method(audioSink, MS_AUDIO_PLAYBACK_GET_VOLUME_GAIN, &gain);
	}
	return gain;
}

void SimpleCaptureGraph::setPlaybackGain(float gain) {
	if (isRunning() && audioSink) {
		ms_filter_call_method(audioSink, MS_AUDIO_PLAYBACK_SET_VOLUME_GAIN, &gain);
	}
}

float SimpleCaptureGraph::getCaptureVolume() {
	float vol = 0;

	if (captureVolumeFilter) {
		ms_filter_call_method(captureVolumeFilter, MS_VOLUME_GET, &vol);
		vol = MediastreamerUtils::dbToLinear(vol);
	}
	return vol;
}
