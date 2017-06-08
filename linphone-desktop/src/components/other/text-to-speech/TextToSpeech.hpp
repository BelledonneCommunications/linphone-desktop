/*
 * TextToSpeech.hpp
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
 *  Created on: May 31, 2017
 *      Author: Ronan Abhamon
 */

#ifndef TEXT_TO_SPEECH_H_
#define TEXT_TO_SPEECH_H_

#include <QObject>

// =============================================================================

class QTextToSpeech;

class TextToSpeech : public QObject {
  Q_OBJECT;

  Q_PROPERTY(bool available READ available CONSTANT);

public:
  TextToSpeech (QObject *parent = Q_NULLPTR);
  ~TextToSpeech () = default;

  Q_INVOKABLE void say (const QString &text);

private:
  bool available () const;

  QTextToSpeech *mQtTextToSpeech = nullptr;
};

#endif // ifndef TEXT_TO_SPEECH_H_
