import QtQuick 2.7
import QtQuick.Controls 2.0

import Common.Styles 1.0

// =============================================================================

Item {
  id: wrappedButton

  property color colorDisabled
  property color colorHovered
  property color colorNormal
  property color colorPressed

  // By default textColorNormal is the hovered/pressed text color.
  property color textColorDisabled
  property color textColorHovered: textColorNormal
  property color textColorNormal
  property color textColorPressed: textColorNormal

  property alias text: button.text
  property bool enabled: true

  signal clicked

  // ---------------------------------------------------------------------------

  function _getBackgroundColor () {
    if (!wrappedButton.enabled) {
      return colorDisabled
    }

    return button.down
      ? colorPressed
      : (button.hovered ? colorHovered : colorNormal)
  }

  function _getTextColor () {
    if (!wrappedButton.enabled) {
      return textColorDisabled
    }

    return button.down
      ? textColorPressed
      : (button.hovered ? textColorHovered : textColorNormal)
  }

  // ---------------------------------------------------------------------------

  implicitHeight: button.height
  implicitWidth: button.width

  // ---------------------------------------------------------------------------

  Button {
    id: button

    background: Rectangle {
      color: _getBackgroundColor()
      implicitHeight: AbstractTextButtonStyle.background.height
      implicitWidth: AbstractTextButtonStyle.background.width
      radius: AbstractTextButtonStyle.background.radius
    }
    contentItem: Text {
      color: _getTextColor()
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

    onClicked: wrappedButton.enabled && parent.clicked()
  }
}
