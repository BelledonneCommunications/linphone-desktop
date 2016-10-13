import QtQuick 2.7
import QtQuick.Controls 2.0

import Common.Styles 1.0

// ===================================================================
// Checkbox with clickable text.
// ===================================================================

CheckBox {
  id: checkBox

  contentItem: Text {
    color: checkBox.down
      ? CheckBoxTextStyle.color.pressed
      : (checkBox.hovered
         ? CheckBoxTextStyle.color.hovered
         : CheckBoxTextStyle.color.normal
        )
    font: checkBox.font
    leftPadding: checkBox.indicator.width + checkBox.spacing
    text: checkBox.text
    verticalAlignment: Text.AlignVCenter
  }
  hoverEnabled: true
  indicator: Rectangle {
    border.color: checkBox.down
      ? CheckBoxTextStyle.color.pressed
      : (checkBox.hovered
         ? CheckBoxTextStyle.color.hovered
         : CheckBoxTextStyle.color.normal
        )
    implicitHeight: CheckBoxTextStyle.size
    implicitWidth: CheckBoxTextStyle.size
    radius: CheckBoxTextStyle.radius
    x: checkBox.leftPadding
    y: parent.height / 2 - height / 2

    Rectangle {
      color: checkBox.down
        ? CheckBoxTextStyle.color.pressed
        : (checkBox.hovered
           ? CheckBoxTextStyle.color.hovered
           : CheckBoxTextStyle.color.normal
          )
      height: parent.height - y * 2
      radius: CheckBoxTextStyle.radius
      visible: checkBox.checked
      width: parent.width - x * 2
      x: 4 // Fixed, no style.
      y: 4 // Fixed, no style.
    }
  }
}
