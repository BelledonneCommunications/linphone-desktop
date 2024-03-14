import QtQuick
import Linphone
import UtilsCpp 1.0
  
ComboBox {
	id: mainItem
	property var selectedDateTime
	readonly property string selectedTimeString: Qt.formatDateTime(selectedDateTime, "hh:mm")
	property int selectedHour: input.hour*1
	property int selectedMin: input.min*1
	property alias contentText: input
	popup.width: 73 * DefaultStyle.dp
	listView.model: 48
	listView.implicitHeight: 204 * DefaultStyle.dp
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
			pixelSize: 14 * DefaultStyle.dp
			weight: 700 * DefaultStyle.dp
		}
		text: mainItem.selectedTimeString
		Keys.onPressed: (event) => {
			if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
				focus = false
			}
		}
		onEditingFinished: {
			console.log("set time", hour, min)
			mainItem.selectedDateTime = UtilsCpp.createDateTime(mainItem.selectedDateTime, hour, min)
		}
	}
	listView.delegate: Text {
		id: hourDelegate
		property int hour: modelData /2
		property int min: modelData%2 === 0 ? 0 : 30
		text: Qt.formatDateTime(UtilsCpp.createDateTime(new Date(), hour, min), "hh:mm")
		width: mainItem.width
		height: 25 * DefaultStyle.dp
		verticalAlignment: TextInput.AlignVCenter
		horizontalAlignment: TextInput.AlignHCenter
		font {
			pixelSize: 14 * DefaultStyle.dp
			weight: 400 * DefaultStyle.dp
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