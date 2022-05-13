import QtQuick 2.7
import QtQuick.Controls 2.2

import Common 1.0
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
  
  property color borderColorDisabled
  property color borderColorHovered
  property color borderColorNormal
  property color borderColorPressed

  property alias text: button.text
  property bool enabled: true
  property bool showBorder : false
  
  property alias capitalization : button.capitalization

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
  
  function _getBorderColor () {
    if (!wrappedButton.enabled) {
      return borderColorDisabled
    }

    return button.down
      ? borderColorPressed
      : (button.hovered ? borderColorHovered : borderColorNormal)
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

  height: button.contentItem.implicitHeight + 25
  width: button.contentItem.implicitWidth + 60

  // ---------------------------------------------------------------------------

  Button {
    id: button
    property int capitalization

    background: Rectangle {
      color: _getBackgroundColor()
      radius: AbstractTextButtonStyle.background.radius
      border.color: _getBorderColor()
      border.width: (showBorder ? 1 : 0)
    }

    contentItem: Text {
      color: _getTextColor()
      font {
        bold: true
        pointSize: AbstractTextButtonStyle.text.pointSize
        capitalization: button.capitalization
      }
		wrapMode: Text.WordWrap
      horizontalAlignment: Text.AlignHCenter
      text: button.text
      verticalAlignment: Text.AlignVCenter
    }

    hoverEnabled: true

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed:  mouse.accepted = false
    }

    height: parent.height
    width: parent.width

    onClicked: wrappedButton.enabled && parent.clicked()
  }
}
