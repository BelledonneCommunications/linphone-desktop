/*
 * LinphoneUtils.hpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
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
 *  Created on: June 2, 2017
 *      Author: Ronan Abhamon
 */

#ifndef LINPHONE_UTILS_H_
#define LINPHONE_UTILS_H_

#include <linphone++/linphone.hh>

// =============================================================================

class QString;

namespace LinphoneUtils {
  inline float computeVu (float volume) {
    constexpr float VuMin = -20.f;
    constexpr float VuMax = 4.f;

    if (volume < VuMin)
      return 0.f;
    if (volume > VuMax)
      return 1.f;

    return (volume - VuMin) / (VuMax - VuMin);
  }

  linphone::TransportType stringToTransportType (const QString &transport);

  static constexpr char WindowIconPath[] = ":/assets/images/app_logo.svg";
}

#endif // ifndef LINPHONE_UTILS_H_
