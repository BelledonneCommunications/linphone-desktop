import QtQuick 2.7
import QtQuick.Controls 2.0

import Common 1.0
import Common.Styles 1.0

// ===================================================================

ToolTip {
  id: tooltip

  function _getArrowHeightMargin () {
    return icon.height > icon.implicitHeight
      ? (icon.height - icon.implicitHeight) / 2
      : icon.height
  }

  function _getArrowWidthMargin () {
    return icon.width > icon.implicitWidth
      ? (icon.width - icon.implicitWidth) / 2
      : icon.width
  }

  function _getRelativeXArrowCenter () {
    return tooltip.parent.width / 2 - icon.width / 2
  }

  function _getRelativeYArrowCenter () {
    return tooltip.parent.height / 2 - icon.height / 2
  }

  function _setArrowPosition () {
    var a = container.mapToItem(null, 0, 0)
    var b = tooltip.parent.mapToItem(null, 0, 0)

    // Left.
    if (a.x + container.width < b.x) {
      icon.x = container.width - TooltipStyle.margins - _getArrowWidthMargin()
      icon.y =  b.y - a.y + _getRelativeYArrowCenter()
    }

    // Right.
    else if (a.x > b.x + container.width) {
      icon.x = container.width + TooltipStyle.margins + _getArrowWidthMargin()
      icon.y =  b.y - a.y + _getRelativeYArrowCenter()
    }

    // Top.
    else if (a.y + container.height < b.y) {
      icon.x =  b.x - a.x + _getRelativeXArrowCenter()
      icon.y = container.height - TooltipStyle.margins - _getArrowHeightMargin()
    }

    // Bottom.
    else if (a.y > b.y + b.height) {
      icon.x =  b.x - a.x + _getRelativeXArrowCenter()
      icon.y = container.height + TooltipStyle.margins + _getArrowHeightMargin()
    }

    // Error?
    else {
      throw new Error('Unable to get the tooltip arrow position')
    }
  }

  // -----------------------------------------------------------------

  background: Item {
    id: container

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
      source: Constants.imagesPath + 'tooltip_arrow' + Constants.imagesFormat
      visible: tooltip.visible
      width: TooltipStyle.arrowSize
      z: Constants.zMax
    }
  }

  contentItem: Text {
    id: text

    color: TooltipStyle.color
    font.pointSize: TooltipStyle.fontSize
    padding: TooltipStyle.padding + TooltipStyle.margins
    text: tooltip.text
  }

  delay: TooltipStyle.delay

  onVisibleChanged: visible && _setArrowPosition()
}
