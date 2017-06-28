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

#include <QOpenGLFramebufferObject>
#include <QQuickWindow>
#include <QThread>
#include <QTimer>

#include "../core/CoreManager.hpp"
#include "MSFunctions.hpp"

#include "Camera.hpp"

#define MAX_FPS 30

using namespace std;

// =============================================================================

struct ContextInfo {
  GLuint width;
  GLuint height;

  OpenGlFunctions *functions;
};

// -----------------------------------------------------------------------------

CameraRenderer::CameraRenderer () {
  mContextInfo = new ContextInfo();
}

CameraRenderer::~CameraRenderer () {
  qInfo() << QStringLiteral("Delete context info:") << mContextInfo;

  CoreManager *coreManager = CoreManager::getInstance();

  coreManager->lockVideoRender();

  if (mIsPreview)
    coreManager->getCore()->setNativePreviewWindowId(nullptr);
  else if (mCall)
    mCall->setNativeVideoWindowId(nullptr);

  coreManager->unlockVideoRender();

  delete mContextInfo;
}

QOpenGLFramebufferObject *CameraRenderer::createFramebufferObject (const QSize &size) {
  QOpenGLFramebufferObjectFormat format;
  format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
  format.setInternalTextureFormat(GL_RGBA8);
  format.setSamples(4);

  CoreManager *coreManager = CoreManager::getInstance();

  // It's not the same thread as render.
  coreManager->lockVideoRender();

  mContextInfo->width = static_cast<GLuint>(size.width());
  mContextInfo->height = static_cast<GLuint>(size.height());
  mContextInfo->functions = MSFunctions::getInstance()->getFunctions();
  mUpdateContextInfo = true;

  updateWindowId();

  coreManager->unlockVideoRender();

  return new QOpenGLFramebufferObject(size, format);
}

void CameraRenderer::render () {
  // Draw with ms filter.
  {
    QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();

    f->glClearColor(0.f, 0.f, 0.f, 0.f);
    f->glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    CoreManager *coreManager = CoreManager::getInstance();

    coreManager->lockVideoRender();
    MSFunctions *msFunctions = MSFunctions::getInstance();
    msFunctions->bind(f);

    if (mIsPreview)
      coreManager->getCore()->previewOglRender();
    else if (mCall) {
      mCall->oglRender();
      if (mNotifyReceivedVideoSize && notifyReceivedVideoSize())
        mNotifyReceivedVideoSize = false;
    }

    msFunctions->bind(nullptr);
    coreManager->unlockVideoRender();
  }

  // Synchronize opengl calls with QML.
  if (mWindow)
    mWindow->resetOpenGLState();
}

void CameraRenderer::synchronize (QQuickFramebufferObject *item) {
  // No mutex needed here. It's a synchronized area.

  mWindow = item->window();

  Camera *camera = qobject_cast<Camera *>(item);

  {
    CallModel *model = camera->getCallModel();
    mCall = model ? model->getCall() : nullptr;
  }

  mIsPreview = camera->mIsPreview;

  updateWindowId();
}

void CameraRenderer::updateWindowId () {
  if (!mUpdateContextInfo)
    return;

  mUpdateContextInfo = false;

  qInfo() << "Thread" << QThread::currentThread() << QStringLiteral("Set context info (width: %1, height: %2, is_preview: %3):")
    .arg(mContextInfo->width).arg(mContextInfo->height).arg(mIsPreview) << mContextInfo;

  if (mIsPreview)
    CoreManager::getInstance()->getCore()->setNativePreviewWindowId(mContextInfo);
  else if (mCall)
    mCall->setNativeVideoWindowId(mContextInfo);
}

bool CameraRenderer::notifyReceivedVideoSize () const {
  shared_ptr<const linphone::VideoDefinition> videoDefinition = mCall->getCurrentParams()->getReceivedVideoDefinition();
  unsigned int width = videoDefinition->getWidth();
  unsigned int height = videoDefinition->getHeight();

  if (width && height) {
    qInfo() << "Thread" << QThread::currentThread() << QStringLiteral("Received video size (width: %1, height: %2):")
      .arg(width).arg(height) << mContextInfo;

    CallModel *callModel = &mCall->getData<CallModel>("call-model");
    QTimer::singleShot(0, callModel, [callModel, width, height] {
      callModel->notifyCameraFirstFrameReceived(width, height);
    });

    return true;
  }

  return false;
}

// -----------------------------------------------------------------------------

Camera::Camera (QQuickItem *parent) : QQuickFramebufferObject(parent) {
  // The fbo content must be y-mirrored because the ms rendering is y-inverted.
  setMirrorVertically(true);

  mRefreshTimer = new QTimer(this);
  mRefreshTimer->setInterval(1000 / MAX_FPS);

  QObject::connect(
    mRefreshTimer, &QTimer::timeout,
    this, &QQuickFramebufferObject::update,
    Qt::DirectConnection
  );

  mRefreshTimer->start();
}

QQuickFramebufferObject::Renderer *Camera::createRenderer () const {
  return new CameraRenderer();
}

// -----------------------------------------------------------------------------

CallModel *Camera::getCallModel () const {
  return mCallModel;
}

void Camera::setCallModel (CallModel *callModel) {
  if (mCallModel != callModel) {
    mCallModel = callModel;
    update();

    emit callChanged(mCallModel);
  }
}

bool Camera::getIsPreview () const {
  return mIsPreview;
}

void Camera::setIsPreview (bool status) {
  if (mIsPreview != status) {
    mIsPreview = status;
    update();

    emit isPreviewChanged(status);
  }
}
