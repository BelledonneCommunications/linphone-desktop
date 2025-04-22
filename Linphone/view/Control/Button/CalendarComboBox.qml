import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp

ComboBox {
	id: mainItem
	readonly property var selectedDate: calendar.selectedDate
	onSelectedDateChanged: popupItem.close()
	property alias calendar: calendar
	property alias contentText: contentText
	contentItem: Text {
		id: contentText
        text: UtilsCpp.formatDate(calendar.selectedDate, false, true, "ddd d, MMMM")
		anchors.fill: parent
        anchors.leftMargin: Math.round(15 * DefaultStyle.dp)
		anchors.verticalCenter: parent.verticalCenter
		verticalAlignment: Text.AlignVCenter
		font {
            pixelSize: Math.round(14 * DefaultStyle.dp)
            weight: Math.min(Math.round(700 * DefaultStyle.dp), 1000)
		}
	}
	popup: Control.Popup {
		id: popupItem
		y: mainItem.height
        width: Math.round(321 * DefaultStyle.dp)
        height: Math.round(270 * DefaultStyle.dp)
		closePolicy: Popup.NoAutoClose
        topPadding: Math.round(25 * DefaultStyle.dp)
        bottomPadding: Math.round(24 * DefaultStyle.dp)
        leftPadding: Math.round(21 * DefaultStyle.dp)
        rightPadding: Math.round(19 * DefaultStyle.dp)
		onOpened: calendar.forceActiveFocus()
		background: Item {
			anchors.fill: parent
			Rectangle {
				id: calendarBg
				anchors.fill: parent
				color: DefaultStyle.grey_0
                radius: Math.round(16 * DefaultStyle.dp)
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
