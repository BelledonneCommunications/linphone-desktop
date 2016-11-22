import QtQuick 2.7

// ===================================================================

MouseArea {
  property alias text: tooltip.text
  property var tooltipParent: this

  anchors.fill: parent
  hoverEnabled: true

  onPressed: mouse.accepted = false

  Tooltip {
    id: tooltip

    parent: tooltipParent
    visible: containsMouse
  }
}
