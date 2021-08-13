import QtQuick 2.7

import Common 1.0
import Linphone 1.0

// =============================================================================

// Wrapper to use `icon` property.
Item {
  property var level: null
  property bool betterIcon : false
	//onLevelChanged: console.log("Level change : "+Presence.getPresenceStatusAsString(level))

  Icon {
    anchors.centerIn: parent

    icon: (level !== -1 && level != null)
      ? (betterIcon? Presence.getBetterPresenceLevelIconName(level) : Presence.getPresenceLevelIconName(level))
      : ''
    iconSize: parent.height > parent.width
      ? parent.width
      : parent.height
	//onIconChanged: console.log(Presence.getPresenceStatusAsString(level)+ "//" +icon)
  }
}
