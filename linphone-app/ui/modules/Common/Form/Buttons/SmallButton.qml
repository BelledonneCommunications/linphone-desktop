import QtQuick 2.7
import QtQuick.Controls 2.2

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Button {
  id: button

  property alias backgroundColor: background.color
  property alias textColor: textItem.color
  property alias radius: background.radius
  property int capitalization
  property alias pointSize: textItem.font.pointSize
  property alias textFormat: textItem.textFormat

  background: Rectangle {
    id: background

    color: button.down
      ? SmallButtonStyle.background.color.pressed.color
      : (button.hovered
         ? SmallButtonStyle.background.color.hovered.color
         : SmallButtonStyle.background.color.normal.color
        )
    implicitHeight: SmallButtonStyle.background.height
    radius: SmallButtonStyle.background.radius
  }
  contentItem: Text {
    id: textItem
    color: SmallButtonStyle.text.colorModel.color
    font.pointSize: SmallButtonStyle.text.pointSize
    font.weight: Font.Bold
    font.capitalization: button.capitalization
    horizontalAlignment: Text.AlignHCenter
    text: button.text
    verticalAlignment: Text.AlignVCenter
    leftPadding: SmallButtonStyle.leftPadding
    rightPadding: SmallButtonStyle.rightPadding
    
  }
  hoverEnabled: true
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    onPressed:  mouse.accepted = false
  }
}
