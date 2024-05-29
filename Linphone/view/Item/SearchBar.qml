import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import Linphone


Rectangle {
	id: mainItem
	property string placeholderText: ""
	property color placeholderTextColor: DefaultStyle.main2_400
	property int textInputWidth: 350 * DefaultStyle.dp
	property color borderColor: "transparent"
	property color focusedBorderColor: DefaultStyle.main2_500main
	property string text: textField.text
	property bool magnifierVisible: true
	property var validator: RegularExpressionValidator{}
	property Control.Popup numericPad
	property alias numericPadButton: dialerButton
	readonly property bool hasActiveFocus: textField.activeFocus

	onVisibleChanged: if (!visible && numericPad) numericPad.close()

	function clearText() {
		textField.text = ""
	}

	Connections {
		enabled: numericPad != undefined
		target: numericPad ? numericPad : null
		onAboutToHide: { mainItem.numericPadButton.checked = false }
		onAboutToShow: { mainItem.numericPadButton.checked = true }
		onButtonPressed: (text) => {
			textField.text += text
		}
		onWipe: textField.text = textField.text.slice(0, -1)
	}


	implicitWidth: mainItem.textInputWidth
	implicitHeight: 50 * DefaultStyle.dp
	radius: 28 * DefaultStyle.dp
	color: DefaultStyle.grey_100
	border.color: textField.activeFocus ? mainItem.focusedBorderColor : mainItem.borderColor
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
		background: Item {
			opacity: 0.
		}
		cursorDelegate: Rectangle {
			visible: textField.cursorVisible
			color: DefaultStyle.main2_500main
			width: 1 * DefaultStyle.dp
		}
	}
	Button {
		id: dialerButton
		visible: numericPad != undefined && textField.text.length === 0
		checkable: true
		checked: false
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
		onCheckedChanged: {
			if (checked) mainItem.numericPad.open()
			else mainItem.numericPad.close()
		}
	}
	Button {
		id: clearTextButton
		visible: textField.text.length > 0
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
