#include <QOpenGLFunctions>

#include "Camera.hpp"

#define ATTRIBUTE_VERTEX 0

// =============================================================================

static const char *_vertex_shader = "attribute vec2 vertex;"
  "uniform mat4 projection;"
  "void main() {"
  "   gl_Position = projection * vec4(vertex.xy, 0, 1);"
  "}";

static const char *_fragment_shader = "void main() {"
  "   gl_FragColor = vec4(vec3(1.0, 0.0, 0.0), 1.0);"
  "}";

static const GLfloat _camera_vertices[] = {
  0.0f, 0.0f,
  50.0f, 0.0f,
  0.0f, 50.0f,
  50.0f, 50.0f
};

// -----------------------------------------------------------------------------

struct CameraStateBinder {
  CameraStateBinder (CameraRenderer *renderer) : m_renderer(renderer) {
    QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();

    f->glEnable(GL_DEPTH_TEST);
    f->glEnable(GL_CULL_FACE);
    f->glDepthMask(GL_TRUE);
    f->glDepthFunc(GL_LESS);
    f->glFrontFace(GL_CCW);
    f->glCullFace(GL_BACK);

    m_renderer->m_program->bind();
  }

  ~CameraStateBinder () {
    m_renderer->m_program->release();

    QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();
    f->glDisable(GL_CULL_FACE);
    f->glDisable(GL_DEPTH_TEST);
  }

  CameraRenderer *m_renderer;
};

// -----------------------------------------------------------------------------

QOpenGLFramebufferObject *CameraRenderer::createFramebufferObject (const QSize &size) {
  m_projection.setToIdentity();
  m_projection.ortho(
    0, size.width(),
    0, size.height(),
    -1, 1
  );

  QOpenGLFramebufferObjectFormat format;
  format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
  format.setSamples(4);

  return new QOpenGLFramebufferObject(size, format);
}

void CameraRenderer::render () {
  init();

  m_vao.bind();

  CameraStateBinder state(this);

  QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();
  f->glClearColor(0.f, 0.f, 0.f, 1.f);
  f->glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  m_program->setUniformValue(m_projection_loc, m_projection);

  // Draw.
  f->glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

  m_vao.release();
}

void CameraRenderer::init () {
  if (m_inited)
    return;

  m_inited = true;

  initProgram();
  initBuffer();
}

void CameraRenderer::initBuffer () {
  QOpenGLVertexArrayObject::Binder vaoBinder(&m_vao);

  m_vbo.create();
  m_vbo.bind();
  m_vbo.allocate(&_camera_vertices, sizeof _camera_vertices);

  m_vbo.bind();
  QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();
  f->glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
  f->glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
  m_vbo.release();
}

void CameraRenderer::initProgram () {
  m_program.reset(new QOpenGLShaderProgram());
  m_program->addShaderFromSourceCode(QOpenGLShader::Vertex, _vertex_shader);
  m_program->addShaderFromSourceCode(QOpenGLShader::Fragment, _fragment_shader);
  m_program->bindAttributeLocation("vertex", ATTRIBUTE_VERTEX);
  m_program->link();

  m_projection_loc = m_program->uniformLocation("projection");
}

// -----------------------------------------------------------------------------

Camera::Camera (QQuickItem *parent) : QQuickFramebufferObject(parent) {
  setAcceptHoverEvents(true);
  setAcceptedMouseButtons(Qt::LeftButton | Qt::RightButton);
}

QQuickFramebufferObject::Renderer *Camera::createRenderer () const {
  return new CameraRenderer();
}

void Camera::hoverMoveEvent (QHoverEvent *) {}

void Camera::mousePressEvent (QMouseEvent *) {
  setFocus(true);
}

void Camera::keyPressEvent (QKeyEvent *) {}
