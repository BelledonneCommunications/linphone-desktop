import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
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
	property string initialText
	readonly property string text: textField.text
	readonly property bool hasActiveFocus: textField.activeFocus

	Component.onCompleted: setText(initialText)

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
		implicitWidth: mainItem.textInputWidth
		implicitHeight: 49 * DefaultStyle.dp
		radius: 79 * DefaultStyle.dp
		color: mainItem.enableBackgroundColors ? DefaultStyle.grey_100 : "transparent"
		border.color: mainItem.enableBackgroundColors
						? (mainItem.errorMessage.length > 0 
							? DefaultStyle.danger_500main
							: textField.activeFocus
								? DefaultStyle.main1_500_main
								: DefaultStyle.grey_200)
						: "transparent"
		Control.TextField {
			id: textField
			anchors.left: parent.left
			anchors.right: eyeButton.visible ? eyeButton.left : parent.right
			anchors.verticalCenter: parent.verticalCenter
			placeholderText: mainItem.placeholderText
			echoMode: (mainItem.hidden && !eyeButton.checked) ? TextInput.Password : TextInput.Normal
			font.family: DefaultStyle.defaultFont
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
			}
			color: DefaultStyle.main2_600
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
		}
		Control.Button {
			id: eyeButton
			visible: mainItem.hidden
			checkable: true
			background: Rectangle {
				color: "transparent"
			}
			contentItem: Image {
				fillMode: Image.PreserveAspectFit
				source: eyeButton.checked ? AppIcons.eyeShow : AppIcons.eyeHide
			}
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.right: parent.right
		}
	}
	Text {
		visible: mainItem.errorMessage.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.errorMessage
		color: DefaultStyle.danger_500main
		elide: Text.ElideRight
		wrapMode: Text.Wrap
		// maximumLineCount: 1
		font {
			pixelSize: 13 * DefaultStyle.dp
			family: DefaultStyle.defaultFont
			bold: true
		}
		Layout.preferredWidth: mainItem.textInputWidth
	}
}
