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
    function _checkIconSize () {
      Utils.assert(
        iconSize != null && iconSize >= 0,
        '`iconSize` must be defined and must be positive. (icon=`' +
          icon + '`, iconSize=' + iconSize + ')'
      )
    }

    anchors.centerIn: parent
    height: {
      _checkIconSize()
      return iconSize > sourceSize.height
        ? sourceSize.height
        : iconSize
    }
    width: {
      _checkIconSize()
      return iconSize > sourceSize.width
        ? sourceSize.width
        : iconSize
    }

    fillMode: Image.PreserveAspectFit
    source: icon
      ? Constants.imagesPath + icon + Constants.imagesFormat
      : ''

    // Warning: Perfomance cost.
    mipmap: true
  }
}
