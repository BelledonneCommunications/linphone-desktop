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

#ifndef VIDEO_SOURCE_DESCRIPTOR_CORE_H_
#define VIDEO_SOURCE_DESCRIPTOR_CORE_H_

#include <linphone++/linphone.hh>
// =============================================================================
#include <QDateTime>
#include <QObject>
#include <QSharedPointer>
#include <QString>

#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"

#include "model/videoSource/VideoSourceDescriptorModel.hpp"

class VideoSourceDescriptorCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(int screenSharingIndex READ getScreenSharingIndex WRITE lSetScreenIndex NOTIFY screenIndexChanged)
	Q_PROPERTY(quint64 windowId READ getWindowId WRITE lSetWindowId NOTIFY windowIdChanged)
public:
	static QSharedPointer<VideoSourceDescriptorCore>
	create(const std::shared_ptr<linphone::VideoSourceDescriptor> &desc);
	VideoSourceDescriptorCore(const std::shared_ptr<linphone::VideoSourceDescriptor> &desc);
	virtual ~VideoSourceDescriptorCore();
	void setSelf(QSharedPointer<VideoSourceDescriptorCore> me);

	int getScreenSharingIndex() const;
	void setScreenSharingDisplay(int index);

	quint64 getWindowId() const;
	void setWindowId(quint64 id);

	std::shared_ptr<VideoSourceDescriptorModel> getModel();

signals:
	void videoDescriptorChanged();
	void windowIdChanged();
	void screenIndexChanged();

	void lSetWindowId(quint64 windowId);
	void lSetScreenIndex(int index);

private:
	int mScreenIndex = 0;
	quint64 mWindowId = 0;
	std::shared_ptr<VideoSourceDescriptorModel> mVideoDescModel;
	QSharedPointer<SafeConnection<VideoSourceDescriptorCore, VideoSourceDescriptorModel>> mVideoDescModelConnection;
	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(VideoSourceDescriptorCore *)
#endif
