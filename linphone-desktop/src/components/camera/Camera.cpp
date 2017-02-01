#include "Camera.hpp"

#include <QOpenGLFunctions>
#include <QOpenGLTexture>

#include "../core/CoreManager.hpp"

#include "Camera.hpp"

// =============================================================================

struct CameraStateBinder {
  CameraStateBinder (CameraRenderer *renderer) : m_renderer(renderer) {
    QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();

    f->glEnable(GL_DEPTH_TEST);
    f->glEnable(GL_CULL_FACE);
    f->glDepthMask(GL_TRUE);
    f->glDepthFunc(GL_LESS);
    f->glFrontFace(GL_CCW);
    f->glCullFace(GL_BACK);
  }

  ~CameraStateBinder () {
    QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();

    f->glDisable(GL_CULL_FACE);
    f->glDisable(GL_DEPTH_TEST);
  }

  CameraRenderer *m_renderer;
};

// -----------------------------------------------------------------------------

struct ContextInfo {
  GLuint width;
  GLuint height;
};

// -----------------------------------------------------------------------------

CameraRenderer::CameraRenderer (const Camera *camera) : m_camera(camera) {}

QOpenGLFramebufferObject *CameraRenderer::createFramebufferObject (const QSize &size) {
  QOpenGLFramebufferObjectFormat format;
  format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
  format.setInternalTextureFormat(GL_RGBA8);
  format.setSamples(4);

  ContextInfo *context_info = m_camera->m_context_info;
  context_info->width = size.width();
  context_info->height = size.height();

  shared_ptr<linphone::Call> linphone_call = m_camera->m_call->getLinphoneCall();
  linphone::CallState state = linphone_call->getState();

  if (state == linphone::CallStateConnected || state == linphone::CallStateStreamsRunning) {
    if (m_camera->m_is_preview)
      CoreManager::getInstance()->getCore()->setNativePreviewWindowId(context_info);
    else
      linphone_call->setNativeVideoWindowId(context_info);
  }

  return new QOpenGLFramebufferObject(size, format);
}

void CameraRenderer::render () {
  CameraStateBinder state(this);

  QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();

  f->glClearColor(0.f, 0.f, 0.f, 0.f);
  f->glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  m_camera->getCall()->getLinphoneCall()->oglRender(m_camera->m_is_preview);

  update();
}

// -----------------------------------------------------------------------------

Camera::Camera (QQuickItem *parent) : QQuickFramebufferObject(parent) {
  setAcceptHoverEvents(true);
  setAcceptedMouseButtons(Qt::LeftButton | Qt::RightButton);

  // The fbo content must be y-mirrored because the ms rendering is y-inverted.
  setMirrorVertically(true);

  m_context_info = new ContextInfo();
}

Camera::~Camera () {
  delete m_context_info;
}

QQuickFramebufferObject::Renderer *Camera::createRenderer () const {
  return new CameraRenderer(this);
}

void Camera::mousePressEvent (QMouseEvent *) {
  setFocus(true);
}

// -----------------------------------------------------------------------------

CallModel *Camera::getCall () const {
  return m_call;
}

void Camera::setCall (CallModel *call) {
  if (m_call != call) {
    if (call) {
      shared_ptr<linphone::Call> linphone_call = call->getLinphoneCall();
      linphone::CallState state = linphone_call->getState();

      if (state == linphone::CallStateConnected || state == linphone::CallStateStreamsRunning) {
        if (m_is_preview)
          CoreManager::getInstance()->getCore()->setNativePreviewWindowId(m_context_info);
        else
          linphone_call->setNativeVideoWindowId(m_context_info);
      }
    }

    m_call = call;

    emit callChanged(call);
  }
}
