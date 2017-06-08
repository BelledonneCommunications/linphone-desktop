import QtQuick 2.7
import QtQuick.Controls 2.1

import Common.Styles 1.0

// =============================================================================
// Checkbox with clickable text.
// =============================================================================

CheckBox {
  id: checkBox

  contentItem: Text {
    color: checkBox.down
      ? CheckBoxTextStyle.color.pressed
      : (
        checkBox.hovered
          ? CheckBoxTextStyle.color.hovered
          : CheckBoxTextStyle.color.normal
      )

    elide: Text.ElideRight
    font: checkBox.font
    leftPadding: checkBox.indicator.width + checkBox.spacing
    text: checkBox.text

    width: parent.width
    wrapMode: Text.WordWrap

    verticalAlignment: Text.AlignVCenter
  }

  font.pointSize: CheckBoxTextStyle.pointSize
  hoverEnabled: true

  indicator: Rectangle {
    border.color: checkBox.down
      ? CheckBoxTextStyle.color.pressed
      : (
        checkBox.hovered
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
      width: parent.width - x * 2

      radius: CheckBoxTextStyle.radius
      visible: checkBox.checked

      x: 4 // Fixed, no needed to use style file.
      y: 4 // Same thing.
    }
  }
}
