import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls

import Common 1.0
import Common.Styles 1.0

// =============================================================================
// A classic TextInput which supports an icon attribute.
// =============================================================================

Controls.TextField {
  id: textField

  property alias icon: icon.icon
  property var tools

  background: Rectangle {
    border {
      color: TextFieldStyle.background.border.color
      width: TextFieldStyle.background.border.width
    }

    color: textField.readOnly
      ? TextFieldStyle.background.color.readOnly
      : TextFieldStyle.background.color.normal

    implicitHeight: TextFieldStyle.background.height
    implicitWidth: TextFieldStyle.background.width

    radius: TextFieldStyle.background.radius

    MouseArea {
      anchors.right: parent.right
      height: parent.height
      hoverEnabled: true
      implicitWidth: tools ? tools.width : 0

      Rectangle {
        id: toolsContainer

        border {
          color: TextFieldStyle.background.border.color
          width: TextFieldStyle.background.border.width
        }

        anchors.fill: parent
        color: background.color
        data: tools || []
      }
    }
  }

  color: TextFieldStyle.text.color
  font.pointSize: TextFieldStyle.text.fontSize
  rightPadding: TextFieldStyle.text.rightPadding + toolsContainer.width
  selectByMouse: true

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
