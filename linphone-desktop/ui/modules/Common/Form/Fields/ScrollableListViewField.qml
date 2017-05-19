import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Rectangle {
  id: field

  property bool readOnly: false

  default property alias _content: content.data

  color: TextFieldStyle.background.color.normal
  radius: TextFieldStyle.background.radius

  Item {
    id: content

    anchors.fill: parent
  }

  Rectangle {
    anchors.fill: parent

    border {
      color: TextFieldStyle.background.border.color.normal
      width: TextFieldStyle.background.border.width
    }

    color: 'transparent'
    radius: field.radius
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    visible: field.readOnly

    onWheel: wheel.accepted = true
  }
}
