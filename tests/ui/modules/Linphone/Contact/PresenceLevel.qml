import QtQuick 2.7

import Common 1.0
import Linphone 1.0 /* It contains `Presence`. */

// ===================================================================

Icon {
  property int level: -1

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
    return level ? 'led_' + level : ''
  }
}
