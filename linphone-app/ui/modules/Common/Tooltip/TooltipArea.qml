import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0

// =============================================================================

MouseArea {
  id: tooltipArea

  property alias text: tooltip.text
  property int delay: TooltipStyle.delay
  property bool force: false
  property var tooltipParent: parent

  property bool _visible: false
  property int hoveringCursor : Qt.ArrowCursor

  anchors.fill:parent

  hoverEnabled: true
  scrollGestureEnabled: true

  onContainsMouseChanged: _visible = containsMouse
  cursorShape: containsMouse ? hoveringCursor : Qt.ArrowCursor

  onPressed: mouse.accepted = false
  onWheel: {
    _visible = false
    wheel.accepted = false
  }

  Tooltip {
    id: tooltip

    delay: tooltipArea.delay
    parent: tooltipParent
    visible: _visible || force
    width: tooltipParent.width>TooltipStyle.minWidth?tooltipParent.width:TooltipStyle.minWidth

    timeout: -1

    // Workaround to always display tooltip.
    onVisibleChanged: {
      if (!visible && force) {
        tooltip.visible = true
      }
    }
  }
}
