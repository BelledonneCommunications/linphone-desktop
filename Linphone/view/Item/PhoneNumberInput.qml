import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.0
import Linphone
  
ColumnLayout {
	id: mainItem

	property string label: ""
	property string defaultText : ""
	property bool mandatory: false
	property int textInputWidth: 200
	readonly property string phoneNumber: textField.inputText
	readonly property string countryCode: combobox.currentText

	Text {
		visible: label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.label + (mainItem.mandatory ? "*" : "")
		color: DefaultStyle.formItemLabelColor
		font {
			pointSize: DefaultStyle.formItemLabelSize
			bold: true
		}
	}

	Rectangle {
		implicitWidth: mainItem.textInputWidth
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
				Layout.preferredWidth: 1
				Layout.fillHeight: true
				Layout.topMargin: 5
				Layout.bottomMargin: 5
				color: DefaultStyle.defaultTextColor
			}
			TextInput {
				id: textField
				Layout.fillWidth: true
				defaultText: mainItem.defaultText
				inputMethodHints: Qt.ImhDigitsOnly
				fillWidth: true
				validator: IntValidator{}
			}
		}
	}	
}