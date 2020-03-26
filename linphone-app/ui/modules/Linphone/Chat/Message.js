/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
// =============================================================================
// `Message.qml` Logic.
// =============================================================================

// See: `ensureVisible` on http://doc.qt.io/qt-5/qml-qtquick-textedit.html
function ensureVisible (cursor) {
  // Case 1: No focused.
  if (!message.activeFocus) {
    return
  }

  // Case 2: Scroll up.
  var contentItem = chat.contentItem
  var contentY = chat.contentY
  var messageY = message.mapToItem(contentItem, 0, 0).y + cursor.y

  if (contentY >= messageY) {
    chat.contentY = messageY
    return
  }

  // Case 3: Scroll down.
  var chatHeight = chat.height
  var cursorHeight = cursor.height

  if (contentY + chatHeight <= messageY + cursorHeight) {
    chat.contentY = messageY + cursorHeight - chatHeight
  }
}
