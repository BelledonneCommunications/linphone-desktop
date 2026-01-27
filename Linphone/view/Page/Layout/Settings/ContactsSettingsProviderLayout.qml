
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import UtilsCpp
import Linphone
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

RowLayout {
	id: mainItem
	
	property string title
	property string addText
	property string addTextDescription
	property string editText
	property string accessibleEditButtonText
	property string accessibleUseButtonText
	property var newItemGui
	property string settingsLayout
	property var proxyModel
	property var owner
	property string titleProperty
	property bool supportsEnableDisable
	property bool showAddButton

	signal save()
	signal undo()

    spacing: Utils.getSizeWithScreenRatio(5)
	ColumnLayout {
		Layout.fillWidth: true
		Layout.fillHeight: true
        spacing: Utils.getSizeWithScreenRatio(16)
		Repeater {
			model: mainItem.proxyModel
			RowLayout {
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignLeft|Qt.AlignHCenter
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(74)
                spacing: Utils.getSizeWithScreenRatio(20)
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
                    icon.width: Utils.getSizeWithScreenRatio(24)
                    icon.height: Utils.getSizeWithScreenRatio(24)
					Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
					onClicked: {
						mainItem.owner.container.push(mainItem.settingsLayout, {
							titleText: mainItem.editText,
							model: modelData,
							container: mainItem.owner.container,
							isNew: false})
					}
					Accessible.name: mainItem.accessibleEditButtonText.arg(modelData.core[titleProperty])
				}
				Switch {
					id: switchButton
					Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
					checked: supportsEnableDisable && modelData.core["enabled"]
					visible: supportsEnableDisable
					onToggled: {
						binding.when = true
					}
					Accessible.name: mainItem.accessibleUseButtonText.arg(modelData.core[titleProperty])
				}
				Binding {
					id: binding
					target: modelData ? modelData.core : null
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
					enabled: modelData
					target: modelData ? modelData.core : null
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
            spacing: Utils.getSizeWithScreenRatio(5)
			Item {
				Layout.fillWidth: true
			}
			MediumButton {
				Layout.alignment: Qt.AlignRight | Qt.AlignHCenter
                //: "Ajouter"
                text: qsTr("add")
				Accessible.name: mainItem.addText
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
