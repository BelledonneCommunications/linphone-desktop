import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import Linphone
  
Control.TextField {
	id: mainItem
	property var customWidth
	width: (customWidth ? customWidth - 1 : 360) * DefaultStyle.dp
	height: 49 * DefaultStyle.dp
	leftPadding: 15 * DefaultStyle.dp
	rightPadding: eyeButton.visible ? 5 * DefaultStyle.dp + eyeButton.width + eyeButton.rightMargin : 15 * DefaultStyle.dp
	echoMode: (hidden && !eyeButton.checked) ? TextInput.Password : TextInput.Normal
	verticalAlignment: TextInput.AlignVCenter
	color: DefaultStyle.main2_600
	placeholderTextColor: DefaultStyle.placeholders
	font {
		family: DefaultStyle.defaultFont
		pixelSize: 14 * DefaultStyle.dp
		weight: 400 * DefaultStyle.dp
	}
	selectByMouse: true

	property bool controlIsDown: false
	property bool hidden: false
	property bool backgroundVisible: true
	property color backgroundColor: DefaultStyle.grey_100
	property color backgroundBorderColor: DefaultStyle.grey_200
	property string initialText
	property int pixelSize: 14 * DefaultStyle.dp
	property int weight: 400 * DefaultStyle.dp
	
	Component.onCompleted: {
		text = initialText
	}

	function resetText() {
		text = initialText
	}

	signal enterPressed()

	background: Rectangle {
		id: inputBackground
		visible: mainItem.backgroundVisible
		anchors.fill: parent
		radius: 79 * DefaultStyle.dp
		color: mainItem.backgroundColor
		border.color: activeFocus
			? DefaultStyle.main1_500_main
			: mainItem.backgroundBorderColor
	}

	cursorDelegate: Rectangle {
		id: cursor
		color: DefaultStyle.main1_500_main
		width: 1 * DefaultStyle.dp
		anchors.verticalCenter: mainItem.verticalCenter

		SequentialAnimation {
            loops: Animation.Infinite
            running: mainItem.cursorVisible

            PropertyAction {
                target: cursor
                property: 'visible'
                value: true
            }

            PauseAnimation {
                duration: 600
            }

            PropertyAction {
                target: cursor
                property: 'visible'
                value: false
            }

            PauseAnimation {
                duration: 600
            }

            onStopped: {
                cursor.visible = false
            }
        }
	}
	Keys.onPressed: (event) => {
		if (event.key == Qt.Key_Control) mainItem.controlIsDown = true
		if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
			enterPressed()
			if (mainItem.controlIsDown) {
				
			}
		}
	}
	Keys.onReleased: (event) => {
		if (event.jey == Qt.Key_Control) mainItem.controlIsDown = false
	}

	Button {
		id: eyeButton
		property int rightMargin: 15 * DefaultStyle.dp
		z: 1
		visible: mainItem.hidden
		checkable: true
		background: Rectangle {
			color: "transparent"
		}
		icon.source: eyeButton.checked ? AppIcons.eyeShow : AppIcons.eyeHide
		width: 20 * DefaultStyle.dp
		height: 20 * DefaultStyle.dp
		icon.width: 20 * DefaultStyle.dp
		icon.height: 20 * DefaultStyle.dp
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		anchors.rightMargin: rightMargin
	}
}

