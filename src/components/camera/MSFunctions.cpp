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

#include "MSFunctions.hpp"

// Do not include this header before `QOpenGLFunctions`!!!
#include <mediastreamer2/msogl_functions.h>

// =============================================================================

MSFunctions *MSFunctions::mInstance;

// -----------------------------------------------------------------------------

MSFunctions::MSFunctions () {
  OpenGlFunctions *f = mFunctions = new OpenGlFunctions();

  f->glActiveTexture = qtResolveGlActiveTexture;
  f->glAttachShader = qtResolveGlAttachShader;
  f->glBindAttribLocation = qtResolveGlBindAttribLocation;
  f->glBindTexture = qtResolveGlBindTexture;
  f->glClear = qtResolveGlClear;
  f->glClearColor = qtResolveGlClearColor;
  f->glCompileShader = qtResolveGlCompileShader;
  f->glCreateProgram = qtResolveGlCreateProgram;
  f->glCreateShader = qtResolveGlCreateShader;
  f->glDeleteProgram = qtResolveGlDeleteProgram;
  f->glDeleteShader = qtResolveGlDeleteShader;
  f->glDeleteTextures = qtResolveGlDeleteTextures;
  f->glDisable = qtResolveGlDisable;
  f->glDrawArrays = qtResolveGlDrawArrays;
  f->glEnableVertexAttribArray = qtResolveGlEnableVertexAttribArray;
  f->glGenTextures = qtResolveGlGenTextures;
  f->glGetError = qtResolveGlGetError;
  f->glGetProgramInfoLog = qtResolveGlGetProgramInfoLog;
  f->glGetProgramiv = qtResolveGlGetProgramiv;
  f->glGetShaderInfoLog = qtResolveGlGetShaderInfoLog;
  f->glGetShaderiv = qtResolveGlGetShaderiv;
  f->glGetString = qtResolveGlGetString;
  f->glGetUniformLocation = qtResolveGlGetUniformLocation;
  f->glLinkProgram = qtResolveGlLinkProgram;
  f->glPixelStorei = qtResolveGlPixelStorei;
  f->glShaderSource = qtResolveGlShaderSource;
  f->glTexImage2D = qtResolveGlTexImage2D;
  f->glTexParameteri = qtResolveGlTexParameteri;
  f->glTexSubImage2D = qtResolveGlTexSubImage2D;
  f->glUniform1f = qtResolveGlUniform1f;
  f->glUniform1i = qtResolveGlUniform1i;
  f->glUniformMatrix4fv = qtResolveGlUniformMatrix4fv;
  f->glUseProgram = qtResolveGlUseProgram;
  f->glValidateProgram = qtResolveGlValidateProgram;
  f->glVertexAttribPointer = qtResolveGlVertexAttribPointer;
  f->glViewport = qtResolveGlViewport;
}

MSFunctions::~MSFunctions () {
  delete mFunctions;
}
