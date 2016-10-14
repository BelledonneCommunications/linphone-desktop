import QtQuick 2.7
import QtQuick.Controls 2.0

import Common.Styles 1.0

// ===================================================================
// A simple custom vertical scrollbar.
// ===================================================================

ScrollBar {
  id: scrollBar

  background: ForceScrollBarStyle.background
  contentItem: Rectangle {
    color: scrollBar.pressed
      ? ForceScrollBarStyle.color.pressed
      : (scrollBar.hovered
         ? ForceScrollBarStyle.color.hovered
         : ForceScrollBarStyle.color.normal
        )
    implicitHeight: ForceScrollBarStyle.contentItem.implicitHeight
    implicitWidth: ForceScrollBarStyle.contentItem.implicitWidth
    radius: ForceScrollBarStyle.contentItem.radius
  }
  hoverEnabled: true
}
