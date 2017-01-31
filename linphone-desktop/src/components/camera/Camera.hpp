#ifndef CAMERA_H_
#define CAMERA_H_

#include <QOpenGLFramebufferObject>
#include <QQuickFramebufferObject>

#include "../call/CallModel.hpp"

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

public:
  Camera (QQuickItem *parent = Q_NULLPTR);
  ~Camera ();

  QQuickFramebufferObject::Renderer *createRenderer () const override;

signals:
  void callChanged (CallModel *call);

protected:
  void hoverMoveEvent (QHoverEvent *event) override;
  void mousePressEvent (QMouseEvent *event) override;

  void keyPressEvent (QKeyEvent *event) override;

private:
  CallModel *getCall () const;
  void setCall (CallModel *call);

  CallModel *m_call = nullptr;

  ContextInfo *m_context_info;
};

#endif // CAMERA_H_
