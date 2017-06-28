/*
 * CameraPreview.cpp
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
 *  Created on: April 19, 2017
 *      Author: Ronan Abhamon
 */

#include <QOpenGLFramebufferObject>
#include <QQuickWindow>
#include <QThread>
#include <QTimer>

#include "../core/CoreManager.hpp"
#include "MSFunctions.hpp"

#include "CameraPreview.hpp"

#define MAX_FPS 30

using namespace std;

// =============================================================================

struct ContextInfo {
  GLuint width;
  GLuint height;

  OpenGlFunctions *functions;
};

// -----------------------------------------------------------------------------

CameraPreviewRenderer::CameraPreviewRenderer () {
  mContextInfo = new ContextInfo();
}

CameraPreviewRenderer::~CameraPreviewRenderer () {
  qInfo() << QStringLiteral("Delete context info:") << mContextInfo;

  CoreManager *coreManager = CoreManager::getInstance();

  coreManager->lockVideoRender();
  coreManager->getCore()->setNativePreviewWindowId(nullptr);
  coreManager->unlockVideoRender();

  delete mContextInfo;
}

QOpenGLFramebufferObject *CameraPreviewRenderer::createFramebufferObject (const QSize &size) {
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

void CameraPreviewRenderer::render () {
  // Draw with ms filter.
  {
    QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();

    f->glClearColor(0.f, 0.f, 0.f, 1.f);
    f->glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    CoreManager *coreManager = CoreManager::getInstance();

    coreManager->lockVideoRender();
    MSFunctions *msFunctions = MSFunctions::getInstance();
    msFunctions->bind(f);

    coreManager->getCore()->previewOglRender();

    msFunctions->bind(nullptr);
    coreManager->unlockVideoRender();
  }

  // Synchronize opengl calls with QML.
  if (mWindow)
    mWindow->resetOpenGLState();
}

void CameraPreviewRenderer::synchronize (QQuickFramebufferObject *item) {
  mWindow = item->window();
}

void CameraPreviewRenderer::updateWindowId () {
  if (!mUpdateContextInfo)
    return;

  mUpdateContextInfo = false;

  qInfo() << "Thread" << QThread::currentThread() << QStringLiteral("Set context info (width: %1, height: %2):")
    .arg(mContextInfo->width).arg(mContextInfo->height) << mContextInfo;

  CoreManager::getInstance()->getCore()->setNativePreviewWindowId(mContextInfo);
}

// -----------------------------------------------------------------------------

QMutex CameraPreview::mCounterMutex;
int CameraPreview::mCounter = 0;

// -----------------------------------------------------------------------------

CameraPreview::CameraPreview (QQuickItem *parent) : QQuickFramebufferObject(parent) {
  mCounterMutex.lock();
  if (++mCounter == 1)
    CoreManager::getInstance()->getCore()->enableVideoPreview(true);
  mCounterMutex.unlock();

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

CameraPreview::~CameraPreview () {
  mCounterMutex.lock();
  if (--mCounter == 0)
    CoreManager::getInstance()->getCore()->enableVideoPreview(false);
  mCounterMutex.unlock();
}

QQuickFramebufferObject::Renderer *CameraPreview::createRenderer () const {
  return new CameraPreviewRenderer();
}
