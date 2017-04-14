/*
 * ThumbnailProvider.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#ifndef THUMBNAIL_PROVIDER_H_
#define THUMBNAIL_PROVIDER_H_

#include <QQuickImageProvider>

// =============================================================================

class ThumbnailProvider : public QQuickImageProvider {
public:
  ThumbnailProvider ();
  ~ThumbnailProvider () = default;

  QImage requestImage (const QString &id, QSize *size, const QSize &requestedSize) override;

  static const QString PROVIDER_ID;

private:
  QString mThumbnailsPath;
};

#endif // THUMBNAIL_PROVIDER_H_
