import QtQuick 2.7

import Common 1.0
// =============================================================================

Item {
  id: dragBox

  // ---------------------------------------------------------------------------

  property var container
  property var draggable

  property var xPosition
  property var yPosition

  // ---------------------------------------------------------------------------

  property var _mouseArea: null

  // ---------------------------------------------------------------------------

  signal clicked (var mouse)
  signal doubleClicked (var mouse)
  signal pressed (var mouse)
  signal released (var mouse)
  signal wheel (var wheel)

  // ---------------------------------------------------------------------------

  function _create () {
    draggable.x = Qt.binding(xPosition)
    draggable.y = Qt.binding(yPosition)

    var drag = draggable.Drag

    drag.hotSpot.x = Qt.binding(function () {
      return draggable.width / 2
    })
    drag.hotSpot.y = Qt.binding(function () {
      return draggable.height / 2
    })

    if (_mouseArea == null) {
      _mouseArea = builder.createObject(draggable)

      drag.active = Qt.binding(function () {
        return _mouseArea && _mouseArea.held
      })

      drag.source = Qt.binding(function () {
        return _mouseArea
      })
    }
  }

  function _delete () {
    if (_mouseArea != null) {
      _mouseArea.destroy()
      _mouseArea = null
    }
  }
  function updateBoundaries(){
        var container = dragBox.container

        if (parent.x < 0) {
          parent.x = 0
        } else if (parent.x + parent.width >= container.width) {
          parent.x = container.width - parent.width
        }
        if (parent.y < 0) {
          parent.y = 0
        } else if (parent.y + parent.height >= container.height) {
          parent.y = container.height - parent.height
        }
  }
  // ---------------------------------------------------------------------------

  Component.onCompleted: enabled && _create()
  Component.onDestruction: _delete()

  onEnabledChanged: {
    _delete()

    if (enabled) {
      _create()
    }
  }

  // ---------------------------------------------------------------------------

  Component {
    id: builder

    MouseArea {
      property bool held: false

      anchors.fill: parent

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      drag {
        axis: Drag.XandYAxis
        target: parent
      }
      onDoubleClicked: dragBox.doubleClicked(mouse)
      onClicked:dragBox.clicked(mouse)
      onPressed: {
        dragBox.pressed(mouse)
        held = true
      }

      onReleased: {
        dragBox.released(mouse)
        held = false
        updateBoundaries()
      }

      onWheel: dragBox.wheel(wheel)
    }
  }
}
