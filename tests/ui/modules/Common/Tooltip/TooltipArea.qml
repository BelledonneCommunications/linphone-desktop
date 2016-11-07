import QtQuick 2.7

// ===================================================================

MouseArea {
  property alias text: tooltip.text
  property var toolTipParent: this

  anchors.fill: parent
  hoverEnabled: true

  onPressed: mouse.accepted = false

  Tooltip {
    id: tooltip

    parent: toolTipParent
    visible: containsMouse
  }
}
