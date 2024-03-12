import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts
import Linphone
  
ColumnLayout {
	id: mainItem

	property string label: ""
	property string errorMessage: ""
	property string placeholderText: ""
	property bool mandatory: false
	property bool hidden: false
	property int textInputWidth: 346 * DefaultStyle.dp
	property var validator: RegularExpressionValidator{}
	property bool fillWidth: false
	property bool enableBackgroundColors: true
	property color backgroundColor: DefaultStyle.grey_100
	property color backgroundBorderColor: DefaultStyle.grey_200
	property string initialText

	property bool enableErrorText: false
	property bool errorTextVisible: errorText.opacity > 0

	property alias textField: textField
	property alias background: input

	readonly property string text: textField.text
	readonly property bool hasActiveFocus: textField.activeFocus

	signal editingFinished()

	Component.onCompleted: {
		setText(initialText)
	}

	function setText(text) {
		textField.text = text
	}
	function resetText() {
		setText(initialText)
	}

	Text {
		visible: mainItem.label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.label + (mainItem.mandatory ? "*" : "")
		color: textField.activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_600
		elide: Text.ElideRight
		wrapMode: Text.Wrap
		maximumLineCount: 1
		font {
			pixelSize: 13 * DefaultStyle.dp
			family: DefaultStyle.defaultFont
			weight: 700 * DefaultStyle.dp
		}
		Layout.preferredWidth: mainItem.textInputWidth
	}

	Rectangle {
		id: input
		Component.onCompleted: {
			if (mainItem.fillWidth)
				Layout.fillWidth = true
		}
		Layout.preferredWidth: mainItem.textInputWidth
		Layout.preferredHeight: 49 * DefaultStyle.dp
		radius: 79 * DefaultStyle.dp
		color: mainItem.backgroundColor
		border.color: mainItem.errorTextVisible
			? DefaultStyle.danger_500main
			: textField.activeFocus
				? DefaultStyle.main1_500_main
				: mainItem.backgroundBorderColor

		Control.TextField {
			id: textField
			anchors.left: parent.left
			anchors.leftMargin: 10 * DefaultStyle.dp
			anchors.right: eyeButton.visible ? eyeButton.left : parent.right
			anchors.rightMargin: eyeButton.visible ? 0 : 10 * DefaultStyle.dp
			anchors.verticalCenter: parent.verticalCenter
			placeholderText: mainItem.placeholderText
			echoMode: (mainItem.hidden && !eyeButton.checked) ? TextInput.Password : TextInput.Normal
			font.family: DefaultStyle.defaultFont
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
			}
			color: mainItem.errorTextVisible ? DefaultStyle.danger_500main : DefaultStyle.main2_600
			selectByMouse: true
			validator: mainItem.validator
			background: Item {
				opacity: 0.
			}
			cursorDelegate: Rectangle {
				visible: textField.activeFocus
				color: DefaultStyle.main1_500_main
				width: 2 * DefaultStyle.dp
			}
			onEditingFinished: {
				mainItem.editingFinished()
			}

			Keys.onPressed: (event)=> {
				if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
					textField.focus = false
				}
			}
		}
		Button {
			id: eyeButton
			visible: mainItem.hidden
			checkable: true
			background: Rectangle {
				color: "transparent"
			}
			icon.source: eyeButton.checked ? AppIcons.eyeShow : AppIcons.eyeHide
			width: 20 * DefaultStyle.dp
			height: 20 * DefaultStyle.dp
			anchors.verticalCenter: parent.verticalCenter
			anchors.right: parent.right
			anchors.rightMargin: 15 * DefaultStyle.dp
		}
	}
	ErrorText {
		id: errorText
		visible: mainItem.enableErrorText
		text: mainItem.errorMessage
		Layout.preferredWidth: implicitWidth
	}
}
