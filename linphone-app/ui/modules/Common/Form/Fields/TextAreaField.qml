import QtQuick 2.7
import QtQuick.Controls 2.2

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Rectangle {
	
	property alias text: textArea.text
	property alias placeholderText: textArea.placeholderText
	readonly property alias length: textArea.length
	property alias boundsBehavior: flickable.boundsBehavior
	property alias font: textArea.font
	property alias textColor: textArea.color
	property alias readOnly: textArea.readOnly
	
	height: TextAreaFieldStyle.background.height
	width: TextAreaFieldStyle.background.width
	border {
		color: TextAreaFieldStyle.background.border.color
		width: TextAreaFieldStyle.background.border.width
	}
	
	color: textArea.readOnly
		   ? TextAreaFieldStyle.background.color.readOnly
		   : TextAreaFieldStyle.background.color.normal
	
	radius: TextAreaFieldStyle.background.radius
	
	Flickable {
		id: flickable
		anchors.fill: parent
		
		boundsBehavior: Flickable.StopAtBounds
		
		ScrollBar.vertical: ForceScrollBar {
			id: scrollBar
		}
		
		TextArea.flickable: TextArea {
			id: textArea
			
			background: Item{}
			
			color: TextAreaFieldStyle.text.color
			font.pointSize: TextAreaFieldStyle.text.pointSize
			selectByMouse: true
			wrapMode: TextArea.Wrap
			height: flickable.height
			
			bottomPadding: TextAreaFieldStyle.text.padding
			leftPadding: TextAreaFieldStyle.text.padding
			rightPadding: TextAreaFieldStyle.text.padding + Number(scrollBar.visible) * scrollBar.width
			topPadding: TextAreaFieldStyle.text.padding
		}
	}
}
