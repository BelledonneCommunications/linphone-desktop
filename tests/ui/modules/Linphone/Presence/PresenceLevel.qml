import QtQuick 2.7

import Common 1.0
import Linphone 1.0

// ===================================================================

// Wrapper to use `icon` property.
Item {
  property int level: -1
  property string icon: 'led'

  Icon {
    anchors.centerIn: parent

    function _getColorString () {
      if (level === Presence.Green) {
        return 'green'
      }
      if (level === Presence.Orange) {
        return 'orange'
      }
      if (level === Presence.Red) {
        return 'red'
      }
      if (level === Presence.White) {
        return 'white'
      }
    }

    icon: {
      var level = _getColorString()
      return level
        ? parent.icon + '_' + level
        : ''
    }
    iconSize: parent.height > parent.width
      ? parent.width
      : parent.height
  }
}
