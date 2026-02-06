import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import CustomControls 1.0
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

FocusScope {
	id: mainItem
	property bool magnifierVisible: true
	property var validator: RegularExpressionValidator{}
	property var numericPadPopup
	property alias numericPadButton: dialerButton
	readonly property bool hasActiveFocus: textField.activeFocus
	property alias color: backgroundItem.color
	property bool delaySearch: true	// Wait some idle time after typing to start searching
	property bool handleNumericPadPopupButtonsPressed: true
    // Border properties
	property color borderColor: "transparent"
	property color focusedBorderColor: DefaultStyle.main2_500_main
	property color keyboardFocusedBorderColor: DefaultStyle.main2_900
	property real borderWidth: Utils.getSizeWithScreenRatio(1)
	property real keyboardFocusedBorderWidth: Utils.getSizeWithScreenRatio(3)
	// Text properties
	property string placeholderText: ""
	property color placeholderTextColor: DefaultStyle.main2_400									
    property real textInputWidth: Utils.getSizeWithScreenRatio(350)
	property string text: textField.searchText
	
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
    implicitHeight: Utils.getSizeWithScreenRatio(50)
	
	Rectangle{
		id: backgroundItem
		anchors.fill: parent
        radius: Utils.getSizeWithScreenRatio(28)
		color: DefaultStyle.grey_100
		border.color: textField.keyboardFocus ? mainItem.keyboardFocusedBorderColor : textField.activeFocus ? mainItem.focusedBorderColor : mainItem.borderColor
		border.width: textField.keyboardFocus ? mainItem.keyboardFocusedBorderWidth : mainItem.borderWidth
	}
	EffectImage {
		id: magnifier
		visible: mainItem.magnifierVisible
		colorizationColor: DefaultStyle.main2_500_main
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Utils.getSizeWithScreenRatio(10)
		imageSource: AppIcons.magnifier
        width: Utils.getSizeWithScreenRatio(20)
        height: Utils.getSizeWithScreenRatio(20)
	}
	Control.TextField {
		id: textField
		anchors.left: magnifier.visible ? magnifier.right : parent.left
        anchors.leftMargin: magnifier.visible ? 0 : Utils.getSizeWithScreenRatio(10)
		anchors.right: clearTextButton.left
		anchors.verticalCenter: parent.verticalCenter
		property bool keyboardFocus: FocusHelper.keyboardFocus
		
		property string searchText

		focus: true
		placeholderText: mainItem.placeholderText
		placeholderTextColor: mainItem.placeholderTextColor
		width: mainItem.width - dialerButton.width
		echoMode: (mainItem.hidden && !dialerButton.checked) ? TextInput.Password : TextInput.Normal
		font {
            pixelSize: Typography.p1.pixelSize
            weight: Typography.p1.weight
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
			color: DefaultStyle.main2_500_main
            width: Utils.getSizeWithScreenRatio(1)
		}
		Timer{
			id: delayTimer
			interval: 300
			repeat: false
			onTriggered: textField.searchText = textField.text
		}
		Keys.onPressed: (event) => {
			event.accepted = false
			if (mainItem.numericPadPopup && mainItem.numericPadPopup.opened && (event.modifiers & Qt.KeypadModifier || event.key === Qt.Key_Return)) {
				mainItem.numericPadPopup.keyPadKeyPressed(event)
				event.accepted = true
			}
		}
	}
	Button {
		id: dialerButton
		visible: numericPadPopup != undefined && textField.text.length === 0
		checked: numericPadPopup?.visible || false
		style: ButtonStyle.noBackground
		icon.source: AppIcons.dialer
		contentImageColor: checked ? DefaultStyle.main1_500_main : DefaultStyle.main2_600 
		hoveredImageColor: contentImageColor
        width: Utils.getSizeWithScreenRatio(30)
        height: Utils.getSizeWithScreenRatio(30)
		icon.width: Utils.getSizeWithScreenRatio(24)
		icon.height: Utils.getSizeWithScreenRatio(24)
		anchors.verticalCenter: parent.verticalCenter 
		anchors.right: parent.right
        anchors.rightMargin: Utils.getSizeWithScreenRatio(20)
		//: "Open dialer"
		Accessible.name: qsTr("open_dialer_acccessibility_label")
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
        width: Utils.getSizeWithScreenRatio(24)
        height: Utils.getSizeWithScreenRatio(24)
		style: ButtonStyle.noBackground
		icon.source: AppIcons.closeX
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.right: parent.right
        anchors.rightMargin: Utils.getSizeWithScreenRatio(20)
		//: "Clear text input"
		Accessible.name: qsTr("clear_text_input_acccessibility_label")
		onClicked: {
			textField.clear()
		}
	}
}
