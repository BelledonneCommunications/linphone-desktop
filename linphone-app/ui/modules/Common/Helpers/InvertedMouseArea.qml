import QtQuick 2.7

import Common 1.0
import Utils 1.0

// =============================================================================
// Helper to handle button click outside an item.
// =============================================================================

Item {
  id: item

  // ---------------------------------------------------------------------------

  property bool _mouseAlwaysOutside
  property var _mouseArea: null

  // ---------------------------------------------------------------------------

  // When emitted, returns a function to test if the click
  // is on a specific item. It takes only a item parameter.
  signal pressed (var pointIsInItem)

  // ---------------------------------------------------------------------------

  function _createMouseArea () {
    var parent = Utils.getTopParent(item, true)

    if (_mouseArea == null) {
      _mouseArea = builder.createObject()
    }

    _mouseArea.parent = parent

    // Must be true if a fake parent is used and if `mouseArea`
    // is not in the same window that `item`.
    _mouseAlwaysOutside =
      _mouseArea.parent !== Utils.getTopParent(item)
  }

  function _deleteMouseArea () {
    if (_mouseArea != null) {
      _mouseArea.destroy()
      _mouseArea = null
    }
  }

  // ---------------------------------------------------------------------------

  // It's necessary to use a `enabled` variable.
  // See: http://doc.qt.io/qt-5/qml-qtqml-component.html#completed-signal
  //
  // The creation order of components in a view is undefined,
  // so the mouse area must be created only when the target component
  // was completed.
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

      function _checkPosition (positionEvent) {
        // Propagate event.
        positionEvent.accepted = false

        // Click is outside or not.
        if (
          _mouseAlwaysOutside ||
          !Utils.pointIsInItem(this, item, positionEvent)
        ) {
          if (_timeout != null) {
            // Remove existing timeout to avoid the creation of
            // many children.
            Utils.clearTimeout(_timeout)
          }

          // Use a asynchronous call that is executed
          // after the propagated event.
          //
          // It's useful to ensure the window's context is not
          // modified with the positionEvent before the `onPressed`
          // call.
          //
          // The timeout is destroyed with the `MouseArea` component.
          _timeout = Utils.setTimeout(this, 0, item.pressed.bind(
            this,
            (function (point, item) {
              return Utils.pointIsInItem(this, item, point)
            }).bind(this, { x: positionEvent.x, y: positionEvent.y })
          ))
        }
      }

      anchors.fill: parent
      propagateComposedEvents: true
      z: Constants.zMax

      onPressed: _checkPosition.call(this, mouse)
      onWheel: _checkPosition.call(this, wheel)
    }
  }
}
