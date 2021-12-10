import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Units 1.0

Item{
	id: mainItem
	
	property alias selectedDate: monthList.selectedDate
	
	signal clicked(date date);
	
	RowLayout {
		id: headerRow
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		height: 30
		ActionButton{
			isCustom: true
			colorSet: DatePickerStyle.nextMonthButton
			rotation: 180
			onClicked: --monthList.currentIndex
		}
		Text { // month year
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignCenter
			horizontalAlignment: Qt.AlignCenter
			text: new Date(monthList.currentYear, monthList.currentMonth, 1).toLocaleString(Qt.locale(), 'MMMM yyyy')
			font.pointSize: Units.dp * 11
		}
		ActionButton{
			isCustom: true
			colorSet: DatePickerStyle.nextMonthButton
			onClicked: ++monthList.currentIndex
		}
	}
	ListView {
		id: monthList
		anchors.top: headerRow.bottom
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		//Layout.fillWidth: true
		//Layout.fillHeight: true
		
		property int maxYears: 5	// Max years to be requested.
		
		function set(date) {
			selectedDate = new Date(date)
			positionViewAtIndex((selectedDate.getFullYear()-minYear) * 12 + selectedDate.getMonth(), ListView.Center)
		}
			
		
		
		property date selectedDate
		property int minYear: new Date(0,0,0).getFullYear()
		
		snapMode:    ListView.SnapOneItem
		orientation: Qt.Horizontal
		clip:        true
		
		// One model per month
		model: (new Date().getFullYear()- minYear + maxYears) * 12
		
		property int currentYear:      Math.floor(currentIndex / 12) + minYear
		property int currentMonth:     currentIndex % 12
		
		highlightFollowsCurrentItem: true
		highlightRangeMode: ListView.StrictlyEnforceRange
		highlightMoveDuration: 100
		delegate: Item {
			width: monthList.width;  height: monthList.height
			
			property int year:      Math.floor(index / 12) + monthList.minYear 
			property int month:     index % 12
			property int firstDay:  new Date(year, month, 1).getDay()
			
			Column {
				
				Grid { // 1 month calender
					id: grid
					
					width: monthList.width;  height: monthList.height
					property real cellWidth:  width  / columns;
					property real cellHeight: height / rows // width and height of each cell in the grid.
					
					columns: 7 // days
					rows:    7
					
					Repeater {
						model: grid.columns * grid.rows // 49 cells per month
						
						delegate: Rectangle { // index is 0 to 48
							property int day:  index - 7 // 0 = top left below Sunday (-7 to 41)
							property int date: day - firstDay + 1 // 1-31
							
							width: grid.cellWidth;  height: grid.cellHeight
							border.width: 0.3 * radius
							border.color: new Date(year, month, date).toDateString() == monthList.selectedDate.toDateString()  &&  text.text  &&  day >= 0?
											  'black': 'transparent' // selected
							radius: 0.02 * monthList.height
							opacity: !mouseArea.pressed? 1: 0.3  //  pressed state
							
							Text {
								id: text
								
								anchors.centerIn: parent
								font.pixelSize: day < 0 ? Units.dp * 11 : Units.dp * 10
								font.bold:      day < 0 || new Date(year, month, date).toDateString() == new Date().toDateString() // today
								text: {
									if(day < 0)
										// Magic date to set day names in this order : 'S', 'M', 'T', 'W', 'T', 'F', 'S' in Locale
										return new Date(1,3,index).toLocaleString(Qt.locale(), 'ddd')[0]
									else if(new Date(year, month, date).getMonth() == month)
										return date
									else
										return ''
								}
							}
							
							MouseArea {
								id: mouseArea
								
								anchors.fill: parent
								enabled:    text.text  &&  day >= 0
								
								onClicked: {
									monthList.selectedDate = new Date(year, month, date)
									mainItem.clicked(monthList.selectedDate)
								}
							}
						}
					}
				}
			}
		}
		Component.onCompleted: set(mainItem.selectedDate)
	}
}