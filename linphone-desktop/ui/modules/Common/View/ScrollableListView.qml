import QtQuick 2.7
import QtQuick.Controls 2.0

import Common 1.0

// =============================================================================

ListView {
  id: listView

  ScrollBar.horizontal: ForceScrollBar {
    id: hScrollBar

    onPressedChanged: pressed ? listView.movementStarted() : listView.movementEnded()
  }

  ScrollBar.vertical: ForceScrollBar {
    id: vScrollBar

    onPressedChanged: pressed ? listView.movementStarted() : listView.movementEnded()
  }

  boundsBehavior: Flickable.StopAtBounds
  clip: true
  contentWidth: vScrollBar.visible ? width - vScrollBar.width : width
  contentHeight: hScrollBar.visible ? height - hScrollBar.height : height

  spacing: 0
}
