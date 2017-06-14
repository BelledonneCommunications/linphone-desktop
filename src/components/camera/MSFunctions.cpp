/*
 * MSFunctions.cpp
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
 *  Created on: February 9, 2017
 *      Author: Ronan Abhamon
 */

#include "MSFunctions.hpp"

// Do not include this header before `QOpenGLFunctions`!!!
#include <mediastreamer2/msogl_functions.h>

// =============================================================================

MSFunctions *MSFunctions::mInstance = nullptr;

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
