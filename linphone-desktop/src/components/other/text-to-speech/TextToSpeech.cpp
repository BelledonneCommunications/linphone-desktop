/*
 * TextToSpeech.cpp
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

#ifdef TEXTTOSPEECH_ENABLED
  #include <QTextToSpeech>
#endif // ifdef TEXTTOSPEECH_ENABLED

#include "TextToSpeech.hpp"

// =============================================================================

#ifdef TEXTTOSPEECH_ENABLED
  TextToSpeech::TextToSpeech (QObject *parent) : QObject(parent) {
    mQtTextToSpeech = new QTextToSpeech(this);
  }

  void TextToSpeech::say (const QString &text) {
    mQtTextToSpeech->say(text);
  }

  bool TextToSpeech::available () const {
    return true;
  }

#else
  TextToSpeech::TextToSpeech (QObject *parent) : QObject(parent) {}

  void TextToSpeech::say (const QString &) {}

  bool TextToSpeech::available () const {
    return false;
  }

#endif // ifdef TEXTTOSPEECH_ENABLED
