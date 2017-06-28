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

#include <memory>

#include <QQuickFramebufferObject>

// =============================================================================

class CallModel;
struct ContextInfo;

namespace linphone {
  class Call;
}

class CameraRenderer : public QQuickFramebufferObject::Renderer {
public:
  CameraRenderer ();
  ~CameraRenderer ();

protected:
  QOpenGLFramebufferObject *createFramebufferObject (const QSize &size) override;
  void render () override;
  void synchronize (QQuickFramebufferObject *item) override;

private:
  void updateWindowId ();
  bool notifyReceivedVideoSize () const;

  ContextInfo *mContextInfo;
  bool mUpdateContextInfo = false;

  bool mNotifyReceivedVideoSize = true;
  bool mIsPreview = false;
  std::shared_ptr<linphone::Call> mCall;

  QQuickWindow *mWindow = nullptr;
};

// -----------------------------------------------------------------------------

class Camera : public QQuickFramebufferObject {
  friend class CameraRenderer;

  Q_OBJECT;

  Q_PROPERTY(CallModel * call READ getCallModel WRITE setCallModel NOTIFY callChanged);
  Q_PROPERTY(bool isPreview READ getIsPreview WRITE setIsPreview NOTIFY isPreviewChanged);

public:
  Camera (QQuickItem *parent = Q_NULLPTR);
  ~Camera () = default;

  QQuickFramebufferObject::Renderer *createRenderer () const override;

signals:
  void callChanged (CallModel *callModel);
  void isPreviewChanged (bool isPreview);

private:
  CallModel *getCallModel () const;
  void setCallModel (CallModel *callModel);

  bool getIsPreview () const;
  void setIsPreview (bool status);

  bool mIsPreview = false;
  CallModel *mCallModel = nullptr;

  QTimer *mRefreshTimer = nullptr;
};

#endif // CAMERA_H_
