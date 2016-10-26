import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

// ===================================================================
// Low component to display a list/menu in a popup.
// ===================================================================

Item {
  // Optionnal parameter, if defined and if a click is detected
  // on it, menu is not closed.
  property var launcher

  // Optionnal parameters, set the position of Menu relative
  // to this item.
  property var relativeTo
  property int relativeX: 0
  property int relativeY: 0

  default property alias _content: content.data

  signal menuClosed
  signal menuOpened

  // -----------------------------------------------------------------

  function isOpen () {
    return visible
  }

  function showMenu () {
    if (visible) {
      return
    }

    if (relativeTo != null) {
      this.x = relativeTo.mapToItem(null, relativeX, relativeY).x
      this.y = relativeTo.mapToItem(null, relativeX, relativeY).y
    }

    visible = true
    menuOpened()

    // Necessary to use `Keys.onEscapePressed`.
    focus = true
  }

  function hideMenu () {
    if (!visible) {
      return
    }

    visible = false
    menuClosed()
  }

  function _computeHeight () {
    console.exception('Virtual method must be implemented.')
  }

  // -----------------------------------------------------------------

  implicitHeight: _computeHeight()
  visible: false
  z: Constants.zPopup

  Keys.onEscapePressed: hideMenu()

  // Set parent menu to root.
  Component.onCompleted: {
    if (relativeTo != null) {
      parent = Utils.getTopParent(this)
    }
  }

  // Menu content.
  Rectangle {
    id: content

    anchors.fill: parent
    color: PopupStyle.backgroundColor

    layer {
      enabled: true
      effect: PopupShadow {}
    }
  }

  // Inverted mouse area to detect click outside menu.
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
