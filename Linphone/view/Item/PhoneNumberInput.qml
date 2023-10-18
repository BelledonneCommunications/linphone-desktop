import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.0
import Linphone
  
ColumnLayout {
	id: cellLayout

	property string label: ""
	property string defaultText : ""
	property bool mandatory: false
	property int textInputWidth: 200
	readonly property string phoneNumber: textField.inputText
	readonly property string countryCode: combobox.currentText

	Text {
		visible: label.length > 0
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
		radius: 20
		color: DefaultStyle.formItemBackgroundColor
		RowLayout {
			anchors.fill: parent
			PhoneNumberComboBox {
				id: combobox
				backgroundWidth: 100
			}
			Rectangle {

				width: 1
				Layout.fillHeight: true
				Layout.topMargin: 5
				Layout.bottomMargin: 5
				color: DefaultStyle.defaultTextColor
			}
			TextInput {
				id: textField
				Layout.fillWidth: true
				defaultText: cellLayout.defaultText
				inputMethodHints: Qt.ImhDigitsOnly
				fillWidth: true
				validator: IntValidator{}
			}
		}
	}	
}