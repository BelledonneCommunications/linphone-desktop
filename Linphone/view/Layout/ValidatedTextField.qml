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
			if (initialReading) {
				initialReading = false
				return
			}
			if (text.length != 0) {
				if (isValid(text)) {
					mainItem.errorMessage = ""
					if (mainItem.propertyOwner[mainItem.propertyName] != text)
						mainItem.propertyOwner[mainItem.propertyName] = text
				} else {
					mainItem.errorMessage = qsTr("Format non reconnu")
				}
			} else
				mainItem.errorMessage = ""
		}
		onTextChanged: {
			idleTimer.restart()
		}
	}
}

