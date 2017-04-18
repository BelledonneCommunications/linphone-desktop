import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0

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

    columns: 3 // Not a style.
    rows: 4 // Same idea.

    columnSpacing: TelKeypadStyle.columnSpacing
    rowSpacing: TelKeypadStyle.rowSpacing

    Repeater {
      model: [{
        text: '1',
        icon: 'answering_machine'
      }, {
        text: '2'
      },{
        text: '3'
      }, {
        text: '4'
      }, {
        text: '5'
      }, {
        text: '6'
      }, {
        text: '7'
      }, {
        text: '8'
      }, {
        text: '9'
      }, {
        text: '*'
      }, {
        text: '0',
        icon: 'plus'
      }, {
        text: '#'
      }]

      TelKeypadButton {
        Layout.fillHeight: true
        Layout.fillWidth: true

        icon: modelData.icon || ''
        text: modelData.text

        onClicked: {
          var text = modelData.text
          console.info('Send dtmf: ' + text)
          telKeypad.call.sendDtmf(text)
        }
      }
    }
  }

  // ---------------------------------------------------------------------------

  DragBox {
    id: dragBox

    readonly property int delta: 5

    property var _mouseX
    property var _mouseY

    container: telKeypad.container
    draggable: parent

    xPosition: (function () {
      return 0
    })
    yPosition: (function () {
      return 0
    })

    onPressed: {
      _mouseX = mouse.x
      _mouseY = mouse.y
    }

    onReleased: {
      if (Math.abs(_mouseX - mouse.x) <= delta && Math.abs(_mouseY - mouse.y) <= delta) {
        var id = parseInt(_mouseX / (parent.width / grid.columns)) + parseInt(_mouseY / (parent.height / grid.rows)) * grid.columns
        grid.children[id].clicked()
      }
    }
  }
}
