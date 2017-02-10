import QtQuick 2.7
import QtQuick.Controls 2.1

import Common.Styles 1.0

// =============================================================================

TabButton {
  id: button

  // ---------------------------------------------------------------------------

  function _getBackgroundColor () {
    if (button.parent.parent.currentItem === button) {
      return TabButtonStyle.backgroundColor.selected
    }

    return button.down
      ? TabButtonStyle.backgroundColor.pressed
      : (
        button.hovered
          ? TabButtonStyle.backgroundColor.hovered
          : TabButtonStyle.backgroundColor.normal
      )
  }

  function _getTextColor () {
    if (button.parent.parent.currentItem === button) {
      return TabButtonStyle.text.color.selected
    }

    return button.down
      ? TabButtonStyle.text.color.pressed
      : (
        button.hovered
          ? TabButtonStyle.text.color.hovered
          : TabButtonStyle.text.color.normal
      )
  }

  // ---------------------------------------------------------------------------

  background: Rectangle {
    color: _getBackgroundColor()
    implicitHeight: TabButtonStyle.text.height
  }

  contentItem: Text {
    color: _getTextColor()

    font {
      bold: true
      pointSize: TabButtonStyle.text.fontSize
    }

    elide: Text.ElideRight

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    leftPadding: TabButtonStyle.text.leftPadding
    rightPadding: TabButtonStyle.text.rightPadding
    text: button.text
  }

  hoverEnabled: true
}
