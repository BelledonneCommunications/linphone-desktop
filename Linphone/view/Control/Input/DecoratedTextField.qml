import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts 1.0
import QtQuick.Effects
import UtilsCpp
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

FormItemLayout {
	id: mainItem
	label: title
	mandatory: false
	enableErrorText: true
	property string propertyName: "value"
	property var propertyOwner: new Array
	property var propertyOwnerGui
	property var title
	property var placeHolder: ""
	property bool useTitleAsPlaceHolder: true
	property bool canBeEmpty: true
	property bool toValidate: false
	property alias text: textField.text
	
	property var value: propertyOwnerGui ? propertyOwnerGui.core[propertyName] : propertyOwner[propertyName]

	function value() {
		return propertyOwnerGui ? propertyOwnerGui.core[propertyName] : propertyOwner[propertyName]
	}
	
    property alias hidden: textField.hidden
	property alias validator: textField.validator

	property alias customButtonIcon: textField.customButtonIcon
    property alias customCallback: textField.customCallback
    property alias customButtonAccessibleName: textField.customButtonAccessibleName

	property var isValid: function(text) {
        return true
    }
    
    function empty() {
		textField.text = ""
	}
	
	contentItem: TextField {
		id: textField
        Layout.preferredWidth: Utils.getSizeWithScreenRatio(360)
		placeholderText: useTitleAsPlaceHolder ? mainItem.title : mainItem.placeHolder
		initialText: (mainItem.propertyOwnerGui ? mainItem.propertyOwnerGui.core[mainItem.propertyName] : mainItem.propertyOwner[mainItem.propertyName]) || ''
		customWidth: mainItem.parent.width
		propertyName: mainItem.propertyName
		propertyOwner: mainItem.propertyOwner
		propertyOwnerGui: mainItem.propertyOwnerGui
		canBeEmpty: mainItem.canBeEmpty
		isValid: mainItem.isValid
		toValidate: mainItem.toValidate
		onValidationChecked: (isValid) => {
			if (isValid) return
			if (!canBeEmpty && empty) {
                                     //: "ne peut être vide"
                mainItem.errorMessage = qsTr("textfield_error_message_cannot_be_empty")
			} else {
                                     //: "Format non reconnu"
                mainItem.errorMessage = qsTr("textfield_error_message_unknown_format")
			}
		}
		onTextChanged: mainItem.clearErrorText()
		Accessible.name: mainItem.title
	}
}

