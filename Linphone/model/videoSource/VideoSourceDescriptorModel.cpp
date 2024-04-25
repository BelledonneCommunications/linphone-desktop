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

#include "VideoSourceDescriptorModel.hpp"
#include "tool/native/DesktopTools.hpp"
// =============================================================================

DEFINE_ABSTRACT_OBJECT(VideoSourceDescriptorModel)

VideoSourceDescriptorModel::VideoSourceDescriptorModel() {
}
VideoSourceDescriptorModel::VideoSourceDescriptorModel(std::shared_ptr<linphone::VideoSourceDescriptor> desc) {
	mDesc = desc;
	if (mDesc && mDesc->getScreenSharingType() == linphone::VideoSourceScreenSharingType::Display)
		mScreenIndex = DesktopTools::getDisplayIndex(mDesc->getScreenSharing());
}

void VideoSourceDescriptorModel::setScreenSharingDisplay(int index) {
	if (!mDesc) mDesc = linphone::Factory::get()->createVideoSourceDescriptor();
	mScreenIndex = index;
	mDesc->setScreenSharing(linphone::VideoSourceScreenSharingType::Display, DesktopTools::getDisplay(index));
	emit videoDescriptorChanged();
}

void VideoSourceDescriptorModel::setScreenSharingWindow(void *window) { // Get data from DesktopTools.
	if (!mDesc) mDesc = linphone::Factory::get()->createVideoSourceDescriptor();
	else if (getVideoSourceType() == LinphoneEnums::VideoSourceScreenSharingTypeWindow && window == getScreenSharing())
		return;
	mDesc->setScreenSharing(linphone::VideoSourceScreenSharingType::Window, window);
	emit videoDescriptorChanged();
}

void *VideoSourceDescriptorModel::getScreenSharing() const {
	if (!mDesc) return nullptr;
	else return mDesc->getScreenSharing();
}

quint64 VideoSourceDescriptorModel::getWindowId() const {
	if (!mDesc) return 0;
	else {
		void *temp = mDesc->getScreenSharing();
		return *(quint64 *)&temp;
	}
}

void VideoSourceDescriptorModel::setWindowId(quint64 id) {
	if (getWindowId() != id) {
		setScreenSharingWindow((void *)id);
	}
}

bool VideoSourceDescriptorModel::isScreenSharing() const {
	return mDesc && mDesc->getType() == linphone::VideoSourceType::ScreenSharing;
}

LinphoneEnums::VideoSourceScreenSharingType VideoSourceDescriptorModel::getVideoSourceType() const {
	return mDesc ? LinphoneEnums::fromLinphone(mDesc->getScreenSharingType())
	             : LinphoneEnums::VideoSourceScreenSharingType::VideoSourceScreenSharingTypeDisplay;
}

int VideoSourceDescriptorModel::getScreenSharingIndex() const {
	if (mDesc && mDesc->getScreenSharingType() == linphone::VideoSourceScreenSharingType::Display) {
		return mScreenIndex;
	} else return -1;
}
