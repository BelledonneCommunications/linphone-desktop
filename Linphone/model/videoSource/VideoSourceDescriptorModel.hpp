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

#ifndef VIDEO_SOURCE_DESCRIPTOR_MODEL_H_
#define VIDEO_SOURCE_DESCRIPTOR_MODEL_H_

// =============================================================================
#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"

#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

class VideoSourceDescriptorModel : public QObject, public AbstractObject {
	Q_OBJECT

public:
	VideoSourceDescriptorModel();
	VideoSourceDescriptorModel(std::shared_ptr<linphone::VideoSourceDescriptor> desc);
	void setScreenSharingDisplay(int index);
	void setScreenSharingWindow(void *window); // Get data from DesktopTools.
	void *getScreenSharing() const;

	quint64 getWindowId() const;
	void setWindowId(quint64 id);

	bool isScreenSharing() const;
	LinphoneEnums::VideoSourceScreenSharingType getVideoSourceType() const;
	int getScreenSharingIndex() const;

	std::shared_ptr<linphone::VideoSourceDescriptor> mDesc;
	int mScreenIndex = -1;

signals:
	void videoDescriptorChanged();

private:
	DECLARE_ABSTRACT_OBJECT
};
#endif
