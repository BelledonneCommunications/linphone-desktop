import QtQuick 2.7
import QtQuick.Controls 2.0

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Flickable {
  property alias text: textArea.text
  readonly property alias length: textArea.length

  height: TextAreaFieldStyle.background.height
  width: TextAreaFieldStyle.background.width

  TextArea.flickable: TextArea {
    id: textArea

    background: Rectangle {
      border {
        color: TextAreaFieldStyle.background.border.color
        width: TextAreaFieldStyle.background.border.width
      }

      color: textArea.readOnly
        ? TextAreaFieldStyle.background.color.readOnly
        : TextAreaFieldStyle.background.color.normal

      radius: TextAreaFieldStyle.background.radius
    }

    color: TextAreaFieldStyle.text.color
    font.pointSize: TextAreaFieldStyle.text.fontSize
    selectByMouse: true
    wrapMode: TextArea.Wrap

    bottomPadding: TextAreaFieldStyle.text.padding
    leftPadding: TextAreaFieldStyle.text.padding
    rightPadding: TextAreaFieldStyle.text.padding + Number(scrollBar.visible) * scrollBar.width
    topPadding: TextAreaFieldStyle.text.padding
  }

  ScrollBar.vertical: ForceScrollBar {
    id: scrollBar
  }
}
