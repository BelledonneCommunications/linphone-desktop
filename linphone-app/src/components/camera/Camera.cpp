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

#include "components/call/CallModel.hpp"
#include "components/core/CoreManager.hpp"
#include "MSFunctions.hpp"

#include "Camera.hpp"

// =============================================================================

using namespace std;

namespace {
constexpr int MaxFps = 30;
}


// =============================================================================
Camera::Camera (QQuickItem *parent) : QQuickFramebufferObject(parent) {
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

QQuickFramebufferObject::Renderer *Camera::createRenderer () const {
	QQuickFramebufferObject::Renderer * renderer = NULL;
	if(mIsPreview){
		renderer=(QQuickFramebufferObject::Renderer *)CoreManager::getInstance()->getCore()->getNativePreviewWindowId();
		if( renderer == NULL){// Renderer is not ready. Wait at least one iteration from linphone core to get a preview stream
			CoreManager::getInstance()->getCore()->iterate();// It is safe to call it here : Qt block GUI thread when calling createRenderer
			renderer=(QQuickFramebufferObject::Renderer *)CoreManager::getInstance()->getCore()->getNativePreviewWindowId();
		}
		return renderer;
	}else{
		auto call = mCallModel->getCall();
		if(call) renderer= (QQuickFramebufferObject::Renderer *) call->getNativeVideoWindowId();
		if(!call || !renderer){
			return (QQuickFramebufferObject::Renderer *) CoreManager::getInstance()->getCore()->getNativeVideoWindowId();
		}else
			return renderer;
	}
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
