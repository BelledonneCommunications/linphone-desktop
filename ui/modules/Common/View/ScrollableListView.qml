import QtQuick 2.7
import QtQuick.Controls 2.1

import Common 1.0

// =============================================================================

ListView {
  id: view

  // ---------------------------------------------------------------------------

  ScrollBar.vertical: ForceScrollBar {
    id: vScrollBar

    onPressedChanged: pressed ? view.movementStarted() : view.movementEnded()
  }

  // ---------------------------------------------------------------------------

  boundsBehavior: Flickable.StopAtBounds
  clip: true
  contentWidth: width - vScrollBar.width
  spacing: 0

  // ---------------------------------------------------------------------------

  // TODO: Find a solution at this bug =>
  // https://bugreports.qt.io/browse/QTBUG-31573
  // https://bugreports.qt.io/browse/QTBUG-49989
}
