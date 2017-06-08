/*
 * LinphoneUtils.hpp
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
 *  Created on: June 2, 2017
 *      Author: Ronan Abhamon
 */

#ifndef LINPHONE_UTILS_H_
#define LINPHONE_UTILS_H_

#include <linphone++/linphone.hh>
#include <QString>

// =============================================================================

#define VU_MIN (-20.f)
#define VU_MAX (4.f)

namespace LinphoneUtils {
  inline float computeVu (float volume) {
    if (volume < VU_MIN)
      return 0.f;
    if (volume > VU_MAX)
      return 1.f;

    return (volume - VU_MIN) / (VU_MAX - VU_MIN);
  }

  linphone::TransportType stringToTransportType (const QString &transport);
}

#undef VU_MIN
#undef VU_MAX

#endif // ifndef LINPHONE_UTILS_H_
