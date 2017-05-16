import QtQuick 2.7
import QtQuick.Controls 2.1

import Common 1.0

import 'ScrollableListView.js' as Logic

// =============================================================================

ListView {
  id: view

  // ---------------------------------------------------------------------------

  function positionViewAtEnd () {
    Logic.positionViewAtEnd()
  }

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

  // TODO: Find a solution at this bug => https://bugreports.qt.io/browse/QTBUG-31573
  SequentialAnimation {
    id: scrollAnimation

    ScriptAction {
      script: {
        view.contentY = view.contentY
        view.contentY = Logic.getYEnd()
        view.contentY = view.contentY
      }
    }

    PauseAnimation {
      duration: 200
    }

    ScriptAction {
      script: {
        view.contentY = Logic.getYEnd()
      }
    }
  }
}
