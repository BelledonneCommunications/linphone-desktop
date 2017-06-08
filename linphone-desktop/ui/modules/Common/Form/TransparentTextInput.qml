import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0

// =============================================================================
// A editable text that has a background color on focus.
// =============================================================================

Item {
  property alias color: textInput.color
  property alias font: textInput.font
  property alias inputMethodHints: textInput.inputMethodHints
  property alias placeholder: placeholder.text
  property alias readOnly: textInput.readOnly
  property alias text: textInput.text
  property bool forceFocus: false
  property bool isInvalid: false
  property int padding: TransparentTextInputStyle.padding

  // ---------------------------------------------------------------------------

  signal editingFinished

  // ---------------------------------------------------------------------------

  onActiveFocusChanged: {
    if (activeFocus) {
      textInput.focus = true
    }
  }

  Rectangle {
    id: background

    color: (textInput.activeFocus || parent.forceFocus) && !textInput.readOnly
      ? TransparentTextInputStyle.backgroundColor
      : // No Style constant, see component name.
        // It's a `transparent` TextInput.
       'transparent'
    height: parent.height
    width: {
      var width = textInput.contentWidth + parent.padding * 2
      return width < parent.width ? width : parent.width
    }

    InvertedMouseArea {
      anchors.fill: parent
      enabled: textInput.activeFocus

      onPressed: textInput.focus = false
    }
  }

  Icon {
    id: icon

    anchors.left: background.right
    height: background.height
    icon: 'generic_error'
    iconSize: TransparentTextInputStyle.iconSize
    visible: parent.isInvalid
  }

  Text {
    id: placeholder

    anchors.centerIn: parent
    color: TransparentTextInputStyle.placeholder.color
    elide: Text.ElideRight

    font {
      italic: true
      pointSize: TransparentTextInputStyle.placeholder.pointSize
    }

    height: textInput.height
    width: textInput.width

    verticalAlignment: Text.AlignVCenter
    visible: textInput.text.length === 0 && (!textInput.activeFocus || textInput.readOnly)
  }

  TextInput {
    id: textInput

    anchors.centerIn: parent
    height: parent.height
    width: parent.width - parent.padding * 2

    clip: true
    color: activeFocus && !readOnly
      ? TransparentTextInputStyle.text.color.focused
      : TransparentTextInputStyle.text.color.normal
    font.pointSize: TransparentTextInputStyle.text.pointSize
    selectByMouse: true
    verticalAlignment: TextInput.AlignVCenter

    Keys.onEscapePressed: focus = false
    Keys.onReturnPressed: focus = false

    onEditingFinished: {
      cursorPosition = 0

      if (!parent.readOnly) {
        parent.editingFinished()
      }
    }
  }
}
