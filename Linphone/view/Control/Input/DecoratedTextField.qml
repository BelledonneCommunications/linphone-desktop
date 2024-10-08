import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts 1.0
import QtQuick.Effects
import UtilsCpp
import Linphone

FormItemLayout {
	id: mainItem
	label: title
	mandatory: false
	enableErrorText: true
	property string propertyName: "value"
	property var propertyOwner: new Array
	property var title
	property var placeHolder
	property bool useTitleAsPlaceHolder: true
	property bool canBeEmpty: true
	property bool toValidate: false

	function value() {
		return propertyOwner[propertyName]
	}

    property alias hidden: textField.hidden
	property alias validator: textField.validator

	property var isValid: function(text) {
        return true
    }
	
	contentItem: TextField {
		id: textField
		placeholderText: useTitleAsPlaceHolder ? mainItem.title : mainItem.placeHolder
		initialText: mainItem.propertyOwner[mainItem.propertyName]
		customWidth: mainItem.parent.width
		propertyName: mainItem.propertyName
		propertyOwner: mainItem.propertyOwner
		canBeEmpty: mainItem.canBeEmpty
		isValid: mainItem.isValid
		toValidate: mainItem.toValidate
		onValidationChecked: (isValid) => {
			if (isValid) return
			if (!canBeEmpty && empty) {
				mainItem.errorMessage = qsTr("ne peut être vide")
			} else {
				mainItem.errorMessage = qsTr("Format non reconnu")
			}
		}
		onTextChanged: mainItem.clearErrorText()
	}
}

