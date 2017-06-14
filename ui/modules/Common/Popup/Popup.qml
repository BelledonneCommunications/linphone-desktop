import QtQuick 2.7
import QtQuick.Controls 2.1 as Controls

import Common.Styles 1.0
import Utils 1.0

// =============================================================================

Item {
  id: wrapper

  // Optionnal parameters, set the position of popup relative to this item.
  property var relativeTo
  property int relativeX: 0
  property int relativeY: 0

  default property alias _content: popup.contentItem

  // ---------------------------------------------------------------------------

  signal closed
  signal opened

  // ---------------------------------------------------------------------------

  function open () {
    if (popup.visible) {
      return
    }

    if (relativeTo) {
      var parent = Utils.getTopParent(this)

      popup.x = Qt.binding(function () {
        return relativeTo ? relativeTo.mapToItem(null, relativeX, relativeY).x : 0
      })
      popup.y = Qt.binding(function () {
        return relativeTo ? relativeTo.mapToItem(null, relativeX, relativeY).y : 0
      })
    } else {
      popup.x = Qt.binding(function () {
        return x
      })
      popup.y = Qt.binding(function () {
        return y
      })
    }

    popup.open()
  }

  function close () {
    if (!popup.visible) {
      return
    }

    popup.x = 0
    popup.y = 0

    popup.close()
  }

  // ---------------------------------------------------------------------------

  visible: false

  // ---------------------------------------------------------------------------

  Controls.Popup {
    id: popup

    height: wrapper._content.height
    width: wrapper._content.width

    background: Rectangle {
      color: PopupStyle.backgroundColor
      height: popup.height
      width: popup.width

      layer {
        enabled: true
        effect: PopupShadow {}
      }
    }

    padding: 0

    Component.onCompleted: parent = Utils.getTopParent(this)

    onClosed: wrapper.closed()
    onOpened: wrapper.opened()
  }
}
