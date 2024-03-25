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
#include "core/App.hpp"
#include "core/call/CallCore.hpp"
#include "core/call/CallGui.hpp"
#include "core/participant/ParticipantDeviceCore.hpp"
#include "core/participant/ParticipantDeviceGui.hpp"

DEFINE_ABSTRACT_OBJECT(CameraGui)

QMutex CameraGui::mPreviewCounterMutex;
int CameraGui::mPreviewCounter = 0;

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
	App::postModelSync([this]() { CoreModel::getInstance()->getCore()->enableVideoPreview(false); });
}

QQuickFramebufferObject::Renderer *CameraGui::createRenderer() const {
	auto renderer = createRenderer(false);
	if (!renderer) {
		qInfo() << "[Camera] (" << mQmlName << ") Setting Camera to Dummy, " << getSourceLocation();
		QTimer::singleShot(1, this, &CameraGui::isNotReady);
		renderer = new CameraDummy(); // Used to fill a renderer to avoid pushing a NULL.
		QTimer::singleShot(1000, this, &CameraGui::requestNewRenderer);
	} else QTimer::singleShot(1, this, &CameraGui::isReady); // Hack because of constness of createRenderer()
	return renderer;
}

QQuickFramebufferObject::Renderer *CameraGui::createRenderer(bool resetWindowId) const {
	QQuickFramebufferObject::Renderer *renderer = NULL;
	// A renderer is mandatory, we cannot wait async.
	switch (getSourceLocation()) {
		case CorePreview:
			App::postModelSync([this, &renderer, resetWindowId]() {
				qInfo() << "[Camera] (" << mQmlName << ") Setting Camera to Preview";
				auto coreModel = CoreModel::getInstance();
				if (coreModel) {
					auto core = coreModel->getCore();
					if (!core) return;
					core->enableVideoPreview(true);
					if (resetWindowId) {
						renderer = (QQuickFramebufferObject::Renderer *)core->getNativePreviewWindowId();
						if (renderer) core->setNativePreviewWindowId(NULL);
					} else {
						renderer = (QQuickFramebufferObject::Renderer *)core->createNativePreviewWindowId();
						if (renderer) core->setNativePreviewWindowId(renderer);
					}
				}
			});
			break;
		case Call:
			App::postModelSync([this, &renderer, resetWindowId]() {
				auto call = mCallGui->getCore()->getModel()->getMonitor();
				if (call) {
					qInfo() << "[Camera] (" << mQmlName << ") Setting Camera to CallModel";
					if (resetWindowId) {
						renderer = (QQuickFramebufferObject::Renderer *)call->getNativeVideoWindowId();
						if (renderer) call->setNativeVideoWindowId(NULL);
					} else {
						renderer = (QQuickFramebufferObject::Renderer *)call->createNativeVideoWindowId();
						if (renderer) call->setNativeVideoWindowId(renderer);
					}
				}
			});
			break;
		case Device:
			App::postModelSync([this, &renderer, resetWindowId]() {
				auto device = mParticipantDeviceGui->getCore()->getModel()->getMonitor();
				if (device) {
					qInfo() << "[Camera] (" << mQmlName << ") Setting Camera to ParticipantDeviceModel";
					if (resetWindowId) {
					} else {
						renderer = (QQuickFramebufferObject::Renderer *)device->createNativeVideoWindowId();
						if (renderer) device->setNativeVideoWindowId(renderer);
					}
				}
			});
			break;
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

QString CameraGui::getQmlName() const {
	return mQmlName;
}

void CameraGui::setQmlName(const QString &name) {
	if (name != mQmlName) {
		mQmlName = name;
		emit qmlNameChanged();
	}
}

bool CameraGui::getIsReady() const {
	return mIsReady;
}
void CameraGui::setIsReady(bool isReady) {
	if (mIsReady != isReady) {
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
		if (mIsPreview) activatePreview();
		else deactivatePreview();
		// updateWindowIdLocation();
		update();

		emit isPreviewChanged(status);
	}
}

CallGui *CameraGui::getCallGui() const {
	return mCallGui;
}

void CameraGui::setCallGui(CallGui *callGui) {
	if (mCallGui != callGui) {
		mCallGui = callGui;
		qDebug() << "Set Call " << mCallGui;
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
		qDebug() << "Set Device " << mParticipantDeviceGui;
		// setIsPreview(mParticipantDeviceGui->getCore()->isLocal());
		emit participantDeviceGuiChanged(mParticipantDeviceGui);
		updateWindowIdLocation();
	}
}

CameraGui::WindowIdLocation CameraGui::getSourceLocation() const {
	return mWindowIdLocation;
}

void CameraGui::activatePreview() {
	mPreviewCounterMutex.lock();
	setWindowIdLocation(WindowIdLocation::CorePreview);
	if (++mPreviewCounter == 1) {
		App::postModelSync([this]() {
			auto coreModel = CoreModel::getInstance();
			coreModel->getCore()->enableVideoPreview(true);
		});
	}
	mPreviewCounterMutex.unlock();
}

void CameraGui::deactivatePreview() {
	mPreviewCounterMutex.lock();
	setWindowIdLocation(WindowIdLocation::None);
	if (--mPreviewCounter == 0) {
		App::postModelSync([this]() {
			auto coreModel = CoreModel::getInstance();
			coreModel->getCore()->enableVideoPreview(false);
		});
		mPreviewCounterMutex.unlock();
	}
}
void CameraGui::setWindowIdLocation(const WindowIdLocation &location) {
	if (mWindowIdLocation != location) {
		qDebug() << "Update Window Id location from " << mWindowIdLocation << " to " << location;
		resetWindowId(); // Location change: Reset old window ID.
		mWindowIdLocation = location;
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
	if (mCallGui) setWindowIdLocation(WindowIdLocation::Call);
	else if (mParticipantDeviceGui && !mParticipantDeviceGui->getCore()->isLocal())
		setWindowIdLocation(WindowIdLocation::Device);
	else setWindowIdLocation(WindowIdLocation::CorePreview);
}
