import QtQuick 2.7

import Linphone 1.0

// ===================================================================

Icon {
  property int level: -1

  function _getColorString () {
    if (level === ContactModel.Green) {
      return 'green'
    }
    if (level === ContactModel.Orange) {
      return 'orange'
    }
    if (level === ContactModel.Red) {
      return 'red'
    }
    if (level === ContactModel.White) {
      return 'white'
    }
  }

  icon: {
    var level = _getColorString()
    return level ? 'led_' + level : ''
  }
}
