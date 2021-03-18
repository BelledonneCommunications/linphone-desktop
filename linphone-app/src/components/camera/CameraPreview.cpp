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

#include "CameraPreview.hpp"

// =============================================================================

using namespace std;

namespace {
constexpr int MaxFps = 30;
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
	CoreManager::getInstance()->getCore()->setNativePreviewWindowId(NULL);
}

class SafeFramebuffer : public QQuickFramebufferObject::Renderer{
public:
	SafeFramebuffer(){}
	QOpenGLFramebufferObject *createFramebufferObject (const QSize &size) override{
		return new QOpenGLFramebufferObject(size);
	}	
	void render () override{}
	void synchronize (QQuickFramebufferObject *item) override{}
};

QQuickFramebufferObject::Renderer *CameraPreview::createRenderer () const {
	QQuickFramebufferObject::Renderer * renderer;
	CoreManager::getInstance()->getCore()->setNativePreviewWindowId(NULL);// Reset
	renderer=(QQuickFramebufferObject::Renderer *)CoreManager::getInstance()->getCore()->getNativePreviewWindowId();
	if(renderer)
		return renderer;
	else{
		qWarning() << "Preview stream couldn't start for Rendering";
		return new SafeFramebuffer();
	}
}
