import QtQuick 2.7
import QtQuick.Controls 2.2

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Rectangle {
	id: mainItem
	property alias text: textArea.text
	property alias placeholderText: textArea.placeholderText
	readonly property alias length: textArea.length
	property alias boundsBehavior: flickable.boundsBehavior
	property alias font: textArea.font
	property alias textColor: textArea.color
	property alias readOnly: textArea.readOnly
	property int padding: TextAreaFieldStyle.text.padding
	property alias implicitHeight: flickable.contentHeight
	property int fitWidth: 0
	
	height: TextAreaFieldStyle.background.height
	width: TextAreaFieldStyle.background.width
	border {
		color: TextAreaFieldStyle.background.border.colorModel.color
		width: TextAreaFieldStyle.background.border.width
	}
	
	color: textArea.readOnly
		   ? TextAreaFieldStyle.background.color.readOnly.color
		   : TextAreaFieldStyle.background.color.normal.color
	
	radius: TextAreaFieldStyle.background.radius
// Fit Width computation
	onTextChanged:{
		var lines = text.split('\n')
		var totalWidth = 0
		for(var index in lines){
			metrics.text = lines[index]
			if( totalWidth < metrics.width)
				totalWidth = metrics.width
		 }
		 fitWidth = totalWidth
	}
	TextMetrics{
		id: metrics
		font: mainItem.font
	}
//-----------------------------------
	Flickable {
		id: flickable
		anchors.fill: parent
		
		boundsBehavior: Flickable.StopAtBounds
		
		ScrollBar.vertical: ForceScrollBar {
			id: scrollBar
			
			contentSizeTarget: flickable.contentHeight
			sizeTarget: flickable.height
			Component.onCompleted: updatePolicy()
		}
		TextArea.flickable: TextArea {
			id: textArea
			
			background: Item{}
			
			color: TextAreaFieldStyle.text.colorModel.color
			font.pointSize: TextAreaFieldStyle.text.pointSize
			selectByMouse: true
			wrapMode: TextArea.Wrap
			height: flickable.height
			
			bottomPadding: mainItem.padding
			leftPadding: mainItem.padding
			rightPadding: mainItem.padding + Number(scrollBar.visible) * scrollBar.width
			topPadding: mainItem.padding
		}
	}
}
