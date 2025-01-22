/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#include "VideoSourceDescriptorCore.hpp"
#include "core/App.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

// =============================================================================

DEFINE_ABSTRACT_OBJECT(VideoSourceDescriptorCore)

QSharedPointer<VideoSourceDescriptorCore>
VideoSourceDescriptorCore::create(const std::shared_ptr<linphone::VideoSourceDescriptor> &desc) {
	auto sharedPointer =
	    QSharedPointer<VideoSourceDescriptorCore>(new VideoSourceDescriptorCore(desc), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

VideoSourceDescriptorCore::VideoSourceDescriptorCore(const std::shared_ptr<linphone::VideoSourceDescriptor> &desc) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mustBeInLinphoneThread(getClassName());
	mVideoDescModel = Utils::makeQObject_ptr<VideoSourceDescriptorModel>(desc);
	mScreenIndex = mVideoDescModel->getScreenSharingIndex();
	mWindowId = mVideoDescModel->getWindowId();
}

VideoSourceDescriptorCore::~VideoSourceDescriptorCore() {
}

void VideoSourceDescriptorCore::setSelf(QSharedPointer<VideoSourceDescriptorCore> me) {
	mVideoDescModelConnection =
	    SafeConnection<VideoSourceDescriptorCore, VideoSourceDescriptorModel>::create(me, mVideoDescModel);
	mVideoDescModelConnection->makeConnectToCore(&VideoSourceDescriptorCore::lSetWindowId, [this](quint64 id) {
		mVideoDescModelConnection->invokeToModel([this, id]() { mVideoDescModel->setScreenSharingWindow((void *)id); });
	});
	mVideoDescModelConnection->makeConnectToCore(&VideoSourceDescriptorCore::lSetScreenIndex, [this](int index) {
		mVideoDescModelConnection->invokeToModel([this, index]() { mVideoDescModel->setScreenSharingDisplay(index); });
	});

	mVideoDescModelConnection->makeConnectToModel(&VideoSourceDescriptorModel::videoDescriptorChanged, [this]() {
		auto id = mVideoDescModel->getWindowId();
		auto index = mVideoDescModel->getScreenSharingIndex();
		mVideoDescModelConnection->invokeToCore([this, id, index]() {
			setWindowId(id);
			setScreenSharingDisplay(index);
		});
	});
}

quint64 VideoSourceDescriptorCore::getWindowId() const {
	return mWindowId;
}

void VideoSourceDescriptorCore::setWindowId(quint64 id) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mWindowId != id) {
		mWindowId = id;
		if (mWindowId != 0 && mScreenIndex >= 0) setScreenSharingDisplay(-1);
		emit windowIdChanged();
	}
}

int VideoSourceDescriptorCore::getScreenSharingIndex() const {
	return mScreenIndex;
}

void VideoSourceDescriptorCore::setScreenSharingDisplay(int data) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mScreenIndex != data) {
		mScreenIndex = data;
		if (mScreenIndex >= 0 && mWindowId != 0) setWindowId(0);
		emit screenIndexChanged();
	}
}

std::shared_ptr<VideoSourceDescriptorModel> VideoSourceDescriptorCore::getModel() {
	return mVideoDescModel;
}
