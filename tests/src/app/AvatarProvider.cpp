#include "Database.hpp"
#include "../utils.hpp"

#include "AvatarProvider.hpp"

// ===================================================================

const QString AvatarProvider::PROVIDER_ID = "avatar";

AvatarProvider::AvatarProvider () :
  QQuickImageProvider(
    QQmlImageProviderBase::Image,
    QQmlImageProviderBase::ForceAsynchronousImageLoading
  ) {
  m_avatars_path = Utils::linphoneStringToQString(Database::getAvatarsPath());
}

QImage AvatarProvider::requestImage (
  const QString &id,
  QSize *,
  const QSize &
) {
  return QImage(m_avatars_path + id);
}
