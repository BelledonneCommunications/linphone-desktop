import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import Linphone


Rectangle {
	id: mainItem
	property string placeholderText: ""
	property int textInputWidth: 350
	property var validator: RegularExpressionValidator{}
	property string text: textField.text
	property alias numericPadButton: dialerButton
	readonly property bool hasActiveFocus: textField.activeFocus
	property var numericPad
	signal numericPadButtonPressed(bool checked)

	onVisibleChanged: if (!visible && numericPad) numericPad.close()

	Connections {
		enabled: numericPad != undefined
		target: numericPad ? numericPad : null
		onAboutToHide: { searchBar.numericPadButton.checked = false }
		onAboutToShow: { searchBar.numericPadButton.checked = true }
		onButtonPressed: (text) => {
			textField.text += text
		}
		onWipe: textField.text = textField.text.slice(0, -1)
	}

	implicitWidth: mainItem.textInputWidth
	implicitHeight: 30
	radius: 20
	color: DefaultStyle.formItemBackgroundColor
	border.color: textField.activeFocus ? DefaultStyle.searchBarFocusBorderColor : "transparent"
	Image {
		id: magnifier
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		anchors.leftMargin: 10 
		source: AppIcons.magnifier
	}
	Control.TextField {
		id: textField
		anchors.left: magnifier.right
		anchors.right: dialerButton.visible ? dialerButton.left : parent.right
		anchors.verticalCenter: parent.verticalCenter
		placeholderText: mainItem.placeholderText
		echoMode: (mainItem.hidden && !dialerButton.checked) ? TextInput.Password : TextInput.Normal
		font.family: DefaultStyle.defaultFont
		font.pointSize: DefaultStyle.defaultFontPointSize
		color: DefaultStyle.formItemLabelColor
		selectByMouse: true
		validator: mainItem.validator
		background: Item {
			opacity: 0.
		}
		cursorDelegate: Rectangle {
			visible: textField.activeFocus
			color: DefaultStyle.formItemFocusBorderColor
			width: 2
		}
	}
	Control.Button {
		id: dialerButton
		visible: numericPad != undefined
		checkable: true
		checked: false
		background: Rectangle {
			color: "transparent"
		}
		contentItem: Image {
			fillMode: Image.PreserveAspectFit
			source: dialerButton.checked ? AppIcons.dialerSelected : AppIcons.dialer
		}
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		anchors.rightMargin: 10
		onCheckedChanged: {
			if (checked) mainItem.numericPad.open()
			else mainItem.numericPad.close()
		}
	}
}
