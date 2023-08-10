import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Units 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

Item{
	id: mainItem
	property bool allYears : false	// if false : years from today
	property alias selectedDate: monthList.selectedDate
	property bool hideOldDates : false
	
	signal clicked(date date);
	
	RowLayout {
		id: headerRow
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.topMargin: 5
		
		height: 30
		Layout.alignment: Qt.AlignCenter
		ActionButton{
			isCustom: true
			colorSet: DatePickerStyle.nextMonthButton
			rotation: 180
			onClicked: --monthList.currentIndex
			visible: monthList.currentIndex > 0
		}
		Text { // month year
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignCenter
			horizontalAlignment: Qt.AlignCenter
			text: new Date(monthList.currentYear, monthList.currentMonth, 15).toLocaleString(App.locale, 'MMMM yyyy')// 15 because of timezones that can change the date for localeString
			color: DatePickerStyle.title.colorModel.color
			font.pointSize: DatePickerStyle.title.pointSize
			font.capitalization: Font.Capitalize
		}
		ActionButton{
			isCustom: true
			colorSet: DatePickerStyle.nextMonthButton
			onClicked: ++monthList.currentIndex
			visible: monthList.currentIndex < monthList.count
		}
	}
	ListView {
		id: monthList
		anchors.top: headerRow.bottom
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.topMargin: 10
		
		cacheBuffer:0
		property int maxYears: 5	// Max years to be requested.
		
		function set(date) {
			selectedDate = new Date(date)
			var moveTo = (selectedDate.getFullYear()-minYear) * 12 + selectedDate.getMonth()
			currentIndex = moveTo
		}
		
		property date selectedDate: new Date()
		property int minYear: mainItem.allYears ? new Date(0,0,1).getFullYear() : new Date().getFullYear()
		
		snapMode:    ListView.SnapOneItem
		orientation: Qt.Horizontal
		clip:        true
		
		// One model per month
		model: (new Date().getFullYear()- minYear + maxYears) * 12
		currentIndex: 0
		property int currentYear:      Math.floor(currentIndex / 12) + minYear
		property int currentMonth:     currentIndex % 12
		
		highlightFollowsCurrentItem: true
		highlightRangeMode: ListView.StrictlyEnforceRange
		highlightMoveDuration: 100
		
		Component.onCompleted:  monthList.set(mainItem.selectedDate)
		
		delegate: Item {
			width: monthList.width == 0 ? 100 : monthList.width
			height: monthList.height == 0 ? 100 : monthList.height
			
			property int year:      Math.floor(index / 12) + monthList.minYear 
			property int month:     index % 12
			property int firstDay:  new Date(year, month, 1).getDay()
			
			GridLayout { // 1 month calender
				id: grid
				
				//width: monthList.width;  height: monthList.height
				anchors.fill: parent
				property real cellWidth:  width  / columns;
				property real cellHeight: height / rows // width and height of each cell in the grid.
				property real cellMinSize: Math.min(cellHeight, cellWidth)
				
				columns: 7 // days
				rows:    8
				
				Repeater {
					model: grid.columns * grid.rows // 49 cells per month
					
					delegate: Item{
						id: cellItem
						property int day: index - 7 // 0 = top left below Sunday (-7 to 41)
						property int date: day - firstDay + 1 // 1-31
						property date cellDate: new Date(year, month, date)
						property bool selected : text.text != '-' 
											&& Utils.equalDate(cellDate, monthList.selectedDate)
											&& text.text && day >= 0
						width: grid.cellMinSize
						height: width
						
						Rectangle { // index is 0 to 48
							anchors.centerIn: parent
							width: Math.min(parent.width, Math.max(text.implicitWidth, text.implicitHeight) + 20)
							height: width
							//border.width: 0.3 * radius
							border.width: 2
							border.color: cellItem.selected ? DatePickerStyle.cell.selectedBorderColor.color : 'transparent' // selected
							//radius: 0.02 * monthList.height
							radius: width/2
							opacity: !mouseArea.pressed? 1: 0.3  //  pressed state
							
							Text {
								id: text
								
								anchors.centerIn: parent
								color: DatePickerStyle.cell.colorModel.color
								font.pixelSize: cellItem.selected 
													? DatePickerStyle.cell.selectedPointSize
													: cellItem.day < 0 
														? DatePickerStyle.cell.dayHeaderPointSize
														: DatePickerStyle.cell.dayPointSize
								font.bold: cellItem.day < 0 || cellItem.selected || Utils.equalDate(cellItem.cellDate, new Date()) // today
								text: {
									if(cellItem.day < 0){
										// Magic date to set day names in this order : 'S', 'M', 'T', 'W', 'T', 'F', 'S' in Locale
										return App.locale.dayName(index)[0].toUpperCase()
									}else if(cellItem.cellDate.getMonth() == month && (!hideOldDates || new Date(year, month, cellItem.date+1) >= new Date()))	// new Date use time too
										return cellItem.date
									else
										return '-'
								}
							}
						}
						
						MouseArea {
							id: mouseArea
							
							anchors.fill: parent
							enabled:    text.text && text.text != '-' &&  cellItem.day >= 0
							
							onClicked: {
								monthList.selectedDate = cellItem.cellDate
								mainItem.clicked(monthList.selectedDate)
							}
						}
					}
				}
			}
		}
	}
}
