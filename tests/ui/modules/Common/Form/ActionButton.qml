import QtQuick 2.7
import QtQuick.Controls 2.0

import Common 1.0

// ===================================================================
// An animated small button with an image.
// ===================================================================

Button {
  property alias icon: icon.icon
  property int iconSize

  flat: true

  // Ugly hack, use current size, ActionBar size,
  // or other parent height.
  height: iconSize || parent.iconSize || parent.height
  width: iconSize || parent.iconSize || parent.height

  Icon {
    id: icon

    anchors.fill: parent
  }
}
