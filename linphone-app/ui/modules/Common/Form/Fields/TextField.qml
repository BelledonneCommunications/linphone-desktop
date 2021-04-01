import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls

import Common 1.0
import Common.Styles 1.0

// =============================================================================
// A classic TextInput which supports an icon attribute.
// =============================================================================

Controls.TextField {
  id: textField

  // ---------------------------------------------------------------------------

  property alias icon: icon.icon
  property string error: ''
  property var tools

  // ---------------------------------------------------------------------------

  background: Rectangle {
    border {
      color: textField.error.length > 0
        ? TextFieldStyle.background.border.color.error
        : (
          textField.activeFocus && !textField.readOnly
            ? TextFieldStyle.background.border.color.selected
            : TextFieldStyle.background.border.color.normal
        )
      width: TextFieldStyle.background.border.width
    }

    color: textField.readOnly
      ? TextFieldStyle.background.color.readOnly
      : TextFieldStyle.background.color.normal

    implicitHeight: TextFieldStyle.background.height
    implicitWidth: TextFieldStyle.background.width

    radius: TextFieldStyle.background.radius

    MouseArea {
      anchors.right: parent.right
      height: parent.height
      cursorShape: Qt.ArrowCursor
      implicitWidth: tools ? tools.width : 0

      Rectangle {
        id: toolsContainer

        border {
          color: textField.error.length > 0
            ? TextFieldStyle.background.border.color.error
            : TextFieldStyle.background.border.color.normal
          width: TextFieldStyle.background.border.width
        }

        anchors.fill: parent
        color: background.color
        data: tools || []
      }
    }
  }

  color: TextFieldStyle.text.color
  font.pointSize: TextFieldStyle.text.pointSize
  rightPadding: TextFieldStyle.text.rightPadding + toolsContainer.width
  selectByMouse: true

  // ---------------------------------------------------------------------------

  onEditingFinished: cursorPosition = 0

  onTextChanged: {
    if (!focus) {
      cursorPosition = 0
    }
  }

  // ---------------------------------------------------------------------------

  Icon {
    id: icon

    anchors {
      right: parent.right
      rightMargin: parent.rightPadding
      verticalCenter: parent.verticalCenter
    }

    iconSize: parent.contentHeight
    visible: !parent.text
  }
  bottomPadding: (statusItem.visible?statusItem.height:0)
  TextEdit{
	  id:statusItem
	  selectByMouse: true
	  readOnly:true
	  color: TextFieldStyle.background.border.color.error
	  width:parent.width
	  anchors.bottom:parent.bottom
	  anchors.right:parent.right
	  anchors.rightMargin:10 + toolsContainer.width
	  horizontalAlignment:Text.AlignRight
	  font {
		  italic: true
		  pointSize: TextFieldStyle.text.pointSize
	  }
	  visible:error!= ''
	  text:error
  }
}
