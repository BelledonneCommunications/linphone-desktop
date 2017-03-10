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
