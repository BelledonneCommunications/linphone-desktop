import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control
import QtQuick.Effects

import Linphone
import ConstantsCpp 1.0
import UtilsCpp 1.0

ListView {
	id: mainItem
	snapMode: ListView.SnapOneItem
	orientation: Qt.Horizontal
	clip: true
	property int maxYears: 5
	readonly property var currentDate: new Date()
	highlightMoveDuration: 100
	// height: contentHeight

	property var selectedDate

	property int currentMonth: calendarModel.monthAt(currentIndex) + 1 //january is index 0
	property int currentYear: calendarModel.yearAt(currentIndex)
	onCurrentYearChanged: console.log("currentyear", currentYear)
	onCurrentMonthChanged: console.log("current month", currentMonth)

	model: Control.CalendarModel {
		id: calendarModel
		from: new Date()
		to: UtilsCpp.addYears(new Date(), 5)
	}
	
	delegate: ColumnLayout {
		width: mainItem.width
		height: mainItem.height
		property int currentMonth: model.month
		spacing: 18 * DefaultStyle.dp
		RowLayout {
			Layout.fillWidth: true
			spacing: 38 * DefaultStyle.dp
			Text {
				text: UtilsCpp.toDateMonthAndYearString(new Date(model.year, model.month, 15))// 15 because of timezones that can change the date for localeString
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 700 * DefaultStyle.dp
					capitalization: Font.Capitalize
				}
			}
			Item {
				Layout.fillWidth: true
			}
			Button {
				Layout.preferredWidth: 20 * DefaultStyle.dp
				Layout.preferredHeight: 20 * DefaultStyle.dp
				icon.width: width
				icon.height: height
				background: Item{}
				icon.source: AppIcons.leftArrow
				onClicked: if (mainItem.currentIndex > 0) mainItem.currentIndex = mainItem.currentIndex - 1
			}
			Button {
				Layout.preferredWidth: 20 * DefaultStyle.dp
				Layout.preferredHeight: 20 * DefaultStyle.dp
				icon.width: width
				icon.height: height
				background: Item{}
				icon.source: AppIcons.rightArrow
				onClicked: if (mainItem.currentIndex < mainItem.count) mainItem.currentIndex = mainItem.currentIndex + 1
			}
		}

		ColumnLayout {
			spacing: 12 * DefaultStyle.dp
			Control.DayOfWeekRow {
				locale: monthGrid.locale
				Layout.column: 1
				Layout.fillWidth: true
				delegate: Text {
					text: model.shortName
					color: DefaultStyle.main2_400
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 300 * DefaultStyle.dp
					}
				}
			}

			Control.MonthGrid {
				id: monthGrid
				Layout.fillWidth: true
				Layout.fillHeight: true
				year: model.year
				month: model.month
				property var curDate: model.date
				onMonthChanged: console.log("cur date changed", month)
				locale: Qt.locale(ConstantsCpp.DefaultLocale)
				delegate: Item {
					property bool isSelectedDay: mainItem.selectedDate ? UtilsCpp.datesAreEqual(mainItem.selectedDate, model.date) : false
					// width: 30 * DefaultStyle.dp
					// height: 30 * DefaultStyle.dp
					Rectangle {
						anchors.centerIn: parent
						width: 30 * DefaultStyle.dp
						height: 30 * DefaultStyle.dp
						radius: 50 * DefaultStyle.dp
						color: isSelectedDay ? DefaultStyle.main1_500_main : "transparent"
					}
					Text {
						anchors.centerIn: parent
						text: UtilsCpp.toDateDayString(model.date)
						color: isSelectedDay
							? DefaultStyle.grey_0
							: UtilsCpp.isCurrentDay(model.date)
								? DefaultStyle.main1_500_main
								: UtilsCpp.dateisInMonth(model.date, mainItem.currentMonth, mainItem.currentYear)
									? DefaultStyle.main2_700
									: DefaultStyle.main2_400
						font {
							pixelSize: 12 * DefaultStyle.dp
							weight: 300 * DefaultStyle.dp
						}
					}
				}
				onClicked: (date) => {
					if (UtilsCpp.isBeforeToday(date)) return;
					mainItem.selectedDate = date
				}
			} 
		}
	}
}