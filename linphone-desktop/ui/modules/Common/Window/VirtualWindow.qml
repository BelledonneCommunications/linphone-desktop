import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Item {
  function setContent (object) {
    object.parent = content
    object.anchors.centerIn = content

    visible = true
  }

  function unsetContent () {
    visible = false

    var object = content.data[0]
    content.data = []

    return object
  }

  // ---------------------------------------------------------------------------

  anchors.fill: parent
  visible: false

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onWheel: wheel.accepted = true
  }

  Rectangle {
    id: content

    anchors.fill: parent
    color: WindowStyle.transientWindow.color
  }
}
