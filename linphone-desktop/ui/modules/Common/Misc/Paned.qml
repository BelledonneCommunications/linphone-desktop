import QtQuick 2.7

import Common.Styles 1.0
import Utils 1.0

// =============================================================================
//
// Paned is one container divided in two areas.
// The division between the areas can be modified with a handle.
//
// Each area can have a fixed or dynamic minimum width.
// See `minimumLeftLimit` and `minimumRightLimit` attributes.
//
// Note: Paned supports too `maximumLeftLimit` and
// `maximumRightLimit`.
//
// To create a dynamic minimum width, it's necessary to give
// a percentage to `minmimumLeftLimit` or `minimumRightLimit` like:
// `minimumLeftLimit: '66%'`.
// The percentage is relative to the container width.
//
// =============================================================================

Item {
  id: container

  // ---------------------------------------------------------------------------

  property alias childA: contentA.data
  property alias childB: contentB.data
  property bool defaultClosed: false
  property bool resizeAInPriority: false
  property int closingEdge: Qt.LeftEdge // `LeftEdge` or `RightEdge`.
  property int defaultChildAWidth

  // User limits: string or int values.
  // By default: no limits.
  property var maximumLeftLimit
  property var maximumRightLimit
  property var minimumLeftLimit: 0
  property var minimumRightLimit: 0

  property bool _isClosed

  // Internal limits.
  property var _maximumLeftLimit
  property var _maximumRightLimit
  property var _minimumLeftLimit
  property var _minimumRightLimit

  // ---------------------------------------------------------------------------
  // Public functions.
  // ---------------------------------------------------------------------------

  function isClosed () {
    return _isClosed
  }

  function open () {
    if (_isClosed) {
      openingTransition.running = true
    }
  }

  function close () {
    if (!_isClosed) {
      _close()
    }
  }

  // ---------------------------------------------------------------------------
  // Private functions.
  // ---------------------------------------------------------------------------

  function _getLimitValue (limit) {
    if (limit == null) {
      return
    }

    return limit.isDynamic
      ? width * limit.value
      : limit.value
  }

  function _parseLimit (limit) {
    if (limit == null) {
      return
    }

    if (Utils.isString(limit)) {
      var arr = limit.split('%')

      if (arr[1] === '') {
        return {
          isDynamic: true,
          value: +arr[0] / 100
        }
      }
    }

    return {
      value: limit
    }
  }

  function _applyLimits () {
    var maximumLeftLimit = _getLimitValue(_maximumLeftLimit)
    var maximumRightLimit = _getLimitValue(_maximumRightLimit)
    var minimumLeftLimit = _getLimitValue(_minimumLeftLimit)
    var minimumRightLimit = _getLimitValue(_minimumRightLimit)

    var theoreticalBWidth = container.width - contentA.width - handle.width

    // If closed, set correctly the handle position to left or right.
    if (_isClosed) {
      contentA.width = (closingEdge !== Qt.LeftEdge)
        ? container.width - handle.width
        : 0
    }
    // width(A) < minimum width(A).
    else if (contentA.width < minimumLeftLimit) {
      contentA.width = minimumLeftLimit
    }
    // width(A) > maximum width(A).
    else if (maximumLeftLimit != null && contentA.width > maximumLeftLimit) {
      contentA.width = maximumLeftLimit
    }
    // width(B) < minimum width(B).
    else if (theoreticalBWidth < minimumRightLimit) {
      contentA.width = container.width - handle.width - minimumRightLimit
    }
    // width(B) > maximum width(B).
    else if (maximumRightLimit != null && theoreticalBWidth > maximumRightLimit) {
      contentA.width = container.width - handle.width - maximumRightLimit
    } else if (resizeAInPriority) {
      contentA.width = container.width - handle.width - contentB.width
    }
  }

  // ---------------------------------------------------------------------------

  function _applyLimitsOnUserMove (offset) {
    var minimumRightLimit = _getLimitValue(_minimumRightLimit)
    var minimumLeftLimit = _getLimitValue(_minimumLeftLimit)

    // One area is closed.
    if (_isClosed) {
      if (closingEdge === Qt.LeftEdge) {
        if (offset > minimumLeftLimit / 2) {
          _open()
        }
      } else {
        if (-offset > minimumRightLimit / 2) {
          _open()
        }
      }

      return
    }

    // Check limits.
    var maximumLeftLimit = _getLimitValue(_maximumLeftLimit)
    var maximumRightLimit = _getLimitValue(_maximumRightLimit)

    var theoreticalBWidth = container.width - offset - contentA.width - handle.width

    // width(A) < minimum width(A).
    if (contentA.width + offset < minimumLeftLimit) {
      contentA.width = minimumLeftLimit

      if (closingEdge === Qt.LeftEdge && -offset > minimumLeftLimit / 2) {
        if (_isClosed) {
          _open()
        } else {
          _close()
        }
      }
    }
    // width(A) > maximum width(A).
    else if (maximumLeftLimit != null && contentA.width + offset > maximumLeftLimit) {
      contentA.width = maximumLeftLimit
    }
    // width(B) < minimum width(B).
    else if (theoreticalBWidth < minimumRightLimit) {
      contentA.width = container.width - handle.width - minimumRightLimit

      if (closingEdge !== Qt.LeftEdge && offset > minimumRightLimit / 2) {
        if (_isClosed) {
          _open()
        } else {
          _close()
        }
      }
    }
    // width(B) > maximum width(B).
    else if (maximumRightLimit != null && theoreticalBWidth > maximumRightLimit) {
      contentA.width = container.width - handle.width - maximumRightLimit
    }
    // Resize A/B.
    else {
      contentA.width = contentA.width + offset
    }
  }

  // ---------------------------------------------------------------------------

  function _open () {
    _isClosed = false
    _applyLimits()
  }

  function _close () {
    _isClosed = true
    closingTransition.running = true
  }

  function _inverseClosingState () {
    if (!_isClosed) {
      // Save state and close.
      _close()
    } else {
      // Restore old state.
      openingTransition.running = true
    }
  }

  function _isVisible (edge) {
    return (
      !_isClosed ||
      openingTransition.running ||
      closingTransition.running
    ) || closingEdge !== edge
  }

  // ---------------------------------------------------------------------------

  onWidthChanged: _applyLimits()

  Component.onCompleted: {
    // Unable to modify these properties after creation.
    // It's a desired choice.
    _maximumLeftLimit = _parseLimit(maximumLeftLimit)
    _maximumRightLimit = _parseLimit(maximumRightLimit)
    _minimumLeftLimit = _parseLimit(minimumLeftLimit)
    _minimumRightLimit = _parseLimit(minimumRightLimit)

    contentA.width = (defaultChildAWidth == null)
      ? _getLimitValue(_minimumLeftLimit)
      : defaultChildAWidth

    _isClosed = defaultClosed
  }

  Item {
    id: contentA

    height: parent.height
    visible: _isVisible(Qt.LeftEdge)
  }

  MouseArea {
    id: handle

    property int _mouseStart

    anchors.left: contentA.right
    cursorShape: Qt.SplitHCursor
    height: parent.height
    hoverEnabled: true
    width: PanedStyle.handle.width

    onDoubleClicked: _inverseClosingState()
    onMouseXChanged: pressed &&
      _applyLimitsOnUserMove(mouseX - _mouseStart)
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
    visible: _isVisible(Qt.RightEdge)
    width: container.width - contentA.width - handle.width
  }

  PropertyAnimation {
    id: openingTransition

    duration: PanedStyle.transitionDuration
    property: 'width'
    target: contentA
    to: closingEdge === Qt.LeftEdge
      ? minimumLeftLimit
      : container.width - minimumRightLimit - handle.width

    onRunningChanged: !running && _open()
  }

  PropertyAnimation {
    id: closingTransition

    duration: PanedStyle.transitionDuration
    property: 'width'
    target: contentA
    to: closingEdge === Qt.LeftEdge ? 0 : container.width - handle.width
  }
}
