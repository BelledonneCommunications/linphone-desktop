import QtQuick 2.7

import Common 1.0

// ===================================================================
// An icon image properly resized.
// ===================================================================

Image {
  property int iconSize
  property string icon

  height: iconSize
  width: iconSize

  fillMode: Image.PreserveAspectFit
  source: icon
    ? Constants.imagesPath + icon + Constants.imagesFormat
    : ''
}
