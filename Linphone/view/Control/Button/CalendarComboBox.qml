import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone

ComboBox {
	id: mainItem
	readonly property var selectedDate: calendar.selectedDate
	onSelectedDateChanged: popupItem.close()
	property alias calendar: calendar
	property alias contentText: contentText
	contentItem: Text {
		id: contentText
		text: Qt.formatDate(calendar.selectedDate, "ddd d, MMMM")
		anchors.fill: parent
		anchors.leftMargin: 15 * DefaultStyle.dp
		anchors.verticalCenter: parent.verticalCenter
		verticalAlignment: Text.AlignVCenter
		font {
			pixelSize: 14 * DefaultStyle.dp
			weight: 700 * DefaultStyle.dp
		}
	}
	popup: Control.Popup {
		id: popupItem
		y: mainItem.height
		width: 321 * DefaultStyle.dp
		height: 270 * DefaultStyle.dp
		closePolicy: Popup.NoAutoClose
		topPadding: 25 * DefaultStyle.dp
		bottomPadding: 24 * DefaultStyle.dp
		leftPadding: 21 * DefaultStyle.dp
		rightPadding: 19 * DefaultStyle.dp
		onOpened: calendar.forceActiveFocus()
		background: Item {
			anchors.fill: parent
			Rectangle {
				id: calendarBg
				anchors.fill: parent
				color: DefaultStyle.grey_0
				radius: 16 * DefaultStyle.dp
				border.color: DefaultStyle.main1_500_main
				border.width: calendar.activeFocus? 1 : 0
			}
			MultiEffect {
				anchors.fill: calendarBg
				source: calendarBg
				shadowEnabled: true
				shadowBlur: 0.1
				shadowOpacity: 0.1
			}
		}
		contentItem: Calendar {
			id: calendar
		}
	}
}
