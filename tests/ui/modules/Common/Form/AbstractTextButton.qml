import QtQuick 2.7
import QtQuick.Controls 2.0

import Common.Styles 1.0

// ===================================================================

Button {
  id: button

  property color colorHovered
  property color colorNormal
  property color colorPressed

  // By default textColorNormal is the hovered/pressed text color.
  property color textColorHovered: textColorNormal
  property color textColorNormal
  property color textColorPressed: textColorNormal

  background: Rectangle {
    color: button.down
      ? colorPressed
      : (button.hovered
         ? colorHovered
         : colorNormal
        )
    implicitHeight: AbstractTextButtonStyle.background.height
    implicitWidth: AbstractTextButtonStyle.background.width
    radius: AbstractTextButtonStyle.background.radius
  }
  contentItem: Text {
    color: button.down
      ? textColorPressed
      : (button.hovered
         ? textColorHovered
         : textColorNormal
        )

    font {
      bold: true
      pointSize: AbstractTextButtonStyle.text.fontSize
    }

    elide: Text.ElideRight
    horizontalAlignment: Text.AlignHCenter
    text: button.text
    verticalAlignment: Text.AlignVCenter
  }
  hoverEnabled: true
}
