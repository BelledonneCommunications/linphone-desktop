import QtQuick 2.7

// ===================================================================

MouseArea {
  property alias text: tooltip.text
  property var tooltipParent: this

  property bool _visible: false

  anchors.fill: parent
  hoverEnabled: true
  scrollGestureEnabled: true

  onContainsMouseChanged: _visible = containsMouse
  onPressed: mouse.accepted = false
  onWheel: {
    _visible = false
    wheel.accepted = false
  }

  Tooltip {
    id: tooltip

    parent: tooltipParent
    visible: _visible
  }
}
