/*
 * Camera.cpp
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
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"
#include "MSFunctions.hpp"

#include "Camera.hpp"

#include <QFileInfo>
#include <QThread>
#include <QQuickWindow>

// =============================================================================

struct CameraStateBinder {
  CameraStateBinder (CameraRenderer *renderer) : m_renderer(renderer) {
    QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();

    f->glEnable(GL_DEPTH_TEST);
    f->glEnable(GL_CULL_FACE);
    f->glDepthMask(GL_TRUE);
    f->glDepthFunc(GL_LESS);
    f->glFrontFace(GL_CCW);
    f->glCullFace(GL_BACK);
  }

  ~CameraStateBinder () {
    QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();

    f->glDisable(GL_CULL_FACE);
    f->glDisable(GL_DEPTH_TEST);

    // Process at next tick.
    m_renderer->update();
  }

  CameraRenderer *m_renderer;
};

// -----------------------------------------------------------------------------

struct ContextInfo {
  GLuint width;
  GLuint height;

  OpenGlFunctions *functions;
};

// -----------------------------------------------------------------------------

CameraRenderer::CameraRenderer () {
  m_context_info = new ContextInfo();
}

CameraRenderer::~CameraRenderer () {
  delete m_context_info;
}

QOpenGLFramebufferObject *CameraRenderer::createFramebufferObject (const QSize &size) {
  QOpenGLFramebufferObjectFormat format;
  format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
  format.setInternalTextureFormat(GL_RGBA8);
  format.setSamples(4);

  CoreManager *core = CoreManager::getInstance();

  m_context_info->width = size.width();
  m_context_info->height = size.height();
  m_context_info->functions = MSFunctions::getInstance()->getFunctions();

  // It's not the same thread as render.
  core->lockVideoRender();
  updateWindowId();
  core->unlockVideoRender();

  return new QOpenGLFramebufferObject(size, format);
}

void CameraRenderer::render () {
  CameraStateBinder state(this);

  if (!m_linphone_call)
    return;

  // Draw with ms filter.
  {
    QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();

    f->glClearColor(0.f, 0.f, 0.f, 0.f);
    f->glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    CoreManager *core = CoreManager::getInstance();
    MSFunctions *ms_functions = MSFunctions::getInstance();

    core->lockVideoRender();

    ms_functions->bind(f);
    m_linphone_call->oglRender(m_is_preview);
    ms_functions->bind(nullptr);

    core->unlockVideoRender();
  }

  // Synchronize opengl calls with QML.
  if (m_window)
    m_window->resetOpenGLState();
}

void CameraRenderer::synchronize (QQuickFramebufferObject *item) {
  // No mutex needed here. It's a synchronized area.

  m_window = item->window();

  Camera *camera = qobject_cast<Camera *>(item);

  m_linphone_call = camera->getCall()->getLinphoneCall();
  m_is_preview = camera->m_is_preview;

  updateWindowId();
}

void CameraRenderer::updateWindowId () {
  qInfo() << "Thread" << QThread::currentThread() << QStringLiteral("Set context info (width: %1, height: %2, is_preview: %3).")
    .arg(m_context_info->width).arg(m_context_info->height).arg(m_is_preview);

  if (m_is_preview)
    CoreManager::getInstance()->getCore()->setNativePreviewWindowId(m_context_info);
  else if (m_linphone_call)
    m_linphone_call->setNativeVideoWindowId(m_context_info);
}

// -----------------------------------------------------------------------------

Camera::Camera (QQuickItem *parent) : QQuickFramebufferObject(parent) {
  setAcceptHoverEvents(true);
  setAcceptedMouseButtons(Qt::LeftButton | Qt::RightButton);

  // The fbo content must be y-mirrored because the ms rendering is y-inverted.
  setMirrorVertically(true);
}

QQuickFramebufferObject::Renderer *Camera::createRenderer () const {
  return new CameraRenderer();
}

void Camera::mousePressEvent (QMouseEvent *) {
  setFocus(true);
}

// -----------------------------------------------------------------------------

CallModel *Camera::getCall () const {
  return m_call;
}

void Camera::setCall (CallModel *call) {
  if (m_call != call) {
    m_call = call;
    update();

    emit callChanged(m_call);
  }
}

bool Camera::getIsPreview () const {
  return m_is_preview;
}

void Camera::setIsPreview (bool status) {
  if (m_is_preview != status) {
    m_is_preview = status;
    update();

    emit isPreviewChanged(status);
  }
}
