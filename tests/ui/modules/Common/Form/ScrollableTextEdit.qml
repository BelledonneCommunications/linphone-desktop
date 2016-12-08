import QtQuick 2.7
import QtQuick 2.7 as Quick

import Common 1.0
import Common.Styles 1.0

// ===================================================================

Item {
  property alias text: textEdit.text
  property alias font: textEdit.font
  property alias color: textEdit.color

  signal editingFinished

  // -----------------------------------------------------------------

  function _handleEditingFinished () {
    textEdit.cursorPosition = 0
    editingFinished()
  }

  // -----------------------------------------------------------------

  Rectangle {
    anchors.fill: flick
    color: textEdit.activeFocus && !textEdit.readOnly
      ? TextEditStyle.backgroundColor.focused
      : TextEditStyle.backgroundColor.normal

    InvertedMouseArea {
      anchors.fill: parent
      enabled: textEdit.activeFocus
      onPressed: textEdit.focus = false
    }
  }

  Flickable {
    id: flick

    // See: http://doc.qt.io/qt-5/qml-qtquick-texttextEdit.html
    function _ensureVisible (r) {
      if (contentX >= r.x) {
        contentX = r.x
      } else if (contentX + width <= r.x + r.width) {
        contentX = r.x + r.width - width
      }

      if (contentY >= r.y) {
        contentY = r.y
      } else if (contentY + height <= r.y + r.height) {
        contentY = r.y + r.height - height
      }
    }

    anchors.fill: parent
    boundsBehavior: Flickable.StopAtBounds
    clip: true
    contentHeight: textEdit.paintedHeight
    contentWidth: textEdit.paintedWidth
    interactive: textEdit.activeFocus

    Quick.TextEdit {
      id: textEdit

      color: activeFocus && !readOnly
        ? TextEditStyle.textColor.focused
        : TextEditStyle.textColor.normal
      selectByMouse: true
      width: flick.width
      wrapMode: Text.Wrap

      Keys.onEscapePressed: focus = false
      Keys.onReturnPressed: focus = false

      onCursorRectangleChanged: flick._ensureVisible(cursorRectangle)
      onEditingFinished: _handleEditingFinished()
    }
  }
}
