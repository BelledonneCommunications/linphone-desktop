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

#include "../App.hpp"
#include "PreviewManager.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(PreviewManager)

// =============================================================================
PreviewManager *PreviewManager::gInstance = nullptr;

PreviewManager::PreviewManager(QObject *parent) : QObject(parent) {
}

PreviewManager::~PreviewManager() {
}

PreviewManager *PreviewManager::getInstance() {
	if (gInstance) return gInstance;
	else {
		gInstance = new PreviewManager();
		return gInstance;
	}
}

// Create a Renderer from SDK preview
QQuickFramebufferObject::Renderer *PreviewManager::subscribe(const CameraGui *candidate) {
	QQuickFramebufferObject::Renderer *renderer = nullptr;
	mCounterMutex.lock();

	if (mCandidates.size() == 0) {
		activate();
	}
	auto itCandidate =
	    std::find_if(mCandidates.begin(), mCandidates.end(),
	                 [candidate](const QPair<const CameraGui *, QQuickFramebufferObject::Renderer *> &item) {
		                 return item.first == candidate;
	                 });
	if (itCandidate == mCandidates.end()) {
		connect(candidate, &QObject::destroyed, this, qOverload<QObject *>(&PreviewManager::unsubscribe));
		mCandidates.append({candidate, nullptr});
		itCandidate = mCandidates.end() - 1;
		lDebug() << log().arg("Subscribing New") << itCandidate->first->getQmlName();
	} else {
		lDebug() << log().arg("Resubscribing") << itCandidate->first->getQmlName();
	}
	mCounterMutex.unlock();
	App::postModelBlock([&renderer, isFirst = (itCandidate == mCandidates.begin()),
	                     name = itCandidate->first->getQmlName()]() {
		renderer =
		    (QQuickFramebufferObject::Renderer *)CoreModel::getInstance()->getCore()->createNativePreviewWindowId();
		if (!renderer) { // TODO debug
			renderer =
			    (QQuickFramebufferObject::Renderer *)CoreModel::getInstance()->getCore()->createNativePreviewWindowId();
		}
		if (isFirst) {
			lDebug() << "[PreviewManager] " << name << " Set Native Preview Id with " << renderer;
			CoreModel::getInstance()->getCore()->setNativePreviewWindowId(renderer);
		}
	});
	mCounterMutex.lock();
	itCandidate->second = renderer;
	mCounterMutex.unlock();
	return renderer;
}

void PreviewManager::unsubscribe(const CameraGui *candidate) { // If nullptr, Use of sender()
	mCounterMutex.lock();
	auto itCandidate = std::find_if(mCandidates.begin(), mCandidates.end(),
	                                [candidate = (candidate ? candidate : sender())](
	                                    const QPair<const CameraGui *, QQuickFramebufferObject::Renderer *> &item) {
		                                return item.first == candidate;
	                                });
	if (itCandidate != mCandidates.end()) {
		lDebug() << log().arg("Unsubscribing") << itCandidate->first->getQmlName();
		disconnect(candidate, nullptr, this, nullptr);
		if (mCandidates.size() == 1) {
			mCandidates.erase(itCandidate);
			deactivate();
		} else if (mCandidates.begin() == itCandidate) {
			mCandidates.erase(itCandidate);
			lDebug() << log().arg("Update") << mCandidates.first().first->getQmlName();
			auto renderer = mCandidates.first().second;
			if (renderer)
				App::postModelBlock([renderer = mCandidates.first().second]() {
					CoreModel::getInstance()->getCore()->setNativePreviewWindowId(renderer);
				});
		} else {
			mCandidates.erase(itCandidate);
		}
	}
	mCounterMutex.unlock();
}

void PreviewManager::unsubscribe(QObject *sender) {
	unsubscribe(dynamic_cast<CameraGui *>(sender));
}

void PreviewManager::activate() {
	App::postModelAsync([]() {
		lDebug() << "[PreviewManager] Activation";
		CoreModel::getInstance()->getCore()->enableVideoPreview(true);
	});
}

void PreviewManager::deactivate() {
	App::postModelAsync([]() {
		lDebug() << "[PreviewManager] Deactivation";
		CoreModel::getInstance()->getCore()->enableVideoPreview(false);
	});
}
