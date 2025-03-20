
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import UtilsCpp
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

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

	signal save()
	signal undo()

    spacing: Math.round(5 * DefaultStyle.dp)
	ColumnLayout {
		Layout.fillWidth: true
		Layout.fillHeight: true
        spacing: Math.round(16 * DefaultStyle.dp)
		Repeater {
			model: mainItem.proxyModel
			RowLayout {
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignLeft|Qt.AlignHCenter
                Layout.preferredHeight: Math.round(74 * DefaultStyle.dp)
                spacing: Math.round(20 * DefaultStyle.dp)
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
					style: ButtonStyle.noBackground
					icon.source: AppIcons.pencil
                    icon.width: Math.round(24 * DefaultStyle.dp)
                    icon.height: Math.round(24 * DefaultStyle.dp)
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
					}
				}
				Binding {
					id: binding
					target: modelData.core
					property: "enabled"
					value: switchButton.checked
					when: false
				}
				Connections {
					target: mainItem
					function onSave() {
						modelData.core.save()
					}
					function onUndo() {
						modelData.core.undo()
					}
				}
				Connections {
					target: modelData.core
					function onSavedChanged() {
                        if (modelData.core.saved) UtilsCpp.showInformationPopup(qsTr("information_popup_success_title"),
                                                                                //: "Les changements ont été sauvegardés"
                                                                                qsTr("information_popup_changes_saved"), true, mainWindow)
					}
				} 

			}
			onVisibleChanged: {
				if (visible)
					proxyModel.updateView()
			}
			Component.onCompleted: {
				proxyModel.updateView()
			}
		}
		RowLayout {
			Layout.fillWidth: true
            spacing: Math.round(5 * DefaultStyle.dp)
			Item {
				Layout.fillWidth: true
			}
			MediumButton {
				Layout.alignment: Qt.AlignRight | Qt.AlignHCenter
                //: "Ajouter"
                text: qsTr("add")
				style: ButtonStyle.main
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
