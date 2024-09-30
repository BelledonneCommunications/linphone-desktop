import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Linphone
  
ColumnLayout {
	id: mainItem

	property string label: ""
	property alias errorMessage: errorText.text
	property string placeholderText : ""
	property bool mandatory: false
	property bool enableErrorText: true
	property int textInputWidth: width
	property string initialPhoneNumber
	readonly property string phoneNumber: textField.text
	readonly property string countryCode: combobox.currentText
	property string defaultCallingCode

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

	Item {
		Layout.preferredWidth: contentBackground.width
		Layout.preferredHeight: contentBackground.height
		Rectangle {
			id: contentBackground
			width: mainItem.textInputWidth
			height: 49 * DefaultStyle.dp
			radius: 63 * DefaultStyle.dp
			color: DefaultStyle.grey_100
			border.color: mainItem.errorMessage.length > 0 
							? DefaultStyle.danger_500main 
							: (textField.hasActiveFocus || combobox.hasActiveFocus)
								? DefaultStyle.main1_500_main
								: DefaultStyle.grey_200
			RowLayout {
				anchors.fill: parent
				CountryIndicatorCombobox {
					id: combobox
					implicitWidth: 110 * DefaultStyle.dp
					defaultCallingCode: mainItem.defaultCallingCode
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
		TemporaryText {
			id: errorText
			anchors.top: contentBackground.bottom
			// visible: mainItem.enableErrorText
			text: mainItem.errorMessage
			color: DefaultStyle.danger_500main
			verticalAlignment: Text.AlignVCenter
			elide: Text.ElideRight
			wrapMode: Text.Wrap
			font {
				pixelSize: 13 * DefaultStyle.dp
				family: DefaultStyle.defaultFont
				bold: true
			}
			Layout.preferredWidth: mainItem.textInputWidth
			// Layout.preferredWidth: implicitWidth
		}
	}
}
