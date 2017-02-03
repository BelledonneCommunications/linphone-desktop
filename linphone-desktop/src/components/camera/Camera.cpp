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

#include <QFileInfo>
#include <QOpenGLFunctions>
#include <QOpenGLTexture>

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "Camera.hpp"

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
  }

  CameraRenderer *m_renderer;
};

// -----------------------------------------------------------------------------

struct ContextInfo {
  GLuint width;
  GLuint height;
};

// -----------------------------------------------------------------------------

CameraRenderer::CameraRenderer (const Camera *camera) : m_camera(camera) {}

QOpenGLFramebufferObject *CameraRenderer::createFramebufferObject (const QSize &size) {
  QOpenGLFramebufferObjectFormat format;
  format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
  format.setInternalTextureFormat(GL_RGBA8);
  format.setSamples(4);

  ContextInfo *context_info = m_camera->m_context_info;
  context_info->width = size.width();
  context_info->height = size.height();

  if (m_camera->m_is_preview)
    CoreManager::getInstance()->getCore()->setNativePreviewWindowId(context_info);
  else
    m_camera->m_call->getLinphoneCall()->setNativeVideoWindowId(context_info);

  return new QOpenGLFramebufferObject(size, format);
}

void CameraRenderer::render () {
  CameraStateBinder state(this);

  QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();

  f->glClearColor(0.f, 0.f, 0.f, 0.f);
  f->glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  m_camera->getCall()->getLinphoneCall()->oglRender(m_camera->m_is_preview);

  update();
}

// -----------------------------------------------------------------------------

Camera::Camera (QQuickItem *parent) : QQuickFramebufferObject(parent) {
  setAcceptHoverEvents(true);
  setAcceptedMouseButtons(Qt::LeftButton | Qt::RightButton);

  // The fbo content must be y-mirrored because the ms rendering is y-inverted.
  setMirrorVertically(true);

  m_context_info = new ContextInfo();
}

Camera::~Camera () {
  delete m_context_info;
}

QQuickFramebufferObject::Renderer *Camera::createRenderer () const {
  m_renderer = new CameraRenderer(this);
  return m_renderer;
}

// -----------------------------------------------------------------------------

void Camera::takeScreenshot () {
  m_screenshot = m_renderer->framebufferObject()->toImage();
}

void Camera::saveScreenshot (const QString &path) {
  QString formatted_path = path.startsWith("file://") ? path.mid(sizeof("file://") - 1) : path;
  QFileInfo info(formatted_path);
  QString extension = info.suffix();

  m_screenshot.save(
    formatted_path,
    extension.size() > 0 ? ::Utils::qStringToLinphoneString(extension).c_str() : "jpg",
    100
  );
}

// -----------------------------------------------------------------------------

void Camera::mousePressEvent (QMouseEvent *) {
  setFocus(true);
}

// -----------------------------------------------------------------------------

CallModel *Camera::getCall () const {
  return m_call;
}

void Camera::setCall (CallModel *call) {
  if (m_call != call) {
    if (call) {
      shared_ptr<linphone::Call> linphone_call = call->getLinphoneCall();
      linphone::CallState state = linphone_call->getState();

      if (state == linphone::CallStateConnected || state == linphone::CallStateStreamsRunning) {
        if (m_is_preview)
          CoreManager::getInstance()->getCore()->setNativePreviewWindowId(m_context_info);
        else
          linphone_call->setNativeVideoWindowId(m_context_info);
      }
    }

    m_call = call;

    emit callChanged(call);
  }
}
