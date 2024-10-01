import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
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
	color: isError ? DefaultStyle.danger_500main : DefaultStyle.main2_600
	placeholderTextColor: DefaultStyle.placeholders
	font {
		family: DefaultStyle.defaultFont
		pixelSize: 14 * DefaultStyle.dp
		weight: 400 * DefaultStyle.dp
	}
	selectByMouse: true
	activeFocusOnTab: true
	KeyNavigation.right: eyeButton

	property bool controlIsDown: false
	property bool hidden: false
	property bool isError: false
	property bool backgroundVisible: true
	property color backgroundColor: DefaultStyle.grey_100
	property color disabledBackgroundColor: DefaultStyle.grey_200
	property color backgroundBorderColor: DefaultStyle.grey_200
	property string initialText
	property int pixelSize: 14 * DefaultStyle.dp
	property int weight: 400 * DefaultStyle.dp

	// fill propertyName and propertyOwner to check text validity
	property string propertyName
	property var propertyOwner
	property var initialReading: true
	property var isValid: function(text) {
        return true
    }
	property bool toValidate: false
	property int idleTimeOut: 200
	property bool empty: mainItem.propertyOwner!= undefined && mainItem.propertyOwner[mainItem.propertyName]?.length == 0
	property bool canBeEmpty: true

	signal validationChecked(bool valid)

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
		color: mainItem.enabled ? mainItem.backgroundColor : mainItem.disabledBackgroundColor
		border.color: mainItem.isError 
			? DefaultStyle.danger_500main
			: mainItem.activeFocus
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
		KeyNavigation.left: mainItem
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
		icon.width: width
		icon.height: height
		anchors.verticalCenter: parent.verticalCenter
		anchors.right: parent.right
		anchors.rightMargin: rightMargin
	}

	// Validation textfield functions
	Timer {
		id: idleTimer
		running: false
		interval: mainItem.idleTimeOut
		repeat: false
		onTriggered: mainItem.editingFinished()
	}
	onEditingFinished: {
		updateText()
	}
	onTextChanged: {
		if(mainItem.toValidate) {
			// Restarting
			idleTimer.restart()
		}
		// updateText()
	}
	function updateText() {
		mainItem.empty = text.length == 0
		if (initialReading) {
			initialReading = false
		}
		if (mainItem.empty && !mainItem.canBeEmpty) {
			mainItem.validationChecked(false)
			return
		}
		if (isValid(text) && mainItem.propertyOwner && mainItem.propertyName) {
			if (mainItem.propertyOwner[mainItem.propertyName] != text)
				mainItem.propertyOwner[mainItem.propertyName] = text
			mainItem.validationChecked(true)
		} else mainItem.validationChecked(false)
	}
}

