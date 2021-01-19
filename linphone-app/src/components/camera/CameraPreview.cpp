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

#include <QOpenGLFramebufferObject>
#include <QQuickWindow>
#include <QThread>
#include <QTimer>

#include "components/core/CoreManager.hpp"
#include "MSFunctions.hpp"

#include "CameraPreview.hpp"


// =============================================================================

using namespace std;

namespace {
  constexpr int MaxFps = 30;
}
// -----------------------------------------------------------------------------

CameraPreviewRenderer::CameraPreviewRenderer () {
  mContextInfo.window = NULL; 
}

CameraPreviewRenderer::~CameraPreviewRenderer () {
  qInfo() << QStringLiteral("Delete context info:") << &mContextInfo;

  CoreManager *coreManager = CoreManager::getInstance();

  coreManager->lockVideoRender();
  coreManager->getCore()->setNativePreviewWindowId(nullptr);
  coreManager->unlockVideoRender();
}

QOpenGLFramebufferObject *CameraPreviewRenderer::createFramebufferObject (const QSize &size) {
  QOpenGLFramebufferObjectFormat format;
  format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
  format.setInternalTextureFormat(GL_RGBA8);
  format.setSamples(4);

  CoreManager *coreManager = CoreManager::getInstance();

  // It's not the same thread as render.
  coreManager->lockVideoRender();

  mContextInfo.getProcAddress = MSFunctions::getInstance()->mGetProcAddress;
  mContextInfo.width = (GLuint)size.width();	
  mContextInfo.height = (GLuint)size.height();
  mUpdateContextInfo = true;

  updateWindowId();

  coreManager->unlockVideoRender();
  return new QOpenGLFramebufferObject(size, format);
}

void CameraPreviewRenderer::render () {
  // Draw with ms filter.
  CoreManager *coreManager = CoreManager::getInstance();

  coreManager->lockVideoRender();
  coreManager->getCore()->previewOglRender();
  coreManager->unlockVideoRender();

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

  qInfo() << "Thread" << QThread::currentThread() << QStringLiteral("Set context info :")
    << &mContextInfo;

  CoreManager::getInstance()->getCore()->setNativePreviewWindowId(&mContextInfo);
}

// -----------------------------------------------------------------------------

QMutex CameraPreview::mCounterMutex;
int CameraPreview::mCounter;

// -----------------------------------------------------------------------------

CameraPreview::CameraPreview (QQuickItem *parent) : QQuickFramebufferObject(parent) {
  mCounterMutex.lock();
  if (++mCounter == 1)
    CoreManager::getInstance()->getCore()->enableVideoPreview(true);
  mCounterMutex.unlock();
  
  setTextureFollowsItemSize(true);
  // The fbo content must be y-mirrored because the ms rendering is y-inverted.
  setMirrorVertically(true);

  mRefreshTimer = new QTimer(this);
  mRefreshTimer->setInterval(1000 / MaxFps);

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
