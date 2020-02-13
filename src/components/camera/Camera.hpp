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

// =============================================================================

namespace linphone {
  class Call;
}

class CallModel;
struct ContextInfo;

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
