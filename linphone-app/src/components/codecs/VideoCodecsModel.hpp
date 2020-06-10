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

#ifndef VIDEO_CODECS_MODEL_H_
#define VIDEO_CODECS_MODEL_H_

#include "AbstractCodecsModel.hpp"

// =============================================================================

class VideoCodecsModel : public AbstractCodecsModel {
  Q_OBJECT;

public:
  VideoCodecsModel (QObject *parent = Q_NULLPTR);

  static void updateCodecs ();
  static void downloadUpdatableCodecs (QObject *parent);

private:
  void updateCodecs (std::list<std::shared_ptr<linphone::PayloadType>> &codecs) override;

  void load ();
  void reload () override;
};

#endif // VIDEO_CODECS_MODEL_H_
