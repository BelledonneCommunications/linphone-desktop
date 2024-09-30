import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Linphone
import 'qrc:/Linphone/view/Control/Tool/Helper/utils.js' as Utils

ComboBox {
	id: comboBox
	Layout.preferredHeight: 49 * DefaultStyle.dp
	property string propertyName
	property var propertyOwner
	property alias entries: comboBox.model
	oneLine: true
	currentIndex: Utils.findIndex(model, function (entry) {
		return entry === propertyOwner[propertyName]
	})
	onCurrentTextChanged: {
		binding.when = currentText != propertyOwner[propertyName]
	}
	Binding {
		id: binding
		target: propertyOwner
		property: propertyName
		value: comboBox.currentText
		when: false
	}
}


