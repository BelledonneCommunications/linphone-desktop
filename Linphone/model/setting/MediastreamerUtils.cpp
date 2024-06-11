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

#include <linphone/linphonecore.h>
#include <mediastreamer2/msvolume.h>
#include <mediastreamer2/mssndcard.h>
#include <mediastreamer2/msticker.h>
#include <model/core/CoreModel.hpp>
#include "MediastreamerUtils.hpp"

#include <qlogging.h>

using namespace MediastreamerUtils;

SimpleCaptureGraph::SimpleCaptureGraph(const std::string &capture, const std::string &playback)
	: captureCardId(capture), playbackCardId(playback)
{
	LinphoneCore *ccore = CoreModel::getInstance()->getCore()->cPtr();
	msFactory = linphone_core_get_ms_factory(ccore);

	playbackCard = ms_snd_card_manager_get_card(ms_factory_get_snd_card_manager(msFactory), playbackCardId.c_str());
	if (!playbackCard)
		qWarning("Cannot get playback card from MSFactory with : %s", playbackCardId.c_str());
	captureCard = ms_snd_card_manager_get_card(ms_factory_get_snd_card_manager(msFactory), captureCardId.c_str());
	if (!captureCard)
		qWarning("Cannot get capture card from MSFactory with : %s", captureCardId.c_str());

	if(playbackCard && captureCard)// Assure to initialize when playback and capture are available
		init();
}

SimpleCaptureGraph::~SimpleCaptureGraph()
{
	destroy();
}
static void device_notify_cb(void *user_data, MSFilter *f, unsigned int event, void *eventdata) {
	if (event == MS_FILTER_OUTPUT_FMT_CHANGED) {
		SimpleCaptureGraph * graph = (SimpleCaptureGraph *)user_data;
		int captureRate, playbackRate, captureChannels, playbackChannels;
		ms_filter_call_method(graph->audioCapture,MS_FILTER_GET_SAMPLE_RATE,&captureRate);
		ms_filter_call_method(graph->audioSink,MS_FILTER_GET_SAMPLE_RATE,&playbackRate);
		ms_filter_call_method(graph->audioCapture,MS_FILTER_GET_NCHANNELS,&captureChannels);
		ms_filter_call_method(graph->audioSink,MS_FILTER_GET_NCHANNELS,&playbackChannels);
		
		ms_filter_call_method(graph->resamplerFilter,MS_FILTER_SET_SAMPLE_RATE,&captureRate);
		ms_filter_call_method(graph->resamplerFilter,MS_FILTER_SET_OUTPUT_SAMPLE_RATE,&playbackRate);
		ms_filter_call_method(graph->resamplerFilter,MS_FILTER_SET_NCHANNELS,&captureChannels);
		ms_filter_call_method(graph->resamplerFilter,MS_FILTER_SET_OUTPUT_NCHANNELS,&playbackChannels);
	}
}

void SimpleCaptureGraph::init() {
	if (!audioCapture) {
		audioCapture = ms_snd_card_create_reader(captureCard);
		ms_filter_add_notify_callback(audioCapture, device_notify_cb,this,FALSE);
	}
	if (!audioSink) {
		audioSink = ms_snd_card_create_writer(playbackCard);
		ms_filter_add_notify_callback(audioSink, device_notify_cb,this,FALSE);
	}
	if (!captureVolumeFilter) {
		captureVolumeFilter = ms_factory_create_filter(msFactory, MS_VOLUME_ID);
	}
	if (!playbackVolumeFilter) {
		playbackVolumeFilter = ms_factory_create_filter(msFactory, MS_VOLUME_ID);
	}
	if(!resamplerFilter)
		resamplerFilter = ms_factory_create_filter(msFactory, MS_RESAMPLE_ID);
	int captureRate, playbackRate, captureChannels, playbackChannels;
	ms_filter_call_method(audioCapture,MS_FILTER_GET_SAMPLE_RATE,&captureRate);
	ms_filter_call_method(audioSink,MS_FILTER_GET_SAMPLE_RATE,&playbackRate);
	ms_filter_call_method(audioCapture,MS_FILTER_GET_NCHANNELS,&captureChannels);
	ms_filter_call_method(audioSink,MS_FILTER_GET_NCHANNELS,&playbackChannels);
	
	ms_filter_call_method(resamplerFilter,MS_FILTER_SET_SAMPLE_RATE,&captureRate);
	ms_filter_call_method(resamplerFilter,MS_FILTER_SET_OUTPUT_SAMPLE_RATE,&playbackRate);
	ms_filter_call_method(resamplerFilter,MS_FILTER_SET_NCHANNELS,&captureChannels);
	ms_filter_call_method(resamplerFilter,MS_FILTER_SET_OUTPUT_NCHANNELS,&playbackChannels);

	ms_filter_link(audioCapture, 0, captureVolumeFilter, 0);
	ms_filter_link(captureVolumeFilter, 0, resamplerFilter, 0);
	ms_filter_link(resamplerFilter, 0, playbackVolumeFilter, 0);
	ms_filter_link(playbackVolumeFilter, 0, audioSink, 0);

	//Mute playback
	float muteGain = 0.0f;
	ms_filter_call_method(playbackVolumeFilter, static_cast<unsigned int>(MS_VOLUME_SET_GAIN), &muteGain);
	ticker = ms_ticker_new();
	running = false;

}

void SimpleCaptureGraph::start() {
	if (!running && audioCapture) {
		running = true;
		ms_ticker_attach(ticker, audioCapture);
		
	}
}

void SimpleCaptureGraph::stop() {
	if (running && audioCapture){
		ms_ticker_detach(ticker, audioCapture);
		running = false;
	}
}

void SimpleCaptureGraph::destroy() {
	if (running) {
		stop();
	}
	
	if (audioSink)
		ms_filter_unlink(playbackVolumeFilter, 0, audioSink, 0);
	if (captureVolumeFilter && resamplerFilter)
		ms_filter_unlink(captureVolumeFilter, 0, resamplerFilter, 0);
	if (resamplerFilter && playbackVolumeFilter)
		ms_filter_unlink(resamplerFilter, 0, playbackVolumeFilter, 0);
	if (audioCapture)
		ms_filter_unlink(audioCapture, 0, captureVolumeFilter, 0);
	if (playbackVolumeFilter)
		ms_filter_destroy(playbackVolumeFilter);
	if (captureVolumeFilter)
		ms_filter_destroy(captureVolumeFilter);
	if (resamplerFilter)
		ms_filter_destroy(resamplerFilter);
	if (audioSink)
		ms_filter_destroy(audioSink);
	if (audioCapture)
		ms_filter_destroy(audioCapture);
	if (ticker) {
		ms_ticker_destroy(ticker);// Destroy ticker at the end to avoid conflicts between attached filters
	}
	ticker = nullptr;
	playbackVolumeFilter = nullptr;
	captureVolumeFilter = nullptr;
	resamplerFilter = nullptr;
	audioSink = nullptr;
	audioCapture = nullptr;
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

float MediastreamerUtils::linearToDb(float volume) {
	if (qFuzzyIsNull(volume)) {
		return MS_VOLUME_DB_LOWEST;
	}
	return static_cast<float>(10.0 * log10(volume));
}
