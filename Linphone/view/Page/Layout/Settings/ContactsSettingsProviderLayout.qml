
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import Linphone

RowLayout {
	id: mainItem
	
	property string title
	property string addText
	property string addTextDescription
	property string editText
	property var newItemGui
	property string settingsLayout
	property var proxyModel
	property var owner
	property string titleProperty
	property bool supportsEnableDisable
	property bool showAddButton

	spacing: 5 * DefaultStyle.dp
	ColumnLayout {
		Layout.fillWidth: true
		Layout.fillHeight: true
		spacing: 16 * DefaultStyle.dp
		Repeater {
			model: mainItem.proxyModel
			RowLayout {
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignLeft|Qt.AlignHCenter
				Layout.preferredHeight: 74 * DefaultStyle.dp
				spacing: 20 * DefaultStyle.dp
				Text {
					text: modelData.core[titleProperty]
					font: Typography.p2l
					wrapMode: Text.WordWrap
					color: DefaultStyle.main2_600
					Layout.fillWidth: true
					Layout.alignment: Qt.AlignHCenter
				}
				Item {
					Layout.fillWidth: true
				}
				Button {
					background: Item{}
					icon.source: AppIcons.pencil
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					contentImageColor: DefaultStyle.main2_600
					onClicked: {
						mainItem.owner.container.push(mainItem.settingsLayout, {
							titleText: mainItem.editText,
							model: modelData,
							container: mainItem.owner.container,
							isNew: false})
					}
				}
				Switch {
					id: switchButton
					Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
					checked: supportsEnableDisable && modelData.core["enabled"]
					visible: supportsEnableDisable
					onToggled: {
						binding.when = true
						modelData.core.save()
					}
				}
				Binding {
					id: binding
					target: modelData.core
					property: "enabled"
					value: switchButton.checked
					when: false
				}
			}
			onVisibleChanged: {
				proxyModel.updateView()
			}
			Component.onCompleted: {
				proxyModel.updateView()
			}
		}
		RowLayout {
			Layout.fillWidth: true
			spacing: 5 * DefaultStyle.dp
			Item {
				Layout.fillWidth: true
			}
			Button {
				Layout.preferredHeight: 47 * DefaultStyle.dp
				Layout.alignment: Qt.AlignRight | Qt.AlignHCenter
				text: qsTr("Ajouter")
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				visible: mainItem.showAddButton
				onClicked: {
					mainItem.owner.container.push(mainItem.settingsLayout, {
						titleText: mainItem.addText,
						model: mainItem.newItemGui,
						container: mainItem.owner.container,
						isNew: true})
				}
			}
		}
	}
}
