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
  property alias iconSize: icon.iconSize
  property alias overwriteColor: icon.overwriteColor
  property string error: ''
  property var tools
  property QtObject textFieldStyle : TextFieldStyle.normal
  property bool showWhenEmpty: true
  onTextFieldStyleChanged: if( !textFieldStyle) textFieldStyle = TextFieldStyle.normal
  
  signal iconClicked()

  // ---------------------------------------------------------------------------

  background: Rectangle {
    border {
      color: textField.error.length > 0
        ? textFieldStyle.background.border.color.error
        : (
          textField.activeFocus && !textField.readOnly
            ? textFieldStyle.background.border.color.selected
            : textFieldStyle.background.border.color.normal
        )
      width: textFieldStyle.background.border.width
    }

    color: textField.readOnly
      ? textFieldStyle.background.color.readOnly
      : textFieldStyle.background.color.normal

    implicitHeight: textFieldStyle.background.height
    implicitWidth: textFieldStyle.background.width

    radius: textFieldStyle.background.radius

    MouseArea {
      anchors.right: parent.right
      height: parent.height
      cursorShape: Qt.ArrowCursor
      implicitWidth: tools ? tools.width : 0

      Rectangle {
        id: toolsContainer

        border {
          color: textField.error.length > 0
            ? textFieldStyle.background.border.color.error
            : textFieldStyle.background.border.color.normal
          width: textFieldStyle.background.border.width
        }

        anchors.fill: parent
        color: background.color
        data: tools || []
      }
    }
  }

  color: textField.readOnly ? textFieldStyle.text.readOnly : textFieldStyle.text.normal
  font.pointSize: textFieldStyle.text.pointSize
  rightPadding: textFieldStyle.text.rightPadding + toolsContainer.width
  selectByMouse: true

  // ---------------------------------------------------------------------------

  Icon {
    id: icon

    anchors {
      right: parent.right
      rightMargin: parent.rightPadding
      verticalCenter: parent.verticalCenter
    }

    iconSize: parent.contentHeight
    visible: showWhenEmpty && !parent.text || !showWhenEmpty && parent.text
    MouseArea{
		anchors.fill:	parent
		onClicked: textField.iconClicked()
    }
  }
  bottomPadding: (statusItem.visible?statusItem.implicitHeight:2)
  TextEdit{
	  id:statusItem
	  selectByMouse: true
	  readOnly:true
	  color: textFieldStyle.background.border.color.error
	  width:parent.width
	  anchors.bottom:parent.bottom
	  anchors.bottomMargin: 2
	  anchors.right:parent.right
	  anchors.rightMargin:10 + toolsContainer.width
	  horizontalAlignment:Text.AlignRight
	  verticalAlignment: Text.AlignVCenter
	  wrapMode: TextEdit.WordWrap
	  font {
		  italic: true
		  pointSize: textFieldStyle.text.pointSize
	  }
	  visible:error!= ''
	  text:error
  }
	Keys.onPressed:{
		if( event.key == Qt.Key_Escape)
			focus = false
	}
}
