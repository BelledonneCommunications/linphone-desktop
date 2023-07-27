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
	property alias text: textInput.oldText
	property bool forceFocus: false
	property bool isInvalid: false
	property int padding: TransparentTextInputStyle.padding
	
	// ---------------------------------------------------------------------------
	
	signal editingFinished
	
	// ---------------------------------------------------------------------------
	
	onActiveFocusChanged: {
		if (activeFocus) {
			textInput.forceActiveFocus()
		}
	}
	
	Rectangle {
		id: background
		property bool displayBackground: (textInput.activeFocus || parent.forceFocus) && !textInput.readOnly
		color: displayBackground
			   ? TransparentTextInputStyle.backgroundColor.color
			   : // No Style constant, see component name.
				 // It's a `transparent` TextInput.
				 'transparent'
		height: parent.height
		width: {
			var width = Math.max(textInput.contentWidth, placeholder.contentWidth) + parent.padding * 2
			return width < parent.width ? width : parent.width
		}
		
		InvertedMouseArea {
			anchors.fill: parent
			enabled: textInput.activeFocus
			
			onPressed: textInput.updateText()
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
		color: TransparentTextInputStyle.placeholder.colorModel.color
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
			   ? TransparentTextInputStyle.text.color.focused.color
			   : TransparentTextInputStyle.text.color.normal.color
		font.pointSize: TransparentTextInputStyle.text.pointSize
		selectByMouse: true
		verticalAlignment: TextInput.AlignVCenter
		
		Keys.onEscapePressed: cancelText()
		Keys.onEnterPressed: textInput.updateText()
		Keys.onReturnPressed: textInput.updateText()
		
		property string oldText
		onOldTextChanged: if(text!=oldText) text = oldText
		function cancelText(){
			text = oldText
			focus = false
		}
		function updateText(){
			cursorPosition = 0
			oldText = text
			
			if (!parent.readOnly) {
				parent.editingFinished()
			}
			focus = false
		}
		onEditingFinished: {
			if(focus){
				updateText()
			}
		}
	}
}
