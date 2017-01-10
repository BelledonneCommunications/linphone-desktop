import QtQuick 2.7
import QtQuick.Controls 2.0

import Common 1.0

// =============================================================================

ListView {
  id: listView

  ScrollBar.vertical: ForceScrollBar {
    id: scrollBar

    onPressedChanged: pressed ? listView.movementStarted() : listView.movementEnded()
  }

  boundsBehavior: Flickable.StopAtBounds
  clip: true
  contentWidth: width - scrollBar.width
  spacing: 0
}
