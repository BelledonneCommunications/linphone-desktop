#include <QOpenGLFunctions>

// Do not include this header before `QOpenGLFunctions`!!!
#include <mediastreamer2/msogl.h>

#include "MSFunctions.hpp"

// =============================================================================

MSFunctions *MSFunctions::m_instance = nullptr;

// -----------------------------------------------------------------------------

MSFunctions::MSFunctions () {
  OpenGlFunctions *f = m_functions = new OpenGlFunctions();

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
  delete m_functions;
}
