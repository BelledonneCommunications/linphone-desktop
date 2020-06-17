import QtQuick 2.7

import Common 1.0
import Utils 1.0

// =============================================================================
// An icon image properly resized.
// =============================================================================

Item {
  property var iconSize // Required.
  property string icon

  height: iconSize
  width: iconSize

  Image {
    mipmap: Qt.platform.os === 'osx'
    function getIconSize () {
      Utils.assert(
        iconSize != null && iconSize >= 0,
        '`iconSize` must be defined and must be positive. (icon=`' +
          icon + '`, iconSize=' + iconSize + ')'
      )

      return iconSize
    }

    anchors.centerIn: parent

    width: iconSize
    height: iconSize

    fillMode: Image.PreserveAspectFit
    source: Utils.resolveImageUri(icon)
    sourceSize.width: getIconSize()
    sourceSize.height: getIconSize()
  }
}
