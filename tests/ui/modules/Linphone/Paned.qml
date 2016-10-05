import QtQuick 2.7

import Linphone.Styles 1.0
import Utils 1.0

// ===================================================================
//
// Paned is one container divided in two areas.
// The division between the areas can be modified with a handle.
//
// Each area can have a fixed or dynamic minimum width.
// See `leftLimit` and `rightLimit` attributes.
//
// To create a dynamic minimum width, it's necessary to give
// a percentage to `leftLimit` or `rightLimit` like:
// `leftLimit: '0.66%'`.
// The percentage is relative to the container width.
//
// ===================================================================

Item {
  id: container

  property alias childA: contentA.data
  property alias childB: contentB.data
  property int closingEdge: Qt.LeftEdge

  // User limits: string or int values.
  property var leftLimit: 0
  property var rightLimit: 0

  property bool _isClosed
  property int _savedContentAWidth

  // Internal limits.
  property var _leftLimit
  property var _rightLimit

  function _getLimitValue (limit) {
    return limit.isDynamic
      ? width * limit.value
      : limit.value
  }

  function _parseLimit (limit) {
    if (Utils.isString(limit)) {
      var arr = limit.split('%')

      return {
        isDynamic: arr[1] === '',
        value: +arr[0]
      }
    }

    return {
      value: limit
    }
  }

  function _applyLimits () {
    var rightLimit = _getLimitValue(_rightLimit)
    var leftLimit = _getLimitValue(_leftLimit)

    // width(A) < minimum width(A).
    if (contentA.width < leftLimit) {
      contentA.width = leftLimit
    }

    // width(B) < minimum width(B).
    else if (width - contentA.width - handle.width < rightLimit) {
      contentA.width = width - handle.width - rightLimit
    }
  }

  onWidthChanged: !_isClosed && _applyLimits()

  Component.onCompleted: {
    _leftLimit = _parseLimit(leftLimit)
    _rightLimit = _parseLimit(rightLimit)

    contentA.width = _getLimitValue(_leftLimit)
  }

  Item {
    id: contentA

    height: parent.height
  }

  MouseArea {
    id: handle

    property int _mouseStart

    anchors.left: contentA.right
    cursorShape: Qt.SplitHCursor
    height: parent.height
    hoverEnabled: true
    width: PanedStyle.handle.width

    onDoubleClicked: {
      // Save state and close.
      if (!_isClosed) {
        _isClosed = true
        _savedContentAWidth = contentA.width

        contentA.width = (closingEdge !== Qt.LeftEdge)
          ? container.width - width
          : 0

        return
      }

      // Restore old state.
      _isClosed = false
      contentA.width = _savedContentAWidth

      _applyLimits()
    }

    onMouseXChanged: {
      if (!pressed || _isClosed) {
        return
      }

      var offset = mouseX - _mouseStart

      var rightLimit = _getLimitValue(_rightLimit)
      var leftLimit = _getLimitValue(_leftLimit)

      // width(B) < minimum width(B).
      if (container.width - offset - contentA.width - width < rightLimit) {
        contentA.width = container.width - width - rightLimit
      }
      // width(A) < minimum width(A).
      else if (contentA.width + offset < leftLimit) {
        contentA.width = leftLimit
      }
      // Resize A/B.
      else {
        contentA.width = contentA.width + offset
      }
    }

    onPressed: _mouseStart = mouseX

    Rectangle {
      anchors.fill: parent
      color: parent.pressed
        ? PanedStyle.handle.color.pressed
        : (parent.containsMouse
           ? PanedStyle.handle.color.hovered
           : PanedStyle.handle.color.normal
          )
    }
  }

  Item {
    id: contentB

    anchors.left: handle.right
    height: parent.height
    width: container.width - contentA.width - handle.width
  }
}
