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

#ifndef CAMERA_PREVIEW_H_
#define CAMERA_PREVIEW_H_

#include <QMutex>
#include <QQuickFramebufferObject>

// =============================================================================

class CameraPreview;
struct ContextInfo;

class CameraPreviewRenderer : public QQuickFramebufferObject::Renderer {
  friend class CameraPreview;

public:
  CameraPreviewRenderer ();
  ~CameraPreviewRenderer ();

protected:
  QOpenGLFramebufferObject *createFramebufferObject (const QSize &size) override;
  void render () override;
  void synchronize (QQuickFramebufferObject *item) override;

private:
  void updateWindowId ();

  ContextInfo *mContextInfo;
  bool mUpdateContextInfo = false;

  QQuickWindow *mWindow = nullptr;
};

// -----------------------------------------------------------------------------

class CameraPreview : public QQuickFramebufferObject {
  friend class CameraPreviewRenderer;

  Q_OBJECT;

public:
  CameraPreview (QQuickItem *parent = Q_NULLPTR);
  ~CameraPreview ();

  QQuickFramebufferObject::Renderer *createRenderer () const override;

private:
  QTimer *mRefreshTimer = nullptr;

  static QMutex mCounterMutex;
  static int mCounter;
};

#endif // CAMERA_PREVIEW_H_
