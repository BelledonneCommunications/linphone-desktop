import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Controls.TabButton {
  id: button

  // ---------------------------------------------------------------------------

  property int iconSize: TabButtonStyle.icon.size
  property string iconName

  readonly property bool _isSelected: parent.parent.currentItem === button

  // ---------------------------------------------------------------------------

  function _getBackgroundColor () {
    if (_isSelected) {
      return TabButtonStyle.backgroundColor.selected
    }

    return button.enabled
      ? (
        button.down
          ? TabButtonStyle.backgroundColor.pressed
          : (
            button.hovered
              ? TabButtonStyle.backgroundColor.hovered
              : TabButtonStyle.backgroundColor.normal
          )
      )
      : TabButtonStyle.backgroundColor.disabled
  }

  function _getTextColor () {
    if (_isSelected) {
      return TabButtonStyle.text.color.selected
    }

    return button.enabled
      ? (
        button.down
          ? TabButtonStyle.text.color.pressed
          : (
            button.hovered
              ? TabButtonStyle.text.color.hovered
              : TabButtonStyle.text.color.normal
          )
      )
      : TabButtonStyle.text.color.disabled
  }

  // ---------------------------------------------------------------------------

  background: Rectangle {
    color: _getBackgroundColor()
    implicitHeight: TabButtonStyle.text.height
  }

  contentItem: RowLayout {
    height: button.height
    width: button.width
    spacing: TabButtonStyle.spacing

    Icon {
      id: icon

      Layout.fillHeight: true
      Layout.leftMargin: TabButtonStyle.text.leftPadding

      icon: {
        var iconName = button.iconName
        return iconName.length
          ? (iconName + '_' + (button._isSelected ? 'selected' : 'normal'))
          : ''
      }
      iconSize: button.iconSize
    }

    Text {
      Layout.fillWidth: true
      Layout.fillHeight: true

      color: _getTextColor()

      font {
        bold: true
        pointSize: TabButtonStyle.text.pointSize
      }

      elide: Text.ElideRight

      height: parent.height
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter

      rightPadding: TabButtonStyle.text.rightPadding
      text: button.text
    }
  }

  hoverEnabled: true
}
