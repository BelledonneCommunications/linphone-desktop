#ifndef CAMERA_H_
#define CAMERA_H_

#include <QOpenGLBuffer>
#include <QOpenGLFramebufferObject>
#include <QOpenGLShaderProgram>
#include <QOpenGLVertexArrayObject>
#include <QQuickFramebufferObject>

// =============================================================================

class CameraRenderer : public QQuickFramebufferObject::Renderer {
  friend struct CameraStateBinder;

public:
  QOpenGLFramebufferObject *createFramebufferObject (const QSize &size) override;

  void render () override;

private:
  void init ();
  void initBuffer ();
  void initProgram ();

  bool m_inited = false;

  QMatrix4x4 m_projection;
  int m_projection_loc;

  QOpenGLVertexArrayObject m_vao;
  QOpenGLBuffer m_vbo;
  QScopedPointer<QOpenGLShaderProgram> m_program;
};

// -----------------------------------------------------------------------------

class Camera : public QQuickFramebufferObject {
  Q_OBJECT;

public:
  Camera (QQuickItem *parent = Q_NULLPTR);
  ~Camera () = default;

  QQuickFramebufferObject::Renderer *createRenderer () const override;

protected:
  void hoverMoveEvent (QHoverEvent *event) override;
  void mousePressEvent (QMouseEvent *event) override;

  void keyPressEvent (QKeyEvent *event) override;
};

#endif // CAMERA_H_
