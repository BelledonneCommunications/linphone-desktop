import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.0
import Linphone
  
ColumnLayout {
	id: cellLayout
	Layout.bottomMargin: 8

	property string label: ""
	property string defaultText : ""
	property bool mandatory: false
	property bool hidden: false
	property int textInputWidth: 200
	readonly property string inputText: textField.text

	Text {
		verticalAlignment: Text.AlignVCenter
		text: cellLayout.label + (cellLayout.mandatory ? "*" : "")
		color: DefaultStyle.formItemLabelColor
		font {
			pointSize: DefaultStyle.formItemLabelSize
			bold: true
		}
	}

	Rectangle {
		implicitWidth: cellLayout.textInputWidth
		implicitHeight: 30
		// anchors.fill: parent
		radius: 20
		color: DefaultStyle.formItemBackgroundColor
		opacity: 0.7
		TextField {
			id: textField
			anchors.left: parent.left
			anchors.right: eyeButton.visible ? eyeButton.left : parent.right
			anchors.verticalCenter: parent.verticalCenter
			placeholderText: cellLayout.defaultText
			echoMode: (cellLayout.hidden && !eyeButton.checked) ? TextInput.Password : TextInput.Normal
			font.family: DefaultStyle.defaultFont
			font.pointSize: DefaultStyle.formTextInputSize
			color: DefaultStyle.formItemLabelColor
			background: Item {
				opacity: 0.
			}
		}
		Button {
			id: eyeButton
			visible: cellLayout.hidden
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