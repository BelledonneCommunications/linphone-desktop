/*
 * MSFunctions.hpp
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

#ifndef MS_FUNCTIONS_H_
#define MS_FUNCTIONS_H_

#include <QOpenGLFunctions>

#define GL_ASSERT() \
  Q_ASSERT(mInstance->mQtFunctions != NULL); \
  Q_ASSERT(QOpenGLContext::currentContext()->functions() == mInstance->mQtFunctions);

#define GL_CALL(CALL) \
  GL_ASSERT() \
  mInstance->mQtFunctions->CALL;

#define GL_CALL_RET(CALL) \
  GL_ASSERT() \
  return mInstance->mQtFunctions->CALL;

// =============================================================================

struct OpenGlFunctions;

class MSFunctions {
public:
  ~MSFunctions ();

  void bind (QOpenGLFunctions *f) {
    mQtFunctions = f; // Qt functions.
  }

  OpenGlFunctions *getFunctions () {
    return mFunctions; // Own implementation.
  }

  // ---------------------------------------------------------------------------

  static MSFunctions *getInstance () {
    if (!mInstance)
      mInstance = new MSFunctions();

    return mInstance;
  }

  // ---------------------------------------------------------------------------

  static void qtResolveGlActiveTexture (GLenum texture) {
    GL_CALL(glActiveTexture(texture));
  }

  static void qtResolveGlAttachShader (GLuint program, GLuint shader) {
    GL_CALL(glAttachShader(program, shader));
  }

  static void qtResolveGlBindAttribLocation (GLuint program, GLuint index, const char *name) {
    GL_CALL(glBindAttribLocation(program, index, name));
  }

  static void qtResolveGlBindTexture (GLenum target, GLuint texture) {
    GL_CALL(glBindTexture(target, texture));
  }

  static void qtResolveGlClear (GLbitfield mask) {
    GL_CALL(glClear(mask));
  }

  static void qtResolveGlClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha) {
    GL_CALL(glClearColor(red, green, blue, alpha));
  }

  static void qtResolveGlCompileShader (GLuint shader) {
    GL_CALL(glCompileShader(shader));
  }

  static GLuint qtResolveGlCreateProgram () {
    GL_CALL_RET(glCreateProgram());
  }

  static GLuint qtResolveGlCreateShader (GLenum type) {
    GL_CALL_RET(glCreateShader(type));
  }

  static void qtResolveGlDeleteProgram (GLuint program) {
    GL_CALL(glDeleteProgram(program));
  }

  static void qtResolveGlDeleteShader (GLuint shader) {
    GL_CALL(glDeleteShader(shader));
  }

  static void qtResolveGlDeleteTextures (GLsizei n, const GLuint *textures) {
    GL_CALL(glDeleteTextures(n, textures));
  }

  static void qtResolveGlDisable (GLenum cap) {
    GL_CALL(glDisable(cap));
  }

  static void qtResolveGlDrawArrays (GLenum mode, GLint first, GLsizei count) {
    GL_CALL(glDrawArrays(mode, first, count));
  }

  static void qtResolveGlEnableVertexAttribArray (GLuint index) {
    GL_CALL(glEnableVertexAttribArray(index));
  }

  static void qtResolveGlGenTextures (GLsizei n, GLuint *textures) {
    GL_CALL(glGenTextures(n, textures));
  }

  static GLenum qtResolveGlGetError () {
    GL_CALL_RET(glGetError());
  }

  static void qtResolveGlGetProgramInfoLog (GLuint program, GLsizei bufsize, GLsizei *length, char *infolog) {
    GL_CALL(glGetProgramInfoLog(program, bufsize, length, infolog));
  }

  static void qtResolveGlGetProgramiv (GLuint program, GLenum pname, GLint *params) {
    GL_CALL(glGetProgramiv(program, pname, params));
  }

  static void qtResolveGlGetShaderInfoLog (GLuint shader, GLsizei bufsize, GLsizei *length, char *infolog) {
    GL_CALL(glGetShaderInfoLog(shader, bufsize, length, infolog));
  }

  static void qtResolveGlGetShaderiv (GLuint shader, GLenum pname, GLint *params) {
    GL_CALL(glGetShaderiv(shader, pname, params));
  }

  static const GLubyte *qtResolveGlGetString (GLenum name) {
    GL_CALL_RET(glGetString(name));
  }

  static GLint qtResolveGlGetUniformLocation (GLuint program, const char *name) {
    GL_CALL_RET(glGetUniformLocation(program, name));
  }

  static void qtResolveGlLinkProgram (GLuint program) {
    GL_CALL(glLinkProgram(program));
  }

  static void qtResolveGlPixelStorei (GLenum pname, GLint param) {
    GL_CALL(glPixelStorei(pname, param));
  }

  static void qtResolveGlShaderSource (GLuint shader, GLsizei count, const char **string, const GLint *length) {
    GL_CALL(glShaderSource(shader, count, string, length));
  }

  static void qtResolveGlTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels) {
    GL_CALL(glTexImage2D(target, level, internalformat, width, height, border, format, type, pixels));
  }

  static void qtResolveGlTexParameteri (GLenum target, GLenum pname, GLint param) {
    GL_CALL(glTexParameteri(target, pname, param));
  }

  static void qtResolveGlTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels) {
    GL_CALL(glTexSubImage2D(target, level, xoffset, yoffset, width, height, format, type, pixels));
  }

  static void qtResolveGlUniform1f (GLint location, GLfloat x) {
    GL_CALL(glUniform1f(location, x));
  }

  static void qtResolveGlUniform1i (GLint location, GLint x) {
    GL_CALL(glUniform1i(location, x));
  }

  static void qtResolveGlUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value) {
    GL_CALL(glUniformMatrix4fv(location, count, transpose, value));
  }

  static void qtResolveGlUseProgram (GLuint program) {
    GL_CALL(glUseProgram(program));
  }

  static void qtResolveGlValidateProgram (GLuint program) {
    GL_CALL(glValidateProgram(program));
  }

  static void qtResolveGlVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *ptr) {
    GL_CALL(glVertexAttribPointer(indx, size, type, normalized, stride, ptr));
  }

  static void qtResolveGlViewport (GLint x, GLint y, GLsizei width, GLsizei height) {
    GL_CALL(glViewport(x, y, width, height));
  }

  // ---------------------------------------------------------------------------

private:
  MSFunctions ();

  OpenGlFunctions *mFunctions = nullptr;
  QOpenGLFunctions *mQtFunctions = nullptr;

  static MSFunctions *mInstance;
};

#undef GL_CALL
#undef GL_CALL_RET
#undef GL_ASSERT

#endif // MS_FUNCTIONS_H_
