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
	property bool handleNumericPadPopupButtonsPressed: true
	
	signal openNumericPadRequested()// Useful for redirection before displaying numeric pad.
	
	function clearText() {
		textField.text = ""
	}

	Connections {
		enabled: numericPadPopup != undefined && handleNumericPadPopupButtonsPressed
		target: numericPadPopup ? numericPadPopup : null
		function onButtonPressed(text) {
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
	EffectImage {
		id: magnifier
		visible: mainItem.magnifierVisible
		colorizationColor: DefaultStyle.main2_500main
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		anchors.leftMargin: 10 * DefaultStyle.dp
		imageSource: AppIcons.magnifier
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
		style: ButtonStyle.noBackground
		icon.source: AppIcons.dialer
		contentImageColor: dialerButton.checked ? DefaultStyle.main1_500_main : DefaultStyle.main2_600 
		hoveredImageColor: contentImageColor
		width: 24 * DefaultStyle.dp
		height: 24 * DefaultStyle.dp
		anchors.verticalCenter: parent.verticalCenter 
		anchors.right: parent.right
		anchors.rightMargin: 20 * DefaultStyle.dp
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
		width: 24 * DefaultStyle.dp
		height: 24 * DefaultStyle.dp
		style: ButtonStyle.noBackground
		icon.source: AppIcons.closeX
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		anchors.rightMargin: 20 * DefaultStyle.dp
		onClicked: {
			textField.clear()
		}
	}
}
