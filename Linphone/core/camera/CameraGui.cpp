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
	mIsDeleting = true;
	setWindowIdLocation(None);
}

QQuickFramebufferObject::Renderer *CameraGui::createRenderer() const {
	auto renderer = createRenderer(false);
	if (!renderer) {
		lInfo() << log().arg("(%1) Setting Camera to Dummy, %2").arg(mQmlName).arg(getSourceLocation());
		QTimer::singleShot(1, this, &CameraGui::isNotReady);
		renderer = new CameraDummy(); // Used to fill a renderer to avoid pushing a NULL.
		if (getSourceLocation() != CorePreview) QTimer::singleShot(1000, this, &CameraGui::requestNewRenderer);
	} else QTimer::singleShot(1, this, &CameraGui::isReady); // Hack because of constness of createRenderer()
	return renderer;
}

QQuickFramebufferObject::Renderer *CameraGui::createRenderer(bool resetWindowId) const {
	QQuickFramebufferObject::Renderer *renderer = NULL;
	lDebug() << log().arg("CreateRenderer. Reset=") << resetWindowId;
	// A renderer is mandatory, we cannot wait async.
	switch (getSourceLocation()) {
		case CorePreview: {
			if (resetWindowId) PreviewManager::getInstance()->unsubscribe(this);
			else renderer = PreviewManager::getInstance()->subscribe(this);
		} break;
		case Call: {
			auto f = [qmlName = mQmlName, callGui = mCallGui, &renderer, resetWindowId]() {
				auto call = callGui->getCore()->getModel()->getMonitor();
				if (call) {
					lInfo() << "[Camera] (" << qmlName << ") " << (resetWindowId ? "Resetting" : "Setting")
					        << " Camera to CallModel";
					if (resetWindowId) {
						renderer = (QQuickFramebufferObject::Renderer *)call->getNativeVideoWindowId();
						if (renderer) call->setNativeVideoWindowId(NULL);
					} else {
						renderer = (QQuickFramebufferObject::Renderer *)call->createNativeVideoWindowId();
						if (renderer) call->setNativeVideoWindowId(renderer);
					}
				}
			};
			App::postModelBlock(f);
		} break;
		case Device: {
			auto f = [qmlName = mQmlName, participantDeviceGui = mParticipantDeviceGui, &renderer, resetWindowId]() {
				auto device = participantDeviceGui->getCore()->getModel()->getMonitor();
				if (device) {
					lInfo() << "[Camera] (" << qmlName << ") " << (resetWindowId ? "Resetting" : "Setting")
					        << " Camera to ParticipantDeviceModel";
					if (resetWindowId) {
					} else {
						renderer = (QQuickFramebufferObject::Renderer *)device->createNativeVideoWindowId();
						if (renderer) device->setNativeVideoWindowId(renderer);
					}
				}
			};
			App::postModelBlock(f);
		} break;
		default: {
		}
	}

	return renderer;
}

void CameraGui::resetWindowId() const {
	createRenderer(true);
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
		else resetWindowId(); // Location change: Reset old window ID.
		mWindowIdLocation = location;
		if (mWindowIdLocation == CorePreview) PreviewManager::getInstance()->subscribe(this);
		update();
		//		if (mWindowIdLocation == WindowIdLocation::CorePreview) {
		//			mLastVideoDefinition =
		// CoreManager::getInstance()->getSettingsModel()->getCurrentPreviewVideoDefinition(); 			emit
		// videoDefinitionChanged(); 			mLastVideoDefinitionChecker.start();
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
