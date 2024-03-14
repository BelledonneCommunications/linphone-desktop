import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control
import QtQuick.Effects

import Linphone
import ConstantsCpp 1.0
import UtilsCpp 1.0

ListView {
	id: mainItem
	// width: 400 * DefaultStyle.dp
	// height: 400 * DefaultStyle.dp
	snapMode: ListView.SnapOneItem
	orientation: Qt.Horizontal
	clip: true
	property int maxYears: 5
	readonly property var currentDate: new Date()
	Layout.fillWidth: true
	Layout.fillHeight: true
	highlightMoveDuration: 100

	property var selectedDate
	
	model: Control.CalendarModel {
		id: calendarModel
		from: new Date()
		to: new Date(2025, 12, 31)
	}
	
	delegate: ColumnLayout {
		width: mainItem.width
		height: mainItem.height
		RowLayout {
			Layout.fillWidth: true
			Text {
				text: new Date(model.year, model.month, 15).toLocaleString(Qt.locale(ConstantsCpp.DefaultLocale), 'MMMM yyyy')// 15 because of timezones that can change the date for localeString
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
				Layout.preferredWidth: 10 * DefaultStyle.dp
				Layout.preferredHeight: 20 * DefaultStyle.dp
				background: Item{}
				icon.source: AppIcons.leftArrow
				onClicked: if (mainItem.currentIndex > 0) --mainItem.currentIndex
			}
			Button {
				Layout.preferredWidth: 20 * DefaultStyle.dp
				Layout.preferredHeight: 20 * DefaultStyle.dp
				background: Item{}
				icon.source: AppIcons.rightArrow
				onClicked: if (mainItem.currentIndex < mainItem.count) ++mainItem.currentIndex
			}
		}
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
			// locale: Qt.locale("en_US")
			delegate: Item {
				property bool isSelectedDay: mainItem.selectedDate ? UtilsCpp.datesAreEqual(mainItem.selectedDate, model.date) : false
				Rectangle {
					anchors.centerIn: parent
					width: 30 * DefaultStyle.dp
					height: 30 * DefaultStyle.dp
					radius: 50 * DefaultStyle.dp
					color: isSelectedDay ? DefaultStyle.main1_500_main : "transparent"
				}
				Text {
					anchors.centerIn: parent
					text: monthGrid.locale.toString(model.date, "d")
					color: isSelectedDay 
						? DefaultStyle.grey_0
						: UtilsCpp.isCurrentDay(model.date)
							? DefaultStyle.main1_500_main
							: UtilsCpp.isCurrentMonth(model.date) 
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