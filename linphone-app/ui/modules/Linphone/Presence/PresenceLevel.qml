import QtQuick 2.7

import Common 1.0
import Linphone 1.0

// =============================================================================

// Wrapper to use `icon` property.
Item {
  property var level: null

  Icon {
    anchors.centerIn: parent

    icon: (level !== -1 && level != null)
      ? Presence.getPresenceLevelIconName(level)
      : ''
    iconSize: parent.height > parent.width
      ? parent.width
      : parent.height
  }
}
