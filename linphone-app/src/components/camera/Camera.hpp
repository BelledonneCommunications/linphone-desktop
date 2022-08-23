/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#ifndef CAMERA_H_
#define CAMERA_H_

#include <memory>

#include <QQuickFramebufferObject>
#include <mediastreamer2/msogl.h>
#include <QMutex>
#include <QTimer>

// =============================================================================

namespace linphone {
	class Call;
}

class CallModel;
class ParticipantDeviceModel;
// -----------------------------------------------------------------------------

class Camera : public QQuickFramebufferObject {
	Q_OBJECT
	
	Q_PROPERTY(CallModel * call READ getCallModel WRITE setCallModel NOTIFY callChanged);
	Q_PROPERTY(ParticipantDeviceModel * participantDeviceModel READ getParticipantDeviceModel WRITE setParticipantDeviceModel NOTIFY participantDeviceModelChanged)
	Q_PROPERTY(bool isPreview READ getIsPreview WRITE setIsPreview NOTIFY isPreviewChanged);
	Q_PROPERTY(bool isReady READ getIsReady WRITE setIsReady NOTIFY isReadyChanged);

	typedef enum{
		None = -1,
		CorePreview = 0,
		Call,
		Device,
		Core
	}WindowIdLocation;
	
public:
	Camera (QQuickItem *parent = Q_NULLPTR);
	virtual ~Camera();
	
	QQuickFramebufferObject::Renderer *createRenderer () const override;
	
	Q_INVOKABLE void resetWindowId() const;	// const to be used from createRenderer()
	void checkVideoDefinition();
	
	static QMutex mPreviewCounterMutex;
	static int mPreviewCounter;
	
	void isReady();
	void isNotReady();
public slots:
	void onCallStateChanged();
	
signals:
	void callChanged (CallModel *callModel);
	void isPreviewChanged (bool isPreview);
	void isReadyChanged();
	void participantDeviceModelChanged(ParticipantDeviceModel *participantDeviceModel);
	void requestNewRenderer();
	void videoDefinitionChanged();
	
private:
	CallModel *getCallModel () const;
	bool getIsPreview () const;
	bool getIsReady () const;
	ParticipantDeviceModel * getParticipantDeviceModel() const;
	
	void setCallModel (CallModel *callModel);
	void setIsPreview (bool status);
	void setIsReady(bool status);
	void setParticipantDeviceModel(ParticipantDeviceModel * participantDeviceModel);
	void setWindowIdLocation(const WindowIdLocation& location);
	
	void activatePreview();
	void deactivatePreview();
	void updateWindowIdLocation();
	void removeParticipantDeviceModel();
	
	QVariantMap mLastVideoDefinition;
	QTimer mLastVideoDefinitionChecker;
	
	bool mIsPreview = false;
	bool mIsReady = false;
	CallModel *mCallModel = nullptr;
	ParticipantDeviceModel *mParticipantDeviceModel = nullptr;

	WindowIdLocation mWindowIdLocation = None;
	mutable bool mIsWindowIdSet = false;
	
	QTimer *mRefreshTimer = nullptr;
};

#endif // CAMERA_H_
