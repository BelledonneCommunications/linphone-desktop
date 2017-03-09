import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Item {
  id: container

  // ---------------------------------------------------------------------------

  property alias backgroundColor: rectangle.color
  property alias color: message.color
  property alias fontSize: message.font.pointSize

  default property alias _content: content.data

  // ---------------------------------------------------------------------------

  implicitHeight: message.contentHeight + message.padding * 2

  Rectangle {
    id: rectangle

    height: parent.height
    radius: ChatStyle.entry.message.radius
    width: (
      message.contentWidth < parent.width
        ? message.contentWidth
        : parent.width
    ) + message.padding * 2
  }

  TextEdit {
    id: message

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

    anchors {
      left: container.left
      right: container.right
    }
    clip: true
    padding: ChatStyle.entry.message.padding
    readOnly: true
    selectByMouse: true
    text: Utils.encodeTextToQmlRichFormat($chatEntry.content, {
      imagesHeight: ChatStyle.entry.message.images.height,
      imagesWidth: ChatStyle.entry.message.images.width
    })

    // See http://doc.qt.io/qt-5/qml-qtquick-text.html#textFormat-prop
    // and http://doc.qt.io/qt-5/richtext-html-subset.html
    textFormat: Text.RichText // To supports links and imgs.
    wrapMode: TextEdit.Wrap

    onCursorRectangleChanged: ensureVisible(cursorRectangle)
    onLinkActivated: Qt.openUrlExternally(link)

    onActiveFocusChanged: deselect()

    // Handle hovered link.
    MouseArea {
      id: mouseArea

      anchors.fill: parent
      acceptedButtons: Qt.NoButton
      cursorShape: parent.hoveredLink
        ? Qt.PointingHandCursor
        : Qt.IBeamCursor
    }
  }

  Item {
    id: content

    anchors {
      left: rectangle.right
      leftMargin: ChatStyle.entry.message.extraContent.leftMargin
    }
  }
}
