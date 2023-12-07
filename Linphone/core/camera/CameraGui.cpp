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

DEFINE_ABSTRACT_OBJECT(CameraGui)

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
	App::postModelSync([this]() { CoreModel::getInstance()->getCore()->enableVideoPreview(false); });
}

QQuickFramebufferObject::Renderer *CameraGui::createRenderer() const {
	QQuickFramebufferObject::Renderer *renderer = NULL;
	// A renderer is mandatory, we cannot wait async.
	switch (getSourceLocation()) {
		case CorePreview:
			App::postModelSync([this, &renderer]() {
				auto coreModel = CoreModel::getInstance();
				if (coreModel) {
					auto core = coreModel->getCore();
					if (!core) return;
					core->enableVideoPreview(true);
					renderer = (QQuickFramebufferObject::Renderer *)core->createNativePreviewWindowId();
					if (renderer) core->setNativePreviewWindowId(renderer);
				}
			});
			break;
		case Call:
			App::postModelSync([this, &renderer]() {
				auto call = mCallGui->getCore()->getModel()->getMonitor();
				if (call) {
					// qInfo() << "[Camera] (" << mQmlName << ") Setting Camera to CallModel";
					renderer = (QQuickFramebufferObject::Renderer *)call->createNativeVideoWindowId();
					if (renderer) call->setNativeVideoWindowId(renderer);
				}
			});
		default: {
		}
	}
	if (!renderer) {
		QTimer::singleShot(1, this, &CameraGui::isNotReady);
		renderer = new CameraDummy(); // Used to fill a renderer to avoid pushing a NULL.
		QTimer::singleShot(1000, this, &CameraGui::requestNewRenderer);
	} else QTimer::singleShot(1, this, &CameraGui::isReady); // Hack because of constness of createRenderer()
	return renderer;
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

CallGui *CameraGui::getCallGui() const {
	return mCallGui;
}

void CameraGui::setCallGui(CallGui *callGui) {
	if (mCallGui != callGui) {
		mCallGui = callGui;
		emit callGuiChanged(mCallGui);
	}
}

CameraGui::WindowIdLocation CameraGui::getSourceLocation() const {
	if (mCallGui != nullptr) return Call;
	else return CorePreview;
}
