import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

ComboBox {
	id: mainItem
	Layout.preferredHeight: 49 * DefaultStyle.dp
	property string propertyName
	
	property var propertyOwner
	property alias entries: mainItem.model
	oneLine: true
	currentIndex: Utils.findIndex(model, function (entry) {
		return Utils.equalObject(entry,propertyOwner[propertyName])
	})
	onCurrentValueChanged: {
		binding.when = !Utils.equalObject(currentValue,propertyOwner[propertyName])
	}
	Binding {
		id: binding
		target: propertyOwner
		property: propertyName
		value: mainItem.currentValue
		when: false
	}
}


