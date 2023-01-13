/*
 * Copyright (c) 2010-2022 Belledonne Communications SARL.
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
#include "components/settings/SettingsModel.hpp"

#include "Camera.hpp"
#include "CameraDummy.hpp"

// =============================================================================

using namespace std;

namespace {
constexpr int MaxFps = 30;
}

QMutex Camera::mPreviewCounterMutex;
int Camera::mPreviewCounter;

// =============================================================================
Camera::Camera (QQuickItem *parent) : QQuickFramebufferObject(parent) {
	qDebug() << "[Camera] Camera constructor" << this;
	updateWindowIdLocation();
	setTextureFollowsItemSize(true);
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
	
	mLastVideoDefinitionChecker.setInterval(500);
	QObject::connect(&mLastVideoDefinitionChecker, &QTimer::timeout, this, &Camera::checkVideoDefinition, Qt::QueuedConnection);
}

Camera::~Camera(){
	qDebug() << "[Camera] Camera destructor" << this;
	mRefreshTimer->stop();
	
	if(mIsPreview)
		deactivatePreview();
	setWindowIdLocation(None);// We need to remove the Qt Buffer from SDK ot avoid to reuse it.
}

void Camera::resetWindowId() const{
	auto core = CoreManager::getInstance()->getCore();
	if(core && mIsWindowIdSet){
		QQuickFramebufferObject::Renderer * oldRenderer = NULL;
		if(mWindowIdLocation == CorePreview){
			oldRenderer = (QQuickFramebufferObject::Renderer *)core->getNativePreviewWindowId();
			if(oldRenderer)
				core->setNativePreviewWindowId(NULL);
		}else if( mWindowIdLocation == Call){
			if(mCallModel){
				auto call = mCallModel->getCall();
				if( call && call->getState() != linphone::Call::State::End && call->getState() != linphone::Call::State::Released){
					oldRenderer = (QQuickFramebufferObject::Renderer *) call->getNativeVideoWindowId();
					if(oldRenderer)
						call->setNativeVideoWindowId(NULL);
				}
			}
		}else if(mWindowIdLocation == Device){
			if(mParticipantDeviceModel){
				auto device = mParticipantDeviceModel->getDevice();
				if( device ){
					oldRenderer = (QQuickFramebufferObject::Renderer *)device->getNativeVideoWindowId();
					if(oldRenderer)
						mParticipantDeviceModel->getDevice()->setNativeVideoWindowId(NULL);
				}
			}
		}else if( mWindowIdLocation == Core){
			oldRenderer = (QQuickFramebufferObject::Renderer *)core->getNativeVideoWindowId();
			if(oldRenderer)
				core->setNativeVideoWindowId(NULL);
		}
		qDebug() << "[Camera] Removed " << oldRenderer << " at " << mWindowIdLocation << " for " << this;
		mIsWindowIdSet = false;
	}
}
void Camera::checkVideoDefinition(){
	if( mWindowIdLocation == WindowIdLocation::CorePreview){
		auto videoDefinition = CoreManager::getInstance()->getSettingsModel()->getCurrentPreviewVideoDefinition();
		if(videoDefinition["width"] != mLastVideoDefinition["width"] || videoDefinition["height"] != mLastVideoDefinition["height"]){
			mLastVideoDefinition = videoDefinition;
			emit videoDefinitionChanged();
		}
	}
}

void Camera::setWindowIdLocation(const WindowIdLocation& location){
	if( mWindowIdLocation != location){
		resetWindowId();// Location change: Reset old window ID.
		mWindowIdLocation = location;
		if( mWindowIdLocation == WindowIdLocation::CorePreview){
			mLastVideoDefinition = CoreManager::getInstance()->getSettingsModel()->getCurrentPreviewVideoDefinition();
			emit videoDefinitionChanged();
			mLastVideoDefinitionChecker.start();
		}else
			mLastVideoDefinitionChecker.stop();
	}
}
void Camera::updateWindowIdLocation(){
	bool useDefaultWindow = true;
	if(mIsPreview)
		setWindowIdLocation( WindowIdLocation::CorePreview);
	else{
		if(mCallModel){
			auto call = mCallModel->getCall();
			if(call){
				setWindowIdLocation( WindowIdLocation::Call);
				useDefaultWindow = false;
			}
		}else if( mParticipantDeviceModel){
			auto participantDevice = mParticipantDeviceModel->getDevice();
			if(participantDevice){
				setWindowIdLocation(WindowIdLocation::Device);
				useDefaultWindow = false;
			}
		}
		if(useDefaultWindow){
			setWindowIdLocation(WindowIdLocation::Core);
		}
	}
}

void Camera::removeParticipantDeviceModel(){
	mParticipantDeviceModel = nullptr;
}

void Camera::callRemoved(){
	mCallModel = nullptr;
}

QQuickFramebufferObject::Renderer *Camera::createRenderer () const {
	QQuickFramebufferObject::Renderer * renderer = NULL;
	if(mWindowIdLocation == CorePreview){
		qDebug() << "[Camera] Setting Camera to Preview";
		renderer=(QQuickFramebufferObject::Renderer *)CoreManager::getInstance()->getCore()->createNativePreviewWindowId();
		if(renderer)
			CoreManager::getInstance()->getCore()->setNativePreviewWindowId(renderer);
	}else if(mWindowIdLocation == Call){
		if(mCallModel){
			auto call = mCallModel->getCall();
			if(call){
				qDebug() << "[Camera] Setting Camera to CallModel";
				renderer = (QQuickFramebufferObject::Renderer *) call->createNativeVideoWindowId();
				if(renderer)
					call->setNativeVideoWindowId(renderer);
			}
		}
	}else if( mWindowIdLocation == Device) {
		auto participantDevice = mParticipantDeviceModel->getDevice();
		if(participantDevice){
			qDebug() << "[Camera] Setting Camera to Participant Device";
			qDebug() << "[Camera] Trying to create new window ID for " << participantDevice->getName().c_str() << ", addr=" << participantDevice->getAddress()->asString().c_str();
			renderer = (QQuickFramebufferObject::Renderer *) participantDevice->createNativeVideoWindowId();
			if(renderer)
				participantDevice->setNativeVideoWindowId(renderer);
		}
	}else if( mWindowIdLocation == Core){
		qDebug() << "[Camera] Setting Camera to Default Window";
		renderer = (QQuickFramebufferObject::Renderer *) CoreManager::getInstance()->getCore()->createNativeVideoWindowId();
		if(renderer)
			CoreManager::getInstance()->getCore()->setNativeVideoWindowId(renderer);
	}
	if( !renderer){
		QTimer::singleShot(1, this, &Camera::isNotReady);// Workaround for const createRenderer
		qWarning() << "[Camera] Stream couldn't start for Rendering. Retrying in 1s";
		renderer = new CameraDummy();
		QTimer::singleShot(1000, this, &Camera::requestNewRenderer);
		
	}else{
		mIsWindowIdSet = true;
		qDebug() << "[Camera] Added " << renderer << " at " << mWindowIdLocation << " for " << this;
		QTimer::singleShot(1, this, &Camera::isReady);// Workaround for const createRenderer.
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

bool Camera::getIsReady () const {
	return mIsReady;
}

ParticipantDeviceModel * Camera::getParticipantDeviceModel() const{
	return mParticipantDeviceModel;
}

void Camera::setCallModel (CallModel *callModel) {
	if (mCallModel != callModel) {
		if( mCallModel)
			disconnect(mCallModel, &CallModel::statusChanged, this, &Camera::onCallStateChanged);
		mCallModel = callModel;
		connect(mCallModel, &CallModel::statusChanged, this, &Camera::onCallStateChanged);
		connect(mCallModel, &QObject::destroyed, this, &Camera::callRemoved);
		updateWindowIdLocation();
		update();
		
		emit callChanged(mCallModel);
	}
}

void Camera::setIsPreview (bool status) {
	if (mIsPreview != status) {
		mIsPreview = status;
		if(mIsPreview)
			activatePreview();
		else
			deactivatePreview();
		updateWindowIdLocation();
		update();
		
		emit isPreviewChanged(status);
	}
}

void Camera::setIsReady(bool status) {
	if (mIsReady != status) {
		mIsReady = status;
		emit isReadyChanged();
	}
}

void Camera::setParticipantDeviceModel(ParticipantDeviceModel * participantDeviceModel){
if (mParticipantDeviceModel != participantDeviceModel) {
		if( mParticipantDeviceModel)
			disconnect(mParticipantDeviceModel, &QObject::destroyed, this, &Camera::removeParticipantDeviceModel);
		mParticipantDeviceModel = participantDeviceModel;
		connect(mParticipantDeviceModel, &QObject::destroyed, this, &Camera::removeParticipantDeviceModel);
		updateWindowIdLocation();
		update();
		emit participantDeviceModelChanged(mParticipantDeviceModel);
	}
}

void Camera::isReady(){
	setIsReady(true);
}
void Camera::isNotReady(){
	setIsReady(false);
}

void Camera::activatePreview(){
	mPreviewCounterMutex.lock();
	if (++mPreviewCounter == 1)
		CoreManager::getInstance()->getCore()->enableVideoPreview(true);
	mPreviewCounterMutex.unlock();
}

void Camera::deactivatePreview(){
	auto core = CoreManager::getInstance()->getCore();
	if(core){
		mPreviewCounterMutex.lock();
		if (--mPreviewCounter == 0)
			core->enableVideoPreview(false);
		mPreviewCounterMutex.unlock();
	}
}

void Camera::onCallStateChanged(){
	if( mCallModel && mCallModel->getStatus() == CallModel::CallStatusEnded){
		resetWindowId();
		disconnect(mCallModel, &CallModel::statusChanged, this, &Camera::onCallStateChanged);
		mCallModel = nullptr;
	}
}