/*
 * Camera.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#ifndef CAMERA_H_
#define CAMERA_H_

#include <QOpenGLFramebufferObject>
#include <QQuickFramebufferObject>

#include "../call/CallModel.hpp"

// =============================================================================

class Camera;
struct ContextInfo;

class CameraRenderer : public QQuickFramebufferObject::Renderer {
  friend class Camera;

public:
  CameraRenderer ();
  ~CameraRenderer ();

protected:
  QOpenGLFramebufferObject *createFramebufferObject (const QSize &size) override;
  void render () override;
  void synchronize (QQuickFramebufferObject *item) override;

private:
  ContextInfo *m_context_info;
  bool m_need_sync = false;

  bool m_is_preview = false;
  shared_ptr<linphone::Call> m_linphone_call;

  QQuickWindow *m_window;
};

// -----------------------------------------------------------------------------

class Camera : public QQuickFramebufferObject {
  friend class CameraRenderer;

  Q_OBJECT;

  Q_PROPERTY(CallModel * call READ getCall WRITE setCall NOTIFY callChanged);
  Q_PROPERTY(bool isPreview MEMBER m_is_preview NOTIFY isPreviewChanged);

public:
  Camera (QQuickItem *parent = Q_NULLPTR);
  ~Camera ();

  QQuickFramebufferObject::Renderer *createRenderer () const override;

signals:
  void callChanged (CallModel *call);
  void isPreviewChanged (bool is_preview);

protected:
  void mousePressEvent (QMouseEvent *event) override;

private:
  CallModel *getCall () const;
  void setCall (CallModel *call);

  bool m_is_preview = false;
  CallModel *m_call = nullptr;
};

#endif // CAMERA_H_
