import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ComboBox {
	id: mainItem
	readonly property var selectedDate: calendar.selectedDate
	onSelectedDateChanged: popupItem.close()
	property alias calendar: calendar
	property alias contentText: contentText
	contentItem: Text {
		id: contentText
		text: calendar.selectedDate ? UtilsCpp.formatDate(calendar.selectedDate, false, true, "ddd d, MMMM") : ""
		anchors.fill: parent
        anchors.leftMargin: Utils.getSizeWithScreenRatio(15)
		anchors.verticalCenter: parent.verticalCenter
		verticalAlignment: Text.AlignVCenter
		font {
            pixelSize: Utils.getSizeWithScreenRatio(14)
            weight: Font.Bold
		}
	}
	popup: Control.Popup {
		id: popupItem
		y: mainItem.height
        width: Utils.getSizeWithScreenRatio(321)
        height: Utils.getSizeWithScreenRatio(270)
		closePolicy: Popup.NoAutoClose
        topPadding: Utils.getSizeWithScreenRatio(25)
        bottomPadding: Utils.getSizeWithScreenRatio(24)
        leftPadding: Utils.getSizeWithScreenRatio(21)
        rightPadding: Utils.getSizeWithScreenRatio(19)
		onOpened: calendar.forceActiveFocus()
		background: Item {
			anchors.fill: parent
			Rectangle {
				id: calendarBg
				anchors.fill: parent
				color: DefaultStyle.grey_0
                radius: Utils.getSizeWithScreenRatio(16)
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
