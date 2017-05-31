/*
 * Clipboard.hpp
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
 *  Created on: May 30, 2017
 *      Author: Ronan Abhamon
 */

#ifndef CLIPBOARD_H_
#define CLIPBOARD_H_

#include <QObject>

// =============================================================================

class Clipboard : public QObject {
  Q_OBJECT;

  Q_PROPERTY(QString text READ getText WRITE setText NOTIFY textChanged);

public:
  Clipboard (QObject *parent = Q_NULLPTR);
  ~Clipboard () = default;

signals:
  void textChanged ();

private:

  QString getText () const;
  void setText (const QString &text);
};

#endif // ifndef CLIPBOARD_H_
