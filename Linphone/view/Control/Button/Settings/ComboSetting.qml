import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

ComboBox {
	id: mainItem
    Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
	property string propertyName
	
	property var propertyOwner
	property var propertyOwnerGui
	property alias entries: mainItem.model
	oneLine: true
	currentIndex: Utils.findIndex(model, function (entry) {
		if(propertyOwnerGui)
			return Utils.equalObject(entry,propertyOwnerGui.core[propertyName])
		else
			return Utils.equalObject(entry,propertyOwner[propertyName])
	})
	onCurrentValueChanged: {
		if(propertyOwnerGui) {
			binding.when = !Utils.equalObject(currentValue,propertyOwnerGui.core[propertyName])
		}else{
			binding.when = !Utils.equalObject(currentValue,propertyOwner[propertyName])
		}
	}
	Binding {
		id: binding
		target: propertyOwnerGui ? propertyOwnerGui.core : propertyOwner
		property: propertyName
		value: mainItem.currentValue
		when: false
	}
}
