import QtQuick 2.7

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
    ? 'qrc:/imgs/' + icon + '.svg'
    : ''
}
