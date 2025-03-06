import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

FocusScope {
	id: mainItem
	property string placeholderText: ""
	property color placeholderTextColor: DefaultStyle.main2_400
    property real textInputWidth: Math.round(350 * DefaultStyle.dp)
	property color borderColor: "transparent"
	property color focusedBorderColor: DefaultStyle.main2_500main
	property string text: textField.searchText
	property bool magnifierVisible: true
	property var validator: RegularExpressionValidator{}
	property var numericPadPopup
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
    implicitHeight: Math.round(50 * DefaultStyle.dp)
	
	Rectangle{
		id: backgroundItem
		anchors.fill: parent
        radius: Math.round(28 * DefaultStyle.dp)
		color: DefaultStyle.grey_100
		border.color: textField.activeFocus ? mainItem.focusedBorderColor : mainItem.borderColor
	}
	EffectImage {
		id: magnifier
		visible: mainItem.magnifierVisible
		colorizationColor: DefaultStyle.main2_500main
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Math.round(10 * DefaultStyle.dp)
		imageSource: AppIcons.magnifier
        width: Math.round(20 * DefaultStyle.dp)
        height: Math.round(20 * DefaultStyle.dp)
	}
	Control.TextField {
		id: textField
		anchors.left: magnifier.visible ? magnifier.right : parent.left
        anchors.leftMargin: magnifier.visible ? 0 : Math.round(10 * DefaultStyle.dp)
		anchors.right: clearTextButton.left
		anchors.verticalCenter: parent.verticalCenter
		
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
			color: DefaultStyle.main2_500main
            width: Math.max(Math.round(1 * DefaultStyle.dp), 1)
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
        width: Math.round(24 * DefaultStyle.dp)
        height: Math.round(24 * DefaultStyle.dp)
		anchors.verticalCenter: parent.verticalCenter 
		anchors.right: parent.right
        anchors.rightMargin: Math.round(20 * DefaultStyle.dp)
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
        width: Math.round(24 * DefaultStyle.dp)
        height: Math.round(24 * DefaultStyle.dp)
		style: ButtonStyle.noBackground
		icon.source: AppIcons.closeX
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.right: parent.right
        anchors.rightMargin: Math.round(20 * DefaultStyle.dp)
		onClicked: {
			textField.clear()
		}
	}
}
