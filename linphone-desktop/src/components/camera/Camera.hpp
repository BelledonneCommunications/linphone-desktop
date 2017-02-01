#ifndef CAMERA_H_
#define CAMERA_H_

#include "../call/CallModel.hpp"

#include <QOpenGLFramebufferObject>
#include <QQuickFramebufferObject>

// =============================================================================

class Camera;
struct ContextInfo;

class CameraRenderer : public QQuickFramebufferObject::Renderer {
public:
  CameraRenderer (const Camera *camera);
  ~CameraRenderer () = default;

  QOpenGLFramebufferObject *createFramebufferObject (const QSize &size) override;

  void render () override;

private:
  const Camera *m_camera;
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
  ContextInfo *m_context_info;
};

#endif // CAMERA_H_
