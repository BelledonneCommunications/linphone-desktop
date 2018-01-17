import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Rectangle {
  id: telKeypad

  property var container: parent
  property var call

  color: TelKeypadStyle.color

  layer {
    effect: PopupShadow {}
    enabled: true
  }

  height: TelKeypadStyle.height
  width: TelKeypadStyle.width

  // ---------------------------------------------------------------------------

  GridLayout {
    id: grid

    anchors.fill: parent

    columns: 4 // Not a style.
    rows: 4 // Same idea.

    columnSpacing: TelKeypadStyle.columnSpacing
    rowSpacing: TelKeypadStyle.rowSpacing

    Repeater {
      model: [
        '1', '2', '3', 'A',
        '4', '5', '6', 'B',
        '7', '8', '9', 'C',
        '*', '0', '#', 'D',
      ]

      TelKeypadButton {
        property var _timeout

        Layout.fillHeight: true
        Layout.fillWidth: true

        text: modelData

        onClicked: telKeypad.call.sendDtmf(modelData)
      }
    }
  }

  // ---------------------------------------------------------------------------

  DragBox {
    id: dragBox

    readonly property int delta: 5

    property int _id
    property var _mouseX
    property var _mouseY

    container: telKeypad.container
    draggable: parent

    xPosition: (function () {
      return 50
    })
    yPosition: (function () {
      return 50
    })

    onPressed: {
      _mouseX = mouse.x
      _mouseY = mouse.y
      _id = parseInt(_mouseX / (parent.width / grid.columns)) + parseInt(_mouseY / (parent.height / grid.rows)) * grid.columns
    }

    onReleased: {
      if (Math.abs(_mouseX - mouse.x) <= delta && Math.abs(_mouseY - mouse.y) <= delta) {
        var children = grid.children[_id]

        children.color = TelKeypadStyle.button.color.pressed
        children.clicked()

        var timeout = children._timeout
        if (timeout) {
          Utils.clearTimeout(timeout)
        }

        children._timeout = Utils.setTimeout(this, 100, (function (id) {
          grid.children[id].color = TelKeypadStyle.button.color.normal
        }).bind(this, _id))
      }
    }
  }
}
