/*
 * Clipboard.cpp
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

#include <QClipboard>
#include <QGuiApplication>

#include "Clipboard.hpp"

// =============================================================================

Clipboard::Clipboard (QObject *parent) : QObject(parent) {
  connect(QGuiApplication::clipboard(), &QClipboard::dataChanged, this, &Clipboard::textChanged);
}

QString Clipboard::getText () const {
  return QGuiApplication::clipboard()->text(QClipboard::Clipboard);
}

void Clipboard::setText (const QString &text) {
  QGuiApplication::clipboard()->setText(text, QClipboard::Clipboard);
}
