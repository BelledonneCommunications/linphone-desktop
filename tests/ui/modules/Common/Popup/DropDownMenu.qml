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
  property var launcher
  property var relativeTo

  default property alias _content: content.data

  signal menuClosed
  signal menuOpened

  function showMenu () {
    if (visible) {
      return
    }

    if (drawOnRoot) {
      this.x = relativeTo.mapToItem(null, relativeTo.width, 0).x
      this.y = relativeTo.mapToItem(null, relativeTo.width, 0).y
    }

    visible = true
    menuOpened()
  }

  function hideMenu () {
    if (!visible) {
      return
    }

    visible = false
    menuClosed()
  }

  function _computeHeight () {
    var model = _content[0].model
    if (model == null || !Utils.qmlTypeof(model, 'QQmlListModel')) {
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

  Keys.onEscapePressed: hideMenu()

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

  InvertedMouseArea {
    anchors.fill: parent
    enabled: parent.visible

    onPressed: {
      if (launcher != null && pointIsInItem(launcher)) {
        return
      }
      hideMenu()
    }
  }
}
