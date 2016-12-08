import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0
import Utils 1.0

// ===================================================================

Item {
  id: container

  property alias backgroundColor: rectangle.color
  property alias color: text.color
  property alias fontSize: text.font.pointSize

  default property alias _content: content.data

  // -----------------------------------------------------------------

  function _handleHoveredLink (hoveredLink) {
    // Can be the `invertedMouseArea` of other message.
    // Or another mouse area. Dangerous?
    var mouseArea = Utils.find(
      Utils.getTopParent(container).children,
      function (element) {
        return Utils.qmlTypeof(element, 'QQuickMouseArea')
      }
    )

    if (mouseArea != null) {
      mouseArea.cursorShape = hoveredLink
        ? Qt.PointingHandCursor
        : Qt.ArrowCursor
    }
  }

  // -----------------------------------------------------------------

  implicitHeight: text.contentHeight + text.padding * 2

  Rectangle {
    id: rectangle

    height: parent.height
    radius: ChatStyle.entry.message.radius
    width: (
      text.contentWidth < parent.width
        ? text.contentWidth
        : parent.width
    ) + text.padding * 2
  }

  TextEdit {
    id: text

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

    onHoveredLinkChanged: _handleHoveredLink(hoveredLink)
    onLinkActivated: Qt.openUrlExternally(link)

    InvertedMouseArea {
      anchors.fill: parent
      enabled: parent.activeFocus

      onPressed: {
        parent.deselect()
        parent.focus = false
      }
    }

    // Used if no InvertedMouseArea exists.
    MouseArea {
      id: mouseArea

      anchors.fill: parent
      acceptedButtons: Qt.NoButton
      cursorShape: parent.hoveredLink
        ? Qt.PointingHandCursor
        : Qt.ArrowCursor
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
