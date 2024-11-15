import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone


FocusScope {
	id: mainItem
	property string placeholderText: ""
	property color placeholderTextColor: DefaultStyle.main2_400
	property int textInputWidth: 350 * DefaultStyle.dp
	property color borderColor: "transparent"
	property color focusedBorderColor: DefaultStyle.main2_500main
	property string text: textField.searchText
	property bool magnifierVisible: true
	property var validator: RegularExpressionValidator{}
	property Control.Popup numericPadPopup
	property alias numericPadButton: dialerButton
	readonly property bool hasActiveFocus: textField.activeFocus
	property alias color: backgroundItem.color
	property bool delaySearch: true	// Wait some idle time after typing to start searching
	
	signal openNumericPadRequested()// Useful for redirection before displaying numeric pad.
	
	function clearText() {
		textField.text = ""
	}

	Connections {
		enabled: numericPadPopup != undefined
		target: numericPadPopup ? numericPadPopup : null
		function onButtonPressed(text) {
			console.log("text", text)
			textField.text += text
		}
		function onWipe(){ textField.text = textField.text.slice(0, -1)}
	}


	implicitWidth: mainItem.textInputWidth
	implicitHeight: 50 * DefaultStyle.dp
	
	Rectangle{
		id: backgroundItem
		anchors.fill: parent
		radius: 28 * DefaultStyle.dp
		color: DefaultStyle.grey_100
		border.color: textField.activeFocus ? mainItem.focusedBorderColor : mainItem.borderColor
	}
	Image {
		id: magnifier
		visible: mainItem.magnifierVisible
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		anchors.leftMargin: 10 * DefaultStyle.dp
		source: AppIcons.magnifier
		width: 20 * DefaultStyle.dp
		height: 20 * DefaultStyle.dp
	}
	Control.TextField {
		id: textField
		anchors.left: magnifier.visible ? magnifier.right : parent.left
		anchors.leftMargin: magnifier.visible ? 0 : 10 * DefaultStyle.dp
		anchors.right: clearTextButton.left
		anchors.verticalCenter: parent.verticalCenter
		
		property string searchText
		
		focus: true
		placeholderText: mainItem.placeholderText
		placeholderTextColor: mainItem.placeholderTextColor
		width: mainItem.width - dialerButton.width
		echoMode: (mainItem.hidden && !dialerButton.checked) ? TextInput.Password : TextInput.Normal
		font {
			pixelSize: 14 * DefaultStyle.dp
			weight: 400 * DefaultStyle.dp
			family: DefaultStyle.defaultFont
		}
		color: DefaultStyle.main2_600
		selectByMouse: true
		validator: mainItem.validator
		onTextChanged: mainItem.delaySearch ? delayTimer.restart() : searchText = text
		background: Item {
			opacity: 0.
		}
		cursorDelegate: Rectangle {
			visible: textField.cursorVisible
			color: DefaultStyle.main2_500main
			width: 1 * DefaultStyle.dp
		}
		Timer{
			id: delayTimer
			interval: 300
			repeat: false
			onTriggered: textField.searchText = textField.text
		}
	}
	Button {
		id: dialerButton
		visible: numericPadPopup != undefined && textField.text.length === 0
		checked: numericPadPopup?.visible || false
		background: Rectangle {
			color: "transparent"
		}
		icon.source: dialerButton.checked ? AppIcons.dialerSelected : AppIcons.dialer
		width: 24 * DefaultStyle.dp
		height: 24 * DefaultStyle.dp
		icon.width: 24 * DefaultStyle.dp
		icon.height: 24 * DefaultStyle.dp
		anchors.verticalCenter: parent.verticalCenter 
		anchors.right: parent.right
		anchors.rightMargin: 15 * DefaultStyle.dp
		onClicked: {
			if(!checked){
				mainItem.openNumericPadRequested()
				mainItem.numericPadPopup.open()
			} else mainItem.numericPadPopup.close()
		}
	}
	Button {
		id: clearTextButton
		visible: textField.text.length > 0 && mainItem.enabled
		background: Rectangle {
			color: "transparent"
		}
		width: 24 * DefaultStyle.dp
		height: 24 * DefaultStyle.dp
		icon.source: AppIcons.closeX
		icon.width: 24 * DefaultStyle.dp
		icon.height: 24 * DefaultStyle.dp
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		anchors.rightMargin: 15 * DefaultStyle.dp
		onClicked: {
			textField.clear()
		}
	}
}
