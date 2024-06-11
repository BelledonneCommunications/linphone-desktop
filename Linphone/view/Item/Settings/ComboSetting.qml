import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import Linphone
import SettingsCpp 1.0
import 'qrc:/Linphone/view/Tool/utils.js' as Utils

ComboBox {
	id: comboBox
	Layout.preferredHeight: 49 * DefaultStyle.dp
	property string propertyName
	oneLine: true
	currentIndex: Utils.findIndex(model, function (entry) {
		return entry === SettingsCpp[propertyName]
	})
	onCurrentTextChanged: {
		binding.when = currentText != SettingsCpp[propertyName]
	}
	Binding {
		id: binding
		target: SettingsCpp
		property: propertyName
		value: comboBox.currentText
		when: false
	}
}


