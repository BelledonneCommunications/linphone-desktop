import QtQuick 2.7

import Common 1.0
import Utils 1.0

// ===================================================================
// Helper to handle button click outside a component.
// ===================================================================

Item {
  id: item

  property var _mouseArea

  signal pressed

  function _createMouseArea () {
    if (_mouseArea == null) {
      _mouseArea = builder.createObject()
    }

    _mouseArea.parent = (function () {
      var root = item

      while (root.parent != null) {
        root = root.parent
      }

      return root
    })()
  }

  function _deleteMouseArea () {
    if (_mouseArea != null) {
      _mouseArea.destroy()
      _mouseArea = null
    }
  }

  function _isInItem (point) {
    return (
      point.x >= item.x &&
      point.y >= item.y &&
      point.x <= item.x + item.width &&
      point.y <= item.y + item.height
    )
  }

  // It's necessary to use a `enabled` variable.
  // See: http://doc.qt.io/qt-5/qml-qtqml-component.html#completed-signal
  //
  // The creation order of components in a view is undefined,
  // so the mouse area must be created only when `enabled === true`.
  //
  // In the first render, `enabled` must be equal to false.
  Component.onCompleted: enabled && _createMouseArea()
  Component.onDestruction: _deleteMouseArea()

  onEnabledChanged: {
    _deleteMouseArea()

    if (enabled) {
      _createMouseArea()
    }
  }

  Component {
    id: builder

    MouseArea {
      property var _timeout

      anchors.fill: parent
      propagateComposedEvents: true
      z: Constants.zMax

      onPressed: {
        // Propagate event.
        mouse.accepted = false

        // Click is outside or not.
        if (!_isInItem(
          mapToItem(item.parent, mouse.x, mouse.y)
        )) {
          if (_timeout != null) {
            // Remove existing timeout to avoid the creation of
            // many children.
            Utils.clearTimeout(_timeout)
          }

          // Use a asynchronous call that is executed
          // after the propagated event.
          //
          // It's useful to ensure the window's context is not
          // modified with the mouse event before the `onPressed`
          // call.
          //
          // The timeout is destroyed with the `MouseArea` component.
          _timeout = Utils.setTimeout.call(
            this, 0, item.pressed.bind(this)
          )
        }
      }
    }
  }
}
