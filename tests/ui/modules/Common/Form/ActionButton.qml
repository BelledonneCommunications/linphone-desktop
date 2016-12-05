import QtQuick 2.7
import QtQuick.Controls 2.0

import Common 1.0

// ===================================================================
// An animated (or not) button with image(s).
// ===================================================================

Button {
  id: button

  property bool useStates: true
  property int iconSize // Optionnal.

  // If `useStates` = true, the used icons are:
  // `icon`_pressed, `icon`_hovered and `icon`_normal.
  property string icon

  // -----------------------------------------------------------------

  function _getIcon () {
    if (!useStates) {
      return button.icon
    }

    return button.icon + (
      button.down
        ? '_pressed'
        : (button.hovered ? '_hovered' : '_normal')
    )
  }

  // -----------------------------------------------------------------

  background: Rectangle {
    color: 'transparent'
  }
  hoverEnabled: true

  height: iconSize || parent.iconSize || parent.height
  width: iconSize || parent.iconSize || parent.height

  Icon {
    id: icon

    anchors.centerIn: parent
    icon: _getIcon()
    iconSize: parent.iconSize || (
      parent.width > parent.height ? parent.height : parent.width
    )
  }
}
