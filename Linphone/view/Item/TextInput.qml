import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.0
import Linphone
  
ColumnLayout {
	id: mainItem

	property string label: ""
	property string defaultText : ""
	property bool mandatory: false
	property bool hidden: false
	property int textInputWidth: 200
	property var inputMethodHints: Qt.ImhNone
	property var validator: RegularExpressionValidator{}
	readonly property string inputText: textField.text
	property bool fillWidth: false

	Text {
		visible: label.length > 0
		textItem.verticalAlignment: Text.AlignVCenter
		textItem.text: mainItem.label + (mainItem.mandatory ? "*" : "")
		textItem.color: DefaultStyle.formItemLabelColor
		textItem.elide: Text.ElideRight
		textItem.wrapMode: Text.Wrap
		textItem.maximumLineCount: 1
		textItem.font {
			pointSize: DefaultStyle.formItemLabelSize
			family: DefaultStyle.defaultFont
			bold: true
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
		implicitHeight: 30
		radius: 20
		color: DefaultStyle.formItemBackgroundColor
		opacity: 0.7
		TextField {
			id: textField
			anchors.left: parent.left
			anchors.right: eyeButton.visible ? eyeButton.left : parent.right
			anchors.verticalCenter: parent.verticalCenter
			placeholderText: mainItem.defaultText
			echoMode: (mainItem.hidden && !eyeButton.checked) ? TextInput.Password : TextInput.Normal
			font.family: DefaultStyle.defaultFont
			font.pointSize: DefaultStyle.formTextInputSize
			color: DefaultStyle.formItemLabelColor
			inputMethodHints: mainItem.inputMethodHints
			selectByMouse: true
			validator: mainItem.validator
			background: Item {
				opacity: 0.
			}
		}
		Button {
			id: eyeButton
			visible: mainItem.hidden
			checkable: true
			background: Rectangle {
				color: "transparent"
			}
			anchors.right: parent.right
			contentItem: Image {
				fillMode: Image.PreserveAspectFit
				source: eyeButton.checked ? AppIcons.eyeHide : AppIcons.eyeShow
			}
		}
	}	
}