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
	property bool isMandatory: false
	property alias overwriteColor: icon.overwriteColor
	property string error: ''
	property var tools
	property QtObject textFieldStyle : TextFieldStyle.normal
	onTextFieldStyleChanged: if( !textFieldStyle) textFieldStyle = TextFieldStyle.normal
	
	
	// ---------------------------------------------------------------------------
	
	background: Rectangle {
		border {
			color: textField.error.length > 0
				   ? textFieldStyle.background.border.color.error.color
				   : (
						 textField.activeFocus && !textField.readOnly
						 ? textFieldStyle.background.border.color.selected.color
						 : textFieldStyle.background.border.color.normal.color
						 )
			width: textFieldStyle.background.border.width
		}
		
		color: textField.readOnly
			   ? textFieldStyle.background.color.readOnly.color
			   : textFieldStyle.background.color.normal.color
		
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
						   ? textFieldStyle.background.border.color.error.color
						   : textFieldStyle.background.border.color.normal.color
					width: textFieldStyle.background.border.width
				}
				
				anchors.fill: parent
				color: background.color
				data: tools || []
			}
		}
	}
	
	color: textField.readOnly ? textFieldStyle.text.readOnly.color : textFieldStyle.text.normal.color
	font.pointSize: textFieldStyle.text.pointSize
	rightPadding: textFieldStyle.text.rightPadding + toolsContainer.width + (icon.visible ? icon.iconSize + 10: 0)
	selectByMouse: true
	
	// ---------------------------------------------------------------------------
	
	Icon {
		id: icon
		
		anchors {
			right: parent.right
			rightMargin: 10
			verticalCenter: parent.verticalCenter
		}
		
		iconSize: parent.contentHeight
		visible: icon.icon != ''
		
		Text{
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.topMargin: 5
			textFormat: Text.RichText
			text : '<span style="color:red">*</span>'
			color: textFieldStyle.background.mandatory.colorModel.color
			font.pointSize: textFieldStyle.background.mandatory.pointSize
			visible: textField.isMandatory
		}
		MouseArea{
			anchors.fill:	parent
			onClicked: {textField.focus = true ; textField.text = ''}
		}
	}
	bottomPadding: (statusItem.visible?statusItem.implicitHeight:2)
	TextEdit{
		id:statusItem
		selectByMouse: true
		readOnly:true
		color: textFieldStyle.background.border.color.error.color
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
