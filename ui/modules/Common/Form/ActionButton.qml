import QtQuick 2.7
import QtQuick.Controls 2.2

import Common 1.0

// =============================================================================
// An animated (or not) button with image(s).
// =============================================================================

Item {
  id: wrappedButton

  // ---------------------------------------------------------------------------

  property bool enabled: true
  property bool updating: false
  property bool useStates: true
  property int iconSize // Optional.
  readonly property alias hovered: button.hovered
  property alias text: button.text

  // If `useStates` = true, the used icons are:
  // `icon`_pressed, `icon`_hovered and `icon`_normal.
  property string icon

  // ---------------------------------------------------------------------------

  signal clicked

  // ---------------------------------------------------------------------------

  function _getIcon () {
    if (wrappedButton.updating) {
      return wrappedButton.icon + '_updating'
    }

    if (!useStates) {
      return wrappedButton.icon
    }

    if (!wrappedButton.enabled) {
      return wrappedButton.icon + '_disabled'
    }

    return wrappedButton.icon + (
      button.down
        ? '_pressed'
        : (button.hovered ? '_hovered' : '_normal')
    )
  }

  // ---------------------------------------------------------------------------

  height: iconSize || parent.iconSize || parent.height
  width: iconSize || parent.iconSize || parent.width

  Button {
    id: button

    anchors.fill: parent
    background: Rectangle {
      color: 'transparent'
    }
    hoverEnabled: !wrappedButton.updating

    onClicked: !wrappedButton.updating && wrappedButton.enabled && wrappedButton.clicked()

    Icon {
      id: icon

      anchors.centerIn: parent
      icon: _getIcon()
      iconSize: wrappedButton.iconSize || (
        parent.width > parent.height ? parent.height : parent.width
      )
    }
  }
}
