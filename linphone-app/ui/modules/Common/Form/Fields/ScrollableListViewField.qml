import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Rectangle {
  id: field

  property bool readOnly: false

  default property alias _content: content.data
  
  property QtObject textFieldStyle : TextFieldStyle.normal

  color: textFieldStyle ? textFieldStyle.background.color.normal.color : ''
  radius: textFieldStyle ? textFieldStyle.background.radius : 0

  Item {
    id: content

    anchors.fill: parent
  }

  Rectangle {
    anchors.fill: parent

    border {
      color: textFieldStyle ? textFieldStyle.background.border.color.normal.color : ''
      width: textFieldStyle ? textFieldStyle.background.border.width : 0
    }

    color: 'transparent'
    radius: field.radius
  }

  Rectangle {
    anchors.fill: parent
    color: textFieldStyle ? textFieldStyle.background.color.readOnly.color : ''
    opacity: 0.8
    visible: field.readOnly
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.ArrowCursor
    visible: field.readOnly

    onWheel: wheel.accepted = true
  }
}
