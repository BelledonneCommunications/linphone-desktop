/*
 * Copyright (c) 2024 Belledonne Communications SARL.
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

#ifndef PREVIEW_MANAGER_H_
#define PREVIEW_MANAGER_H_

#include "CameraGui.hpp"
#include "tool/AbstractObject.hpp"
#include <QMutex>
#include <QObject>
#include <QPair>
#include <QQuickFramebufferObject>

// Manage the SDK preview as a singleton.
// The goal is to process the limitation that only one preview can be displayed.
// On asynchronized application, the destruction of a previous Preview can be done AFTER the creation on a new Preview
// Sticker.

// =============================================================================

class PreviewManager : public QObject, public AbstractObject {
	Q_OBJECT
public:
	PreviewManager(QObject *parent = nullptr);
	virtual ~PreviewManager();

	static PreviewManager *getInstance();

	QQuickFramebufferObject::Renderer *subscribe(const CameraGui *candidate);
	void unsubscribe(const CameraGui *candidate);

	void activate();
	void deactivate();
public slots:
	void unsubscribe(QObject *sender);

private:
	QMutex mCounterMutex;
	QList<QPair<const CameraGui *, QQuickFramebufferObject::Renderer *>> mCandidates;
	static PreviewManager *gInstance;
	QQuickFramebufferObject::Renderer *mPreviewRenderer = nullptr;
	DECLARE_ABSTRACT_OBJECT
};

#endif
