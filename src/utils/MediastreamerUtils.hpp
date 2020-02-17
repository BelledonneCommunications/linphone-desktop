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

#ifndef MEDIASTREAMER_UTILS_H_
#define MEDIASTREAMER_UTILS_H_

#include <cmath>

#include "mediastreamer2/mssndcard.h"
#include "mediastreamer2/msvolume.h"
#include "mediastreamer2/msfilter.h"
#include "mediastreamer2/msticker.h"
#include <linphone++/linphone.hh>

#include <QtGlobal>

// =============================================================================

namespace MediastreamerUtils {

	inline float computeVu (float volume) {
		constexpr float VuMin = -20.f;
		constexpr float VuMax = 4.f;

		if (volume < VuMin)
			return 0.f;
		if (volume > VuMax)
			return 1.f;

		return (volume - VuMin) / (VuMax - VuMin);
	}

	inline float dbToLinear(float volume) {
        return static_cast<float>(pow(10.0, volume / 10.0));
	}

	inline float linearToDb(float volume) {
        if (qFuzzyIsNull(volume)) {
			return MS_VOLUME_DB_LOWEST;
		}
        return static_cast<float>(10.0 * log10(volume));
	}

	//Simple mediastreamer audio capture graph
	//Used to get current microphone volume in audio settings
	class SimpleCaptureGraph {
	public:
		SimpleCaptureGraph(const std::string &captureCardId, const std::string &playbackCardId);
		~SimpleCaptureGraph();

		void start();
		void stop();

		float getCaptureVolume();

		float getCaptureGain();
		float getPlaybackGain();
		void setCaptureGain(float volume);
		void setPlaybackGain(float volume);

		bool isRunning() const {
			return running;
		}
	protected:
		void init();
		void destroy();

		bool running = false;

		std::string captureCardId;
		std::string playbackCardId;

		MSFilter *audioSink = nullptr;
		MSFilter *audioCapture = nullptr;
		MSFilter *captureVolumeFilter = nullptr;
		MSFilter *playbackVolumeFilter = nullptr;
		MSTicker *ticker = nullptr;
		MSSndCard *playbackCard = nullptr;
		MSSndCard *captureCard = nullptr;
		MSFactory *msFactory = nullptr;
	};

}

#endif // ifndef MEDIASTREAMER_UTILS_H_
