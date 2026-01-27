import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import CustomControls 1.0
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
	id: mainItem

	property string label: ""
	property alias errorMessage: errorText.text
	property string placeholderText : ""
	property bool mandatory: false
	property bool enableErrorText: true
    property real textInputWidth: width
	property string initialPhoneNumber
	readonly property string phoneNumber: textField.text
	readonly property string countryCode: combobox.text
	property string defaultCallingCode
	property bool keyboardFocus: combobox.keyboardFocus || textField.keyboardFocus
	property color keyboardFocusedBorderColor: DefaultStyle.main2_900
	property real borderWidth: Utils.getSizeWithScreenRatio(1)
	property real keyboardFocusedBorderWidth: Utils.getSizeWithScreenRatio(3)

	spacing: Utils.getSizeWithScreenRatio(5)

	Text {
		visible: label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.label + (mainItem.mandatory ? "*" : "")
		color: (combobox.activeFocus || textField.activeFocus) ? DefaultStyle.main1_500_main : DefaultStyle.main2_600
		font {
            pixelSize: Typography.p2.pixelSize
            weight: Typography.p2.weight
		}
	}

	Control.Control {
		Layout.preferredWidth: mainItem.width
		Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
		background: Rectangle {
			id: contentBackground
			anchors.fill: parent
            radius: Utils.getSizeWithScreenRatio(63)
			color: DefaultStyle.grey_100
			border.color: mainItem.errorMessage.length > 0 
				? DefaultStyle.danger_500_main
				: (textField.activeFocus || combobox.activeFocus)
					? DefaultStyle.main1_500_main
					: DefaultStyle.grey_200
        	border.width: mainItem.borderWidth
		}
		contentItem: RowLayout {
			CountryIndicatorCombobox {
				id: combobox
				implicitWidth: Utils.getSizeWithScreenRatio(110)
				leftPadding: Utils.getSizeWithScreenRatio(16)
				Layout.fillHeight: true
				defaultCallingCode: mainItem.defaultCallingCode
				//: %1 prefix
				Accessible.name: qsTr("prefix_phone_number_accessible_name").arg(mainItem.Accessible.name)
			}
			Rectangle {
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(1)
				Layout.fillHeight: true
				Layout.topMargin: Utils.getSizeWithScreenRatio(10)
				Layout.bottomMargin: Utils.getSizeWithScreenRatio(10)
				color: DefaultStyle.main2_600
			}
			TextField {
				id: textField
				Layout.fillWidth: true
				placeholderText: mainItem.placeholderText
				background: Rectangle {
					visible: textField.keyboardFocus
            		radius: Utils.getSizeWithScreenRatio(63)
					color: "transparent"
					border.color: mainItem.keyboardFocusedBorderColor
        			border.width: mainItem.keyboardFocusedBorderWidth
				}
				initialText: initialPhoneNumber
				validator: RegularExpressionValidator{ regularExpression: /[0-9]+/}
				//: %1 number
				Accessible.name: qsTr("number_phone_number_accessible_name").arg(mainItem.Accessible.name)
			}
		}
	}
	TemporaryText {
		id: errorText
		Layout.fillWidth: true
		Layout.topMargin: Utils.getSizeWithScreenRatio(-3)
		// visible: mainItem.enableErrorText
		text: mainItem.errorMessage
		color: DefaultStyle.danger_500_main
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
		wrapMode: Text.Wrap
		font {
			pixelSize: Utils.getSizeWithScreenRatio(13)
			family: DefaultStyle.defaultFont
			bold: true
		}
	}
}
