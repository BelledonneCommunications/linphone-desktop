#ifndef AVATAR_PROVIDER_H_
#define AVATAR_PROVIDER_H_

#include <QQuickImageProvider>

// ===================================================================

class AvatarProvider : public QQuickImageProvider {
public:
  AvatarProvider ();
  ~AvatarProvider () = default;

  QImage requestImage (
    const QString &id,
    QSize *size,
    const QSize &requested_size
  ) override;

private:
  QString m_avatars_path;
};

#endif // AVATAR_PROVIDER_H_
