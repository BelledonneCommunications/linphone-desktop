import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

// ===================================================================
// Low component to display a list/menu in a popup.
// ===================================================================

Rectangle {
  property bool drawOnRoot: false
  property int entryHeight // Only with a ListView child.
  property int maxMenuHeight // Only with a ListView child.
  property var relativeTo

  default property alias _content: content.data

  function show () {
    if (drawOnRoot) {
      this.x = relativeTo.mapToItem(null, relativeTo.width, 0).x
      this.y = relativeTo.mapToItem(null, relativeTo.width, 0).y
    }

    visible = true
  }

  function hide () {
    visible = false
  }

  function _computeHeight () {
    var model = _content[0].model
    if (model == null) {
      return content.height
    }

    var height = model.count * entryHeight
    return (maxMenuHeight !== undefined && height > maxMenuHeight)
      ? maxMenuHeight
      : height
  }

  implicitHeight: _computeHeight()
  visible: false
  z: Constants.zPopup

  Component.onCompleted: {
    if (drawOnRoot) {
      parent = Utils.getTopParent(this)
    }
  }

  Rectangle {
    id: content

    anchors.fill: parent
    color: PopupStyle.backgroundColor

    layer {
      enabled: true
      effect: PopupShadow {}
    }
  }
}
