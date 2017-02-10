import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls

import Common 1.0
import Common.Styles 1.0

// =============================================================================
// A classic TextInput which supports an icon attribute.
// =============================================================================

Controls.TextField {
  property alias icon: icon.icon

  background: Rectangle {
    border {
      color: TextFieldStyle.background.border.color
      width: TextFieldStyle.background.border.width
    }
    color: TextFieldStyle.background.color
    implicitHeight: TextFieldStyle.background.height
    implicitWidth: TextFieldStyle.background.width

    radius: TextFieldStyle.background.radius
  }

  color: TextFieldStyle.text.color
  font.pointSize: TextFieldStyle.text.fontSize

  Icon {
    id: icon

    anchors {
      right: parent.right
      rightMargin: parent.rightPadding
      verticalCenter: parent.verticalCenter
    }

    iconSize: parent.contentHeight
    visible: !parent.text
  }
}
