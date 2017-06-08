import QtQuick 2.7
import QtQuick.Controls 2.1

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

// =============================================================================

ToolTip {
  id: tooltip

  property var _edge: 'left'

  // ---------------------------------------------------------------------------

  function _getArrowHeightMargin () {
    Utils.assert(
      icon.height >= icon.implicitHeight,
      '`icon.height` must be lower than `icon.implicitHeight`.'
    )
    return (icon.height - icon.implicitHeight) / 2
  }

  function _getArrowWidthMargin () {
    Utils.assert(
      icon.width >= icon.implicitWidth,
      '`icon.width` must be lower than `icon.implicitWidth`.'
    )
    return (icon.width - icon.implicitWidth) / 2
  }

  function _getRelativeXArrowCenter () {
    return tooltip.parent.width / 2 - icon.width / 2
  }

  function _getRelativeYArrowCenter () {
    return tooltip.parent.height / 2 - icon.height / 2
  }

  function _setArrowEdge () {
    var a = container.mapToItem(null, 0, 0)
    var b = tooltip.parent.mapToItem(null, 0, 0)

    if (a.x + container.width < b.x) {
      _edge = 'left'
    } else if (a.x > b.x + container.width) {
      _edge = 'right'
    } else if (a.y + container.height < b.y) {
      _edge = 'top'
    } else if (a.y > b.y + b.height) {
      _edge = 'bottom'
    } else {
      // Unable to get the tooltip arrow position.
      _edge = null
    }
  }

  // Called when new image is loaded. (When the is edge is updated.)
  function _setArrowPosition () {
    var a = container.mapToItem(null, 0, 0)
    var b = tooltip.parent.mapToItem(null, 0, 0)

    if (_edge === 'left') {
      icon.x = container.width - TooltipStyle.margins - _getArrowWidthMargin()
      icon.y =  b.y - a.y + _getRelativeYArrowCenter()
    } else if (_edge === 'right') {
      icon.x = container.width + TooltipStyle.margins + _getArrowWidthMargin()
      icon.y =  b.y - a.y + _getRelativeYArrowCenter()
    } else if (_edge === 'top') {
      icon.x =  b.x - a.x + _getRelativeXArrowCenter()
      icon.y = container.height - TooltipStyle.margins - _getArrowHeightMargin()
    } else if (_edge === 'bottom') {
      icon.x =  b.x - a.x + _getRelativeXArrowCenter()
      icon.y = container.height + TooltipStyle.margins + _getArrowHeightMargin()
    }
  }

  // ---------------------------------------------------------------------------

  background: Item {
    id: container

    layer {
      enabled: true
      effect: PopupShadow {}
    }

    Rectangle {
      anchors {
        fill: parent
        margins: TooltipStyle.margins
      }
      color: TooltipStyle.backgroundColor
      radius: TooltipStyle.radius
    }

    // Do not use `Icon` component to access to `implicitHeight`
    // and `implicitWidth`.
    Image {
      id: icon

      fillMode: Image.PreserveAspectFit
      height: TooltipStyle.arrowSize
      source: _edge
        ? (Constants.imagesPath + 'tooltip_arrow_' + _edge + Constants.imagesFormat)
        : ''
      visible: tooltip.visible && _edge
      width: TooltipStyle.arrowSize
      z: Constants.zMax

      onStatusChanged: status === Image.Ready && _setArrowPosition()
    }
  }

  contentItem: Text {
    id: text

    color: TooltipStyle.color
    font.pointSize: TooltipStyle.pointSize
    padding: TooltipStyle.padding + TooltipStyle.margins
    text: tooltip.text
  }

  delay: TooltipStyle.delay

  onVisibleChanged: visible && _setArrowEdge()
}
