import QtQuick 2.7

import Clipboard 1.0
import Common 1.0
import Linphone.Styles 1.0
import TextToSpeech 1.0
import Utils 1.0

import 'Message.js' as Logic

// =============================================================================

Item {
  id: container

  // ---------------------------------------------------------------------------

  property alias backgroundColor: rectangle.color
  property alias color: message.color
  property alias pointSize: message.font.pointSize

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

  // ---------------------------------------------------------------------------
  // Message.
  // ---------------------------------------------------------------------------

  TextEdit {
    id: message

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

    onCursorRectangleChanged: Logic.ensureVisible(cursorRectangle)
    onLinkActivated: Qt.openUrlExternally(link)

    onActiveFocusChanged: deselect()

    Menu {
      id: messageMenu

      MenuItem {
        text: qsTr('menuCopy')
        onTriggered: Clipboard.text = $chatEntry.content
      }

      MenuItem {
        enabled: TextToSpeech.available
        text: qsTr('menuPlayMe')

        onTriggered: TextToSpeech.say($chatEntry.content)
      }
    }

    // Handle hovered link.
    MouseArea {
      height: parent.height
      width: rectangle.width

      acceptedButtons: Qt.RightButton
      cursorShape: parent.hoveredLink
        ? Qt.PointingHandCursor
        : Qt.IBeamCursor

      onClicked: mouse.button === Qt.RightButton && messageMenu.open()
    }
  }

  // ---------------------------------------------------------------------------
  // Extra content.
  // ---------------------------------------------------------------------------

  Item {
    id: content

    anchors {
      left: rectangle.right
      leftMargin: ChatStyle.entry.message.extraContent.leftMargin
    }
  }
}
