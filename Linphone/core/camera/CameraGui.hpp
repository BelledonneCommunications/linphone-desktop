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

// =============================================================================

class CallGui;

class CameraGui : public QQuickFramebufferObject, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(bool isReady READ getIsReady NOTIFY isReadyChanged)
	Q_PROPERTY(CallGui *call READ getCallGui WRITE setCallGui NOTIFY callGuiChanged);

public:
	CameraGui(QQuickItem *parent = Q_NULLPTR);
	virtual ~CameraGui();
	QQuickFramebufferObject::Renderer *createRenderer() const override;

	bool getIsReady() const;
	void setIsReady(bool isReady);
	void isReady();
	void isNotReady();

	CallGui *getCallGui() const;
	void setCallGui(CallGui *callGui);

	typedef enum { None = -1, CorePreview = 0, Call, Device, Player, Core } WindowIdLocation;
	WindowIdLocation getSourceLocation() const;

signals:
	void requestNewRenderer();
	void isReadyChanged(bool isReady);
	void callGuiChanged(CallGui *callGui);

private:
	bool mIsReady = false;
	QTimer mRefreshTimer;
	int mMaxFps = 30;
	CallGui *mCallGui = nullptr;

	DECLARE_ABSTRACT_OBJECT
};

#endif
