#ifndef THUMBNAIL_PROVIDER_H_
#define THUMBNAIL_PROVIDER_H_

#include <QQuickImageProvider>

// =============================================================================

class ThumbnailProvider : public QQuickImageProvider {
public:
  ThumbnailProvider ();
  ~ThumbnailProvider () = default;

  QImage requestImage (const QString &id, QSize *size, const QSize &requested_size) override;

  static const QString PROVIDER_ID;

private:
  QString m_thumbnails_path;
};

#endif // THUMBNAIL_PROVIDER_H_
