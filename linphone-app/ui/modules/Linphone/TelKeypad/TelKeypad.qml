import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0

import 'TelKeypad.js' as Logic

// =============================================================================

Rectangle {
  id: telKeypad

  property var container: parent
  property var call

  color: TelKeypadStyle.color   // useless as it is overridden by buttons color, but keep it if buttons are transparent
  onActiveFocusChanged: {if(activeFocus) selectedArea.border.width=TelKeypadStyle.selectedBorderWidth; else selectedArea.border.width=0}
  
  layer {
    effect: PopupShadow {}
    enabled: true
  }

  height: TelKeypadStyle.height
  width: TelKeypadStyle.width
  radius:TelKeypadStyle.radius+1.0 // +1 for avoid mixing color with border slection (some pixels can be print after the line)

  Keys.onPressed: {
    var index = Logic.mapKeyToButtonIndex(event.key)
    if (index != null) {
      event.accepted = true
      Logic.sendDtmf(index)
    }
  }

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
      return 80
    })
    yPosition: (function () {
      return 70
    })

    onPressed: {
      _mouseX = mouse.x
      _mouseY = mouse.y
      _id = parseInt(_mouseX / (parent.width / grid.columns)) + parseInt(_mouseY / (parent.height / grid.rows)) * grid.columns

      telKeypad.focus = true
    }

    onReleased: Math.abs(_mouseX - mouse.x) <= delta && Math.abs(_mouseY - mouse.y) <= delta &&
      Logic.sendDtmf(_id)
  }
  Rectangle{
    id: selectedArea
    anchors.fill:parent
    color:"transparent"
    border.color:TelKeypadStyle.selectedColor
    border.width:0 
    focus:false
    enabled:false
    radius:TelKeypadStyle.radius
  }
  MouseArea
  {// Just take hover events and set popup to do its automatic close if mouse is not inside field/popup area
      anchors.fill: parent
      onContainsMouseChanged: (containsMouse?telKeypad.forceActiveFocus():telKeypad.focus=false)
      hoverEnabled:true
      preventStealing: true
      propagateComposedEvents:true
      onPressed: mouse.accepted=false
      onReleased: mouse.accepted=false
      onClicked: mouse.accepted=false
      onDoubleClicked: mouse.accepted=false
      onPressAndHold: mouse.accepted=false
  }
}
