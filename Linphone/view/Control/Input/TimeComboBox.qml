import QtQuick
import Linphone
import UtilsCpp 1.0
  
ComboBox {
	id: mainItem
	property var selectedDateTime
	onSelectedDateTimeChanged: {
		if (minTime != undefined) {
			if (UtilsCpp.timeOffset(minTime, selectedDateTime) < 0)
				selectedDateTime = minTime
		}
		if (maxTime != undefined) {
			if (UtilsCpp.timeOffset(maxTime, selectedDateTime) > 0)
				selectedDateTime = maxTime
		}
	}
	readonly property string selectedTimeString: Qt.formatDateTime(selectedDateTime, "hh:mm")
	property int selectedHour: input.hour*1
	property int selectedMin: input.min*1
	property alias contentText: input
	property var minTime
	property var maxTime
    popup.width: Math.round(73 * DefaultStyle.dp)
	listView.model: 48
    listView.height: Math.min(Math.round(204 * DefaultStyle.dp), listView.contentHeight)
    popup.height: Math.min(Math.round(204 * DefaultStyle.dp), listView.contentHeight)
	editable: true
	popup.closePolicy: Popup.PressOutsideParent | Popup.CloseOnPressOutside
	onCurrentTextChanged: input.text = currentText
	popup.onOpened: {
		input.forceActiveFocus()
	}
	contentItem: TextInput {
		id: input
		anchors.right: indicator.left
		validator: IntValidator{}
		// activeFocusOnPress: false
		inputMask: "00:00"
		verticalAlignment: TextInput.AlignVCenter
		horizontalAlignment: TextInput.AlignHCenter
		property string hour: text.split(":")[0]
		property string min: text.split(":")[1]
		color: DefaultStyle.main2_600
		onActiveFocusChanged: {
			if (activeFocus) {
				selectAll()
				mainItem.popup.open()
			} else {
				listView.currentIndex = -1
				mainItem.selectedDateTime = UtilsCpp.createDateTime(mainItem.selectedDateTime, hour, min)
			}
		}
		font {
            pixelSize: Typography.p2l.pixelSize
            weight: Typography.p2l.weight
		}
		text: mainItem.selectedTimeString
		Keys.onPressed: (event) => {
			if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
				focus = false
			}
		}
		onFocusChanged: if (!focus) {
			mainItem.selectedDateTime = UtilsCpp.createDateTime(mainItem.selectedDateTime, hour, min)
			console.log("set time", hour, min)
		}
	}
	listView.delegate: Text {
		id: hourDelegate
		property int hour: modelData /2
		property int min: modelData%2 === 0 ? 0 : 30
		property var currentDateTime: UtilsCpp.createDateTime(new Date(), hour, min)
		text: Qt.formatDateTime(currentDateTime, "hh:mm")
		width: mainItem.width
		visible: mainItem.minTime == undefined || UtilsCpp.timeOffset(mainItem.minTime, currentDateTime) > 0
        height: visible ? Math.round(25 * DefaultStyle.dp) : 0
		verticalAlignment: TextInput.AlignVCenter
		horizontalAlignment: TextInput.AlignHCenter
		font {
            pixelSize: Typography.p1.pixelSize
            weight: Typography.p1.weight
		}
		MouseArea {
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
			onClicked: {
				// mainItem.text = parent.text
				mainItem.listView.currentIndex = index
				mainItem.selectedDateTime = UtilsCpp.createDateTime(mainItem.selectedDateTime, hour, min)
				mainItem.popup.close()
			}
			Rectangle {
				visible: parent.containsMouse
				color: DefaultStyle.main2_200
			}
		}
	}
}
