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
	
	function getDate(){
		var d = new Date()
		if(outer.currentItem)
			d.setHours(outer.currentItem.text)
		if(inner.currentItem)
			d.setMinutes(inner.currentItem.text)
		d.setSeconds(0)
		return d;
	}
	
	PathView {
		id: outer
		model: 24
		
		interactive: false
		highlightRangeMode:  PathView.NoHighlightRange
		
		highlight: Rectangle {
			id: rect
			width: 30 * 1.5
			height: width
			radius: width / 2
			border.color: "darkgray"
			color: TimePickerStyle.hoursColor
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
				onClicked: outer.currentIndex = index
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
		model: 6
		interactive: false
		highlightRangeMode:  PathView.NoHighlightRange
		
		highlight: Rectangle {
			width: 30 * 1.5
			height: width
			radius: width / 2
			border.color: "darkgray"
			color: TimePickerStyle.minutesColor
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
				text: index * 10
				color: currentItem ? TimePickerStyle.selectedItemColor : TimePickerStyle.unselectedItemColor
			}
			
			MouseArea {
				anchors.fill: parent
				onClicked: inner.currentIndex = index
			}
		}
		
		path: Path {
			id: innerPath
			property int yStep: middleMinSize  * Math.cos(2 * Math.PI / inner.count)
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
		x: centerPosition - width/2
		y: centerPosition - height/2
		
		Text {
			id: h
			font.pointSize: Units.dp * 12
			font.bold: true
			text: outer.currentItem.text.length < 2 ? '0' + outer.currentItem.text : outer.currentItem.text
			onTextChanged: mainItem.newDate(mainItem.getDate())
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
			onTextChanged: mainItem.newDate(mainItem.getDate())
		}
		
		
	}
	MouseArea {
		anchors.fill: selectedTimeArea
		onClicked: {
			mainItem.clicked(mainItem.getDate())
		}
	}
	Component.onCompleted: {
		outer.currentIndex = mainItem.selectedTime.getHours() % 24
		inner.currentIndex = mainItem.selectedTime.getMinutes() / 10
		
	}
}