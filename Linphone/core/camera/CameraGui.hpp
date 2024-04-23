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

#ifndef CAMERA_GUI_H_
#define CAMERA_GUI_H_

#include <memory>

#include "tool/AbstractObject.hpp"
#include <QMutex>
#include <QQuickFramebufferObject>
#include <QTimer>

#include "core/participant/ParticipantDeviceGui.hpp"
// =============================================================================

class CallGui;

class CameraGui : public QQuickFramebufferObject, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(CallGui *call READ getCallGui WRITE setCallGui NOTIFY callGuiChanged)
	Q_PROPERTY(ParticipantDeviceGui *participantDevice READ getParticipantDeviceGui WRITE setParticipantDeviceGui NOTIFY
	               participantDeviceGuiChanged)
	Q_PROPERTY(bool isPreview READ getIsPreview WRITE setIsPreview NOTIFY isPreviewChanged)
	Q_PROPERTY(bool isReady READ getIsReady WRITE setIsReady NOTIFY isReadyChanged)
	// Q_PROPERTY(SoundPlayer * linphonePlayer READ getLinphonePlayer WRITE setLinphonePlayer NOTIFY
	// linphonePlayerChanged)

	typedef enum { None = -1, CorePreview = 0, Call, Device, Player, Core } WindowIdLocation;

public:
	CameraGui(QQuickItem *parent = Q_NULLPTR);
	virtual ~CameraGui();
	QQuickFramebufferObject::Renderer *createRenderer() const override;

	Q_INVOKABLE void resetWindowId();
	void checkVideoDefinition();

	bool getIsReady() const;
	void setIsReady(bool isReady);
	void isReady();
	void isNotReady();
	bool getIsPreview() const;
	void setIsPreview(bool status);

	CallGui *getCallGui() const;
	void setCallGui(CallGui *callGui);
	ParticipantDeviceGui *getParticipantDeviceGui() const;
	void setParticipantDeviceGui(ParticipantDeviceGui *participantDeviceGui);
	WindowIdLocation getSourceLocation() const;
	void setWindowIdLocation(const WindowIdLocation &location);

	void updateWindowIdLocation();
	void removeParticipantDeviceModel();
	void removeCallModel();
	void removeLinphonePlayer();

	void callStateChanged(LinphoneEnums::CallState state);

	void setRenderer(QQuickFramebufferObject::Renderer *);
	void refreshLastRenderer(); // Lookup in stocked renderer and link it.
	void clearRenderer();
	void updateSDKRenderer();
	void updateSDKRenderer(QQuickFramebufferObject::Renderer *renderer);

signals:
	void requestNewRenderer();
	void isReadyChanged(bool isReady);
	void callGuiChanged(CallGui *callGui);
	void isPreviewChanged(bool isPreview);
	void isReadyChanged();
	void participantDeviceGuiChanged(ParticipantDeviceGui *participantDeviceGui);
	void videoDefinitionChanged();
	// void linphonePlayerChanged(SoundPlayer * linphonePlayer);

private:
	bool mIsPreview = false;
	bool mIsReady = false;
	QTimer mRefreshTimer;
	int mMaxFps = 30;
	QVariantMap mLastVideoDefinition;
	QTimer mLastVideoDefinitionChecker;
	CallGui *mCallGui = nullptr;
	ParticipantDeviceGui *mParticipantDeviceGui = nullptr;

	QQuickFramebufferObject::Renderer *mLastRenderer = nullptr;

	WindowIdLocation mWindowIdLocation = None;
	mutable bool mIsWindowIdSet = false;

	DECLARE_ABSTRACT_OBJECT
	DECLARE_GUI_OBJECT
};

#endif
