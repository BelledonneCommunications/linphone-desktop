import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import QtQuick.Effects
import UtilsCpp
import Linphone

FormItemLayout {
	id: mainItem
	label: title
	mandatory: false
	enableErrorText: true
	property string propertyName
	property var propertyOwner
	property var title
	property var placeHolder
	property bool useTitleAsPlaceHolder: true
	property int idleTimeOut: 200
	property var isValid: function(text) {
        return true;
    }
    property alias hidden: textField.hidden
	property alias validator: textField.validator
	property bool empty: mainItem.propertyOwner[mainItem.propertyName]?.length == 0
	property bool canBeEmpty: true
	contentItem: TextField {
		id: textField
		property var initialReading: true
		placeholderText: useTitleAsPlaceHolder ? mainItem.title : mainItem.placeHolder
		initialText: mainItem.propertyOwner[mainItem.propertyName]
		customWidth: mainItem.parent.width
		Timer {
			id: idleTimer
			running: false
			interval: mainItem.idleTimeOut
			repeat: false
			onTriggered: textField.editingFinished()
		}
		onEditingFinished: {
			updateText()
		}
		onTextChanged: {
			idleTimer.restart()
			updateText()
		}
		function updateText() {
			mainItem.empty = text.length == 0
			if (initialReading) {
				initialReading = false
				return
			}
			if (!canBeEmpty && mainItem.empty) {
				mainItem.errorMessage = qsTr("ne peut être vide")
				return
			}
			if (isValid(text)) {
				mainItem.errorMessage = ""
				if (mainItem.propertyOwner[mainItem.propertyName] != text)
					mainItem.propertyOwner[mainItem.propertyName] = text
			} else {
				mainItem.errorMessage = qsTr("Format non reconnu")
			}
		}
	}
}

