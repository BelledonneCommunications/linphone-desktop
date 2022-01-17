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
#include "components/participant/ParticipantDeviceModel.hpp"

#include "Camera.hpp"
#include "CameraDummy.hpp"

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
				Qt::QueuedConnection
				);
	
	mRefreshTimer->start();
}

void Camera::resetWindowId() {
	if(mIsPreview)
		CoreManager::getInstance()->getCore()->setNativePreviewWindowId(NULL);
	else if( mCallModel && mCallModel->getCall())
		mCallModel->getCall()->setNativeVideoWindowId(NULL);
	else
		CoreManager::getInstance()->getCore()->setNativeVideoWindowId(NULL);
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

QQuickFramebufferObject::Renderer *Camera::createRenderer () const {
	QQuickFramebufferObject::Renderer * renderer = NULL;
	if(mIsPreview){
		renderer = (QQuickFramebufferObject::Renderer *)CoreManager::getInstance()->getCore()->getNativePreviewWindowId();
		if(renderer)
			CoreManager::getInstance()->getCore()->setNativePreviewWindowId(NULL);// Reset
		renderer=(QQuickFramebufferObject::Renderer *)CoreManager::getInstance()->getCore()->createNativePreviewWindowId();
		if(renderer)
			CoreManager::getInstance()->getCore()->setNativePreviewWindowId(renderer);
	}else{
		bool useDefaultWindow = false;
		if(mCallModel){
			auto call = mCallModel->getCall();
			if(call){
				renderer = (QQuickFramebufferObject::Renderer *) call->getNativeVideoWindowId();
				if(renderer)
					call->setNativeVideoWindowId(NULL);// Reset
				renderer = (QQuickFramebufferObject::Renderer *) call->createNativeVideoWindowId();
				if(renderer)
					call->setNativeVideoWindowId(renderer);
			}else
				useDefaultWindow = true;
		}else if( mParticipantDeviceModel){
			auto participantDevice = mParticipantDeviceModel->getDevice();
			if(participantDevice){
				renderer = (QQuickFramebufferObject::Renderer *)participantDevice->getNativeVideoWindowId();
				if(renderer)
					participantDevice->setNativeVideoWindowId(NULL);// Reset
				renderer = (QQuickFramebufferObject::Renderer *) participantDevice->createNativeVideoWindowId();
				if(renderer)
					participantDevice->setNativeVideoWindowId(renderer);
			}else
				useDefaultWindow = true;
		}
		if(useDefaultWindow){
			renderer = (QQuickFramebufferObject::Renderer *)CoreManager::getInstance()->getCore()->getNativeVideoWindowId();
			if(renderer)
				CoreManager::getInstance()->getCore()->setNativeVideoWindowId(NULL);
			renderer = (QQuickFramebufferObject::Renderer *) CoreManager::getInstance()->getCore()->createNativeVideoWindowId();
			if(renderer)
				CoreManager::getInstance()->getCore()->setNativeVideoWindowId(renderer);
		}
	}
	if( !renderer){
		qWarning() << "Camera stream couldn't start for Rendering. Retrying in 1s";
		renderer = new CameraDummy();
		QTimer::singleShot(1000, this, &Camera::requestNewRenderer);
		
	}
	return renderer;
}

// -----------------------------------------------------------------------------

CallModel *Camera::getCallModel () const {
	return mCallModel;
}

bool Camera::getIsPreview () const {
	return mIsPreview;
}

ParticipantDeviceModel * Camera::getParticipantDeviceModel() const{
	return mParticipantDeviceModel;
}

void Camera::setCallModel (CallModel *callModel) {
	if (mCallModel != callModel) {
		mCallModel = callModel;
		update();
		
		emit callChanged(mCallModel);
	}
}

void Camera::setIsPreview (bool status) {
	if (mIsPreview != status) {
		mIsPreview = status;
		update();
		
		emit isPreviewChanged(status);
	}
}

void Camera::setParticipantDeviceModel(ParticipantDeviceModel * participantDeviceModel){
if (mParticipantDeviceModel != participantDeviceModel) {
		mParticipantDeviceModel = participantDeviceModel;
		update();
		emit participantDeviceModelChanged(mParticipantDeviceModel);
	}
}