import QtQuick 2.7

import Common 1.0
import Linphone 1.0

// =============================================================================

// Wrapper to use `icon` property.
Item {
  property int level: -1

  Icon {
    anchors.centerIn: parent

    icon: Presence.getPresenceLevelIconName(level)
    iconSize: parent.height > parent.width
      ? parent.width
      : parent.height
  }
}
