import QtQuick 2.7
import QtQuick.Controls 2.1

import Common.Styles 1.0

// =============================================================================

MenuItem {
  id: button

  background: Rectangle {
    color: button.down
      ? MenuItemStyle.background.color.pressed
      : (
        button.hovered
          ? MenuItemStyle.background.color.hovered
          : MenuItemStyle.background.color.normal
      )
    implicitHeight: MenuItemStyle.background.height
  }
  contentItem: Text {
    color: MenuItemStyle.text.color
    elide: Text.ElideRight
    font.bold: true
    font.pointSize: MenuItemStyle.text.fontSize
    text: button.text

    leftPadding: MenuItemStyle.leftPadding
    rightPadding: MenuItemStyle.rightPadding

    verticalAlignment: Text.AlignVCenter
  }
  hoverEnabled: true
}
