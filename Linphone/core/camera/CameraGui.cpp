/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#include "CameraDummy.hpp"
#include "CameraGui.hpp"
#include "PreviewManager.hpp"
#include "core/App.hpp"
#include "core/call/CallCore.hpp"
#include "core/call/CallGui.hpp"
#include "core/participant/ParticipantDeviceCore.hpp"
#include "core/participant/ParticipantDeviceGui.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(CameraGui)
DEFINE_GUI_OBJECT(CameraGui)

// =============================================================================
CameraGui::CameraGui(QQuickItem *parent) : QQuickFramebufferObject(parent) {
	mustBeInMainThread(getClassName());
	// The fbo content must be y-mirrored because the ms rendering is y-inverted.
	setMirrorVertically(true);
	mRefreshTimer.setInterval(1000 / mMaxFps);
	connect(&mRefreshTimer, &QTimer::timeout, this, &QQuickFramebufferObject::update, Qt::QueuedConnection);

	mRefreshTimer.start();
}

// TODO : Deactivate only if there are no previews to display (Could be open in settings and calls)
CameraGui::~CameraGui() {
	mustBeInMainThread("~" + getClassName());
	mRefreshTimer.stop();
	setWindowIdLocation(None);
}

// Hack for Qt constness on create Renderer.
// We need to store the renderer in order to update the SDK filters with this renderer.
QMap<const CameraGui *, QQuickFramebufferObject::Renderer *> gRenderers;
QMutex gRenderesLock;

//-------------------------------------------------------------

void CameraGui::refreshLastRenderer() {
	gRenderesLock.lock();
	if (gRenderers.contains(this)) setRenderer(gRenderers[this]);
	else clearRenderer();
	updateSDKRenderer();
	gRenderesLock.unlock();
}

void CameraGui::setRenderer(QQuickFramebufferObject::Renderer *renderer) {
	mLastRenderer = renderer;
}

void CameraGui::clearRenderer() {
	mLastRenderer = nullptr;
}

QQuickFramebufferObject::Renderer *CameraGui::createRenderer() const {
	QQuickFramebufferObject::Renderer *renderer = NULL;
	lDebug() << log().arg("CreateRenderer");

	// A renderer is mandatory, we cannot wait async.
	switch (getSourceLocation()) {
		case CorePreview: {
			// if (resetWindowId) PreviewManager::getInstance()->unsubscribe(this);
			renderer = PreviewManager::getInstance()->subscribe(this);
			//(QQuickFramebufferObject::Renderer *)CoreModel::getInstance()->getCore()->createNativePreviewWindowId();

		} break;
		case Call: {
			App::postModelBlock([qmlName = mQmlName, callGui = mCallGui, &renderer]() {
				auto call = callGui->getCore()->getModel()->getMonitor();
				if (call) {
					lInfo() << "[Camera] (" << qmlName << ") Camera create from CallModel";
					renderer = (QQuickFramebufferObject::Renderer *)call->createNativeVideoWindowId();
				}
			});
		} break;
		case Device: {
			App::postModelBlock([qmlName = mQmlName, participantDeviceGui = mParticipantDeviceGui, &renderer]() {
				auto device = participantDeviceGui->getCore()->getModel()->getMonitor();
				if (device) {
					lInfo() << "[Camera] (" << qmlName << ") Camera create from ParticipantDeviceModel";
					renderer = (QQuickFramebufferObject::Renderer *)device->createNativeVideoWindowId();
				}
			});
		} break;
		default: {
		}
	}

	// Storing Qt renderer
	gRenderesLock.lock();
	gRenderers[this] = renderer;
	gRenderesLock.unlock();
	QTimer::singleShot(
	    1, this, &CameraGui::refreshLastRenderer); // Assign new renderer to the current CameraGui (bypassing constness)

	if (!renderer) {
		lInfo() << log().arg("(%1) Setting Camera to Dummy, %2").arg(mQmlName).arg(getSourceLocation());
		QTimer::singleShot(1, this, &CameraGui::isNotReady);
		renderer = new CameraDummy(); // Used to fill a renderer to avoid pushing a NULL.
		QTimer::singleShot(1000, this, &CameraGui::requestNewRenderer);
	} else QTimer::singleShot(1, this, &CameraGui::isReady); // Hack because of constness of createRenderer()
	return renderer;
}

void CameraGui::updateSDKRenderer() {
	updateSDKRenderer(mLastRenderer);
}

void CameraGui::updateSDKRenderer(QQuickFramebufferObject::Renderer *renderer) {
	lDebug() << log().arg("Apply Qt Renderer to SDK") << renderer;
	switch (getSourceLocation()) {
		case CorePreview: {

		} break;
		case Call: {
			App::postModelAsync([qmlName = mQmlName, callGui = mCallGui, renderer]() {
				auto call = callGui->getCore()->getModel()->getMonitor();
				if (call) {
					lInfo() << "[Camera] (" << qmlName << ") Camera to CallModel";
					call->setNativeVideoWindowId(renderer);
				}
			});
		} break;
		case Device: {
			App::postModelAsync([qmlName = mQmlName, participantDeviceGui = mParticipantDeviceGui, renderer]() {
				auto device = participantDeviceGui->getCore()->getModel()->getMonitor();
				if (device) {
					lInfo() << "[Camera] (" << qmlName << ") Camera to ParticipantDevice";
					device->setNativeVideoWindowId(renderer);
				}
			});
		} break;
		default: {
		}
	}
}

void CameraGui::resetWindowId() {
	updateSDKRenderer(nullptr);
}
void CameraGui::checkVideoDefinition() { /*
	 if (mWindowIdLocation == WindowIdLocation::CorePreview) {
	     auto videoDefinition = CoreManager::getInstance()->getSettingsModel()->getCurrentPreviewVideoDefinition();
	     if (videoDefinition["width"] != mLastVideoDefinition["width"] ||
	         videoDefinition["height"] != mLastVideoDefinition["height"]) {
	         mLastVideoDefinition = videoDefinition;
	         emit videoDefinitionChanged();
	     }
	 }*/
}

bool CameraGui::getIsReady() const {
	return mIsReady;
}
void CameraGui::setIsReady(bool isReady) {
	if (mIsReady != isReady) {
		lDebug() << log().arg("Set IsReady") << isReady;
		mIsReady = isReady;
		emit isReadyChanged(mIsReady);
	}
}
void CameraGui::isReady() {
	setIsReady(true);
}
void CameraGui::isNotReady() {
	setIsReady(false);
}

bool CameraGui::getIsPreview() const {
	return mIsPreview;
}
void CameraGui::setIsPreview(bool status) {
	if (mIsPreview != status) {
		mIsPreview = status;
		updateWindowIdLocation();
		update();

		emit isPreviewChanged(status);
	}
}

CallGui *CameraGui::getCallGui() const {
	return mCallGui;
}

void CameraGui::setCallGui(CallGui *callGui) {
	if (mCallGui != callGui) {
		if (mCallGui) disconnect(mCallGui->getCore(), &CallCore::stateChanged, this, &CameraGui::callStateChanged);
		mCallGui = callGui;
		if (mCallGui) connect(mCallGui->getCore(), &CallCore::stateChanged, this, &CameraGui::callStateChanged);
		lDebug() << log().arg("Set Call") << mCallGui;
		emit callGuiChanged(mCallGui);
		updateWindowIdLocation();
	}
}

ParticipantDeviceGui *CameraGui::getParticipantDeviceGui() const {
	return mParticipantDeviceGui;
}

void CameraGui::setParticipantDeviceGui(ParticipantDeviceGui *deviceGui) {
	if (mParticipantDeviceGui != deviceGui) {
		mParticipantDeviceGui = deviceGui;
		lDebug() << log().arg("Set Device") << mParticipantDeviceGui;
		// setIsPreview(mParticipantDeviceGui->getCore()->isLocal());
		emit participantDeviceGuiChanged(mParticipantDeviceGui);
		updateWindowIdLocation();
	}
}

CameraGui::WindowIdLocation CameraGui::getSourceLocation() const {
	return mWindowIdLocation;
}

void CameraGui::setWindowIdLocation(const WindowIdLocation &location) {
	if (mWindowIdLocation != location) {
		lDebug() << log().arg("Update Window Id location from %2 to %3").arg(mWindowIdLocation).arg(location);
		if (mWindowIdLocation == CorePreview) PreviewManager::getInstance()->unsubscribe(this);
		//  else if (mWindowIdLocation != None) resetWindowId(); // Location change: Reset old window ID.
		resetWindowId();
		mWindowIdLocation = location;
		if (mWindowIdLocation == CorePreview) PreviewManager::getInstance()->subscribe(this);
		else updateSDKRenderer();
		// QTimer::singleShot(100, this, &CameraGui::requestNewRenderer);
		//		if (mWindowIdLocation == WindowIdLocation::CorePreview) {
		//			mLastVideoDefinition =
		//  CoreManager::getInstance()->getSettingsModel()->getCurrentPreviewVideoDefinition(); 			emit
		//  videoDefinitionChanged(); 			mLastVideoDefinitionChecker.start();
		//		} else mLastVideoDefinitionChecker.stop();
	}
}
void CameraGui::updateWindowIdLocation() {
	bool useDefaultWindow = true;
	if (mIsPreview) setWindowIdLocation(WindowIdLocation::CorePreview);
	else if (mCallGui) setWindowIdLocation(WindowIdLocation::Call);
	else if (mParticipantDeviceGui && !mParticipantDeviceGui->getCore()->isLocal())
		setWindowIdLocation(WindowIdLocation::Device);
	else setWindowIdLocation(WindowIdLocation::CorePreview);
}

void CameraGui::callStateChanged(LinphoneEnums::CallState state) {
	if (getSourceLocation() == CorePreview && state == LinphoneEnums::CallState::Connected) {
		if (!getIsReady()) {
			lDebug() << log().arg("Request new renderer because of not being Ready on CallState as Connected");
			emit requestNewRenderer();
		}
	}
}
