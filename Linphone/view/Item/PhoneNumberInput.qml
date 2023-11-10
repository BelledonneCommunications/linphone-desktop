import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts 1.0
import Linphone
  
ColumnLayout {
	id: mainItem

	property string label: ""
	property string errorMessage: ""
	property string placeholderText : ""
	property bool mandatory: false
	property int textInputWidth: 200
	property string initialPhoneNumber
	readonly property string phoneNumber: textField.text
	readonly property string countryCode: combobox.currentText

	Text {
		visible: label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.label + (mainItem.mandatory ? "*" : "")
		color: (combobox.hasActiveFocus || textField.hasActiveFocus) ? DefaultStyle.formItemFocusBorderColor : DefaultStyle.formItemLabelColor
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
		border.color: mainItem.errorMessage.length > 0 
						? DefaultStyle.errorMessageColor 
						: (textField.hasActiveFocus || combobox.hasActiveFocus)
							? DefaultStyle.formItemFocusBorderColor
							: DefaultStyle.formItemBorderColor
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
				placeholderText: mainItem.placeholderText
				enableBackgroundColors: false
				fillWidth: true
				initialText: initialPhoneNumber
				validator: IntValidator{}
			}
		}
	}
	
	Text {
		visible: mainItem.errorMessage.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.errorMessage
		color: DefaultStyle.errorMessageColor
		elide: Text.ElideRight
		wrapMode: Text.Wrap
		font {
			pointSize: DefaultStyle.defaultTextSize
			family: DefaultStyle.defaultFont
			bold: true
		}
		Layout.preferredWidth: mainItem.textInputWidth
	}
}
