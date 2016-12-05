#include "Database.hpp"
#include "../utils.hpp"

#include "AvatarProvider.hpp"

// ===================================================================

AvatarProvider::AvatarProvider () :
  QQuickImageProvider(
    QQmlImageProviderBase::Image,
    QQmlImageProviderBase::ForceAsynchronousImageLoading
  ) {
  m_avatars_path = Utils::linphoneStringToQString(Database::getAvatarsPath());
}

QImage AvatarProvider::requestImage (
  const QString &id,
  QSize *size,
  const QSize &requested_size
) {
  // TODO: use a shared image from contact.
}
