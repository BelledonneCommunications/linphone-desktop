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
  property alias textColor: button.textColor
  property bool enabled: true
  property bool showBorder : false
  property bool interactive: true
  property alias toggled : button.checked
  property alias button: button
  property alias radius: button.radius
  property alias capitalization : button.capitalization
  
  //Additional size around text
  property int addHeight: 25
  property int addWidth: 60

  signal clicked

  // ---------------------------------------------------------------------------

  function _getBackgroundColor () {
    if (!wrappedButton.enabled) {
      return colorDisabled
    }

    return button.down || button.checked
      ? colorPressed
      : (button.hovered ? colorHovered : colorNormal)
  }
  
  function _getBorderColor () {
    if (!wrappedButton.enabled) {
      return borderColorDisabled
    }

    return button.down || button.checked
      ? borderColorPressed
      : (button.hovered ? borderColorHovered : borderColorNormal)
  }

  function _getTextColor () {
    if (!wrappedButton.enabled) {
      return textColorDisabled
    }

    return button.down || button.checked
      ? textColorPressed
      : (button.hovered ? textColorHovered : textColorNormal)
  }

  // ---------------------------------------------------------------------------
   property int fitHeight: button.contentItem.implicitHeight + addHeight
   property int fitWidth: button.contentItem.implicitWidth + addWidth
  height: fitHeight
  width: fitWidth

  // ---------------------------------------------------------------------------

  Button {
    id: button
    property int capitalization
    property color textColor: _getTextColor()
    property int radius: AbstractTextButtonStyle.background.radius

    background: Rectangle {
      color: _getBackgroundColor()
      radius: button.radius
      border.color: _getBorderColor()
      border.width: (showBorder ? 1 : 0)
    }

    contentItem: Text {
      color: button.textColor
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

    hoverEnabled: wrappedButton.interactive

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed:  mouse.accepted = !interactive
        interactive: wrappedButton.interactive
    }

    height: parent.height
    width: parent.width

    onClicked: wrappedButton.enabled && parent.clicked()
  }
}
