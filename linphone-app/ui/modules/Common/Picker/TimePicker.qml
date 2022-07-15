import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Units 1.0

Item{
	id: mainItem
		
	property date selectedTime
	property int border: 25
	
	property int centerPosition: Math.min(height, width)/2
	property int middleMinSize: centerPosition - border	// Minus border
	
	signal newDate(date date)
	signal clicked(date date)
	
	onNewDate: selectedTime = date
	
	function getDate(hText, mText){
		var d = new Date()
		if(hText || outer.currentItem)
			d.setHours(hText ? hText : outer.currentItem.text)
		if(mText || inner.currentItem)
			d.setMinutes(mText ? mText : inner.currentItem.text)
		d.setSeconds(0)
		return d;
	}
	
	PathView {
		id: outer
		model: 24
		
		interactive: false
		highlightRangeMode:  PathView.NoHighlightRange
		
		currentIndex:	0
		Connections{// startX/Y begin from currentIndex. It must be set to 0 at first.
			target: mainItem
			onSelectedTimeChanged: outer.currentIndex = mainItem.selectedTime.getHours() % 24
		}
		Component.onCompleted: currentIndex = mainItem.selectedTime.getHours() % 24
		
		highlight: Rectangle {
			id: rect
			width: 30 * 1.5
			height: width
			radius: width / 2
			border.color: TimePickerStyle.hoursColor
			border.width: 3
		}
		
		delegate: Item {
			id: del
			width: 30
			height: 30
			property bool currentItem: PathView.view.currentIndex == index
			property alias text : hourText.text
			Text {
				id: hourText
				anchors.centerIn: parent
				font.pointSize: Units.dp * 11
				font.bold: currentItem
				text: index
				color: currentItem ? TimePickerStyle.selectedItemColor : TimePickerStyle.unselectedItemColor
			}
			
			MouseArea {
				anchors.fill: parent
				onClicked: mainItem.selectedTime = mainItem.getDate(parent.text, undefined)
			}
		}
		
		path: Path {
			id: outPath
			property int yStep: middleMinSize * Math.cos(2 * Math.PI / outer.count) 
			
			startX: mainItem.centerPosition
			startY: mainItem.centerPosition - outPath.yStep 
			PathArc {
				x: mainItem.centerPosition; y: mainItem.centerPosition + outPath.yStep
				radiusX: 110; radiusY: 110
				useLargeArc: false
			}
			PathArc {
				x: mainItem.centerPosition; y: mainItem.centerPosition - outPath.yStep
				radiusX: 110; radiusY: 110
				useLargeArc: false
			}
		}
	}
	
	PathView {
		id: inner
		model: 12
		interactive: false
		highlightRangeMode:  PathView.NoHighlightRange
		
		currentIndex:	0
		Connections{// startX/Y begin from currentIndex. It must be set to 0 at first.
			target: mainItem
			onSelectedTimeChanged: inner.currentIndex = mainItem.selectedTime.getMinutes() / 5
		}
		Component.onCompleted: currentIndex = mainItem.selectedTime.getMinutes() / 5
		
		highlight: Rectangle {
			width: 30 * 1.5
			height: width
			radius: width / 2
			border.color: TimePickerStyle.minutesColor
			border.width: 3
		}
		
		delegate: Item {
			width: 30
			height: 30
			property bool currentItem: PathView.view.currentIndex == index
			property alias text : textMin.text
			Text {
				id: textMin
				anchors.centerIn: parent
				font.pointSize: Units.dp * 11
				font.bold: currentItem
				text: index * 5
				color: currentItem ? TimePickerStyle.selectedItemColor : TimePickerStyle.unselectedItemColor
			}
			
			MouseArea {
				anchors.fill: parent
				onClicked: mainItem.selectedTime = mainItem.getDate(undefined, parent.text)
			}
		}
		
		path: Path {
			id: innerPath
			property int yStep: (middleMinSize - 30 )  * Math.cos(2 * Math.PI / inner.count)
			startX: mainItem.centerPosition; startY: mainItem.centerPosition - innerPath.yStep
			PathArc {
				x: mainItem.centerPosition; y: mainItem.centerPosition + innerPath.yStep
				radiusX: 40; radiusY: 40
				useLargeArc: false
			}
			PathArc {
				x: mainItem.centerPosition; y: mainItem.centerPosition - innerPath.yStep
				radiusX: 40; radiusY: 40
				useLargeArc: false
			}
		}
	}
	
	RowLayout {
		id: selectedTimeArea
		property int cBinding: centerPosition	// remove binding loop
		onCBindingChanged: Qt.callLater(function(){x = centerPosition - width/2; y= centerPosition - height/2})// To avoid binding loops
		
		Text {
			id: h
			font.pointSize: Units.dp * 12
			font.bold: true
			text: outer.currentItem.text.length < 2 ? '0' + outer.currentItem.text : outer.currentItem.text
		}
		Text {
			id: div
			font.pointSize: Units.dp * 12
			font.bold: true
			text: ':'
		}
		Text {
			id: m
			font.pointSize: Units.dp * 12
			font.bold: true
			text: inner.currentItem.text.length < 2 ? '0' + inner.currentItem.text : inner.currentItem.text
		}
		
		
	}
	MouseArea {
		anchors.fill: selectedTimeArea
		onClicked: {
			mainItem.selectedTime = mainItem.getDate()
			mainItem.clicked(mainItem.selectedTime)
		}
	}
}