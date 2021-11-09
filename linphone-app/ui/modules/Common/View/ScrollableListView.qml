import QtQuick 2.12	//synchronousDrag
import QtQuick.Controls 2.2

import Common 1.0

// =============================================================================

ListView {
  id: view

  // ---------------------------------------------------------------------------
  
  ScrollBar.vertical: ForceScrollBar {
    id: vScrollBar

    onPressedChanged: pressed ? view.movementStarted() : view.movementEnded()
    // ScrollBar.AsNeeded doesn't work. Do it ourself.
	policy: (view.contentHeight > view.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff)
  }
  // ---------------------------------------------------------------------------

  boundsBehavior: Flickable.StopAtBounds
  clip: true
  contentWidth: width - (vScrollBar.visible?vScrollBar.width:0)
  spacing: 0
  synchronousDrag: true
  cacheBuffer: height
  // ---------------------------------------------------------------------------

  // TODO: Find a solution at this bug =>
  // https://bugreports.qt.io/browse/QTBUG-31573
  // https://bugreports.qt.io/browse/QTBUG-49989
}
