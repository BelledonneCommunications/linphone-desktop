import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Units 1.0

Item{
	id: mainItem
		
	property string selectedTime
	property int border: 25
	
	property int centerPosition: Math.min(height, width)/2
	property int middleMinSize: centerPosition - border	// Minus border
	
	signal newTime(string time)
	signal clicked(string time)
	
	onNewTime: selectedTime = time
	
	function getTime(hText, mText){
		var h = (hText ? hText : outer.currentItem.text)
		if(h.length == 1)
			h = '0'+h
		var m = (mText ? mText : inner.currentItem.text)
		if(m.length == 1)
			m = '0'+m
		return h+':'+m
	}
	function getHours(time){
		var partsArray = time.split(':');
		return partsArray[0] && partsArray[0].length > 1 ? partsArray[0] : '0'+partsArray[0]
	}
	function getMinutes(time){
		var partsArray = time.split(':');
		return partsArray[1] && partsArray[1].length > 1 ? partsArray[1] : '0'+partsArray[1]
	}

	PathView {
		id: outer
		model: 24
		
		interactive: false
		highlightRangeMode:  PathView.NoHighlightRange
		
		currentIndex:	0
		Connections{// startX/Y begin from currentIndex. It must be set to 0 at first.
			target: mainItem
			onSelectedTimeChanged: outer.currentIndex = mainItem.getHours(mainItem.selectedTime) % 24
		}
		Component.onCompleted: currentIndex = mainItem.getHours(mainItem.selectedTime) % 24
		
		highlight: Rectangle {
			id: rect
			width: 30 * 1.5
			height: width
			radius: width / 2
			border.color: TimePickerStyle.hoursColor.color
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
				color: currentItem ? TimePickerStyle.selectedItemColor.color : TimePickerStyle.unselectedItemColor.color
			}
			MouseArea {
				anchors.fill: parent
				onClicked: mainItem.selectedTime = mainItem.getTime(parent.text, undefined)
			}
		}
		
		path: Path {
			id: outPath
			property int yStep: middleMinSize * Math.cos(2 * Math.PI / outer.count) 
			
			startX: mainItem.centerPosition+10
			startY: mainItem.centerPosition - outPath.yStep
			PathArc {
				x: mainItem.centerPosition+10; y: mainItem.centerPosition + outPath.yStep
				radiusX: 110; radiusY: 110
				useLargeArc: false
			}
			PathArc {
				x: mainItem.centerPosition+10; y: mainItem.centerPosition - outPath.yStep
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
			onSelectedTimeChanged: inner.currentIndex = mainItem.getMinutes(mainItem.selectedTime) / 5
		}
		Component.onCompleted: currentIndex = mainItem.getMinutes(mainItem.selectedTime) / 5
		
		highlight: Rectangle {
			width: 30 * 1.5
			height: width
			radius: width / 2
			border.color: TimePickerStyle.minutesColor.color
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
				color: currentItem ? TimePickerStyle.selectedItemColor.color : TimePickerStyle.unselectedItemColor.color
			}
			
			MouseArea {
				anchors.fill: parent
				onClicked: mainItem.selectedTime = mainItem.getTime(undefined, parent.text)
			}
		}
		
		path: Path {
			id: innerPath
			property int yStep: (middleMinSize - 30 )  * Math.cos(2 * Math.PI / inner.count)
			startX: mainItem.centerPosition+10; startY: mainItem.centerPosition - innerPath.yStep
			PathArc {
				x: mainItem.centerPosition+10; y: mainItem.centerPosition + innerPath.yStep
				radiusX: 40; radiusY: 40
				useLargeArc: false
			}
			PathArc {
				x: mainItem.centerPosition+10; y: mainItem.centerPosition - innerPath.yStep
				radiusX: 40; radiusY: 40
				useLargeArc: false
			}
		}
	}
	
	RowLayout {
		id: selectedTimeArea
		anchors.centerIn: parent
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
			mainItem.selectedTime = mainItem.getTime()
			mainItem.clicked(mainItem.selectedTime)
		}
	}
}
