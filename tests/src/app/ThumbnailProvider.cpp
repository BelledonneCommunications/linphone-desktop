#include "Paths.hpp"
#include "../utils.hpp"

#include "ThumbnailProvider.hpp"

// =============================================================================

const QString ThumbnailProvider::PROVIDER_ID = "thumbnail";

ThumbnailProvider::ThumbnailProvider () : QQuickImageProvider(
    QQmlImageProviderBase::Image,
    QQmlImageProviderBase::ForceAsynchronousImageLoading
  ) {
  m_thumbnails_path = Utils::linphoneStringToQString(Paths::getThumbnailsDirPath());
}

QImage ThumbnailProvider::requestImage (const QString &id, QSize *, const QSize &) {
  return QImage(m_thumbnails_path + id);
}
