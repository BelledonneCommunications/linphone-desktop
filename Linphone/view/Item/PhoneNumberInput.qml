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
	property int textInputWidth: width
	property string initialPhoneNumber
	readonly property string phoneNumber: textField.text
	readonly property string countryCode: combobox.currentText

	Text {
		visible: label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.label + (mainItem.mandatory ? "*" : "")
		color: (combobox.hasActiveFocus || textField.hasActiveFocus) ? DefaultStyle.main1_500_main : DefaultStyle.main2_600
		font {
			pixelSize: 13 * DefaultStyle.dp
			weight: 700 * DefaultStyle.dp
		}
	}

	Rectangle {
		Layout.preferredWidth: mainItem.textInputWidth
		Layout.preferredHeight: 49 * DefaultStyle.dp
		radius: 63 * DefaultStyle.dp
		color: DefaultStyle.grey_100
		border.color: mainItem.errorMessage.length > 0 
						? DefaultStyle.danger_500main 
						: (textField.hasActiveFocus || combobox.hasActiveFocus)
							? DefaultStyle.main1_500_main
							: DefaultStyle.grey_200
		RowLayout {
			anchors.fill: parent
			PhoneNumberComboBox {
				id: combobox
				implicitWidth: 110 * DefaultStyle.dp
			}
			Rectangle {
				Layout.preferredWidth: 1 * DefaultStyle.dp
				Layout.fillHeight: true
				Layout.topMargin: 10 * DefaultStyle.dp
				Layout.bottomMargin: 10 * DefaultStyle.dp
				color: DefaultStyle.main2_600
			}
			TextField {
				id: textField
				Layout.fillWidth: true
				placeholderText: mainItem.placeholderText
				background: Item{}
				initialText: initialPhoneNumber
				validator: RegularExpressionValidator{ regularExpression: /[0-9]+/}
			}
		}
	}
	
	Text {
		visible: mainItem.errorMessage.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.errorMessage
		color: DefaultStyle.danger_500main
		elide: Text.ElideRight
		wrapMode: Text.Wrap
		font {
			pixelSize: 13 * DefaultStyle.dp
			family: DefaultStyle.defaultFont
			bold: true
		}
		Layout.preferredWidth: mainItem.textInputWidth
	}
}
