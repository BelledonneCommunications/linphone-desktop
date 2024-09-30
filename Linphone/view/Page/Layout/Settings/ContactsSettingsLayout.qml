
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material as Control
import SettingsCpp 1.0
import Linphone

AbstractSettingsLayout {
	id: mainItem
	contentComponent: content
	function layoutUrl(name) {
		return layoutsPath+"/"+name+".qml"
	}
	Component {
		id: content
		RowLayout {
			spacing: 5 * DefaultStyle.dp
			ColumnLayout {
				Layout.fillWidth: true
				spacing: 5 * DefaultStyle.dp
				ColumnLayout {
					Layout.preferredWidth: 341 * DefaultStyle.dp
					Layout.maximumWidth: 341 * DefaultStyle.dp
					spacing: 5 * DefaultStyle.dp
					Text {
						text: qsTr("Annuaires LDAP")
						font: Typography.h4
						wrapMode: Text.WordWrap
						color: DefaultStyle.main2_600
						Layout.fillWidth: true
					}
					Text {
						text: qsTr("Ajouter vos annuaires LDAP pour pouvoir effectuer des recherches dans la magic search bar.")
						font: Typography.p1s
						wrapMode: Text.WordWrap
						color: DefaultStyle.main2_600
						Layout.fillWidth: true
					}
				}
				Item {
					Layout.fillHeight: true
				}
			}
			ColumnLayout {
				Layout.rightMargin: 25 * DefaultStyle.dp
				Layout.fillWidth: true
				Layout.fillHeight: true
				spacing: 27 * DefaultStyle.dp
				Layout.leftMargin: 76 * DefaultStyle.dp
				Layout.topMargin: 16 * DefaultStyle.dp
				Repeater {
					model: LdapProxy {
						id: proxyModel
					}
					RowLayout {
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignLeft|Qt.AlignHCenter
						spacing: 5 * DefaultStyle.dp
						Text {
							text: modelData.core.server
							font: Typography.p2l
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_600
							Layout.fillWidth: true
							Layout.leftMargin: 17 * DefaultStyle.dp
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
								var ldapGui = Qt.createQmlObject('import Linphone
											LdapGui{
											}', mainItem)
								mainItem.container.push(layoutUrl("LdapSettingsLayout"), {
									titleText: qsTr("Modifier un annuaire LDAP"),
									model: modelData,
									container: mainItem.container,
									isNew: false})
							}
						}
						Switch {
							id: switchButton
							Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
							Layout.rightMargin: 17 * DefaultStyle.dp
							checked: modelData.core["enabled"]
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
						Layout.alignment: Qt.AlignRight | Qt.AlignHCenter
						text: qsTr("Ajouter")
						onClicked: {
							var ldapGui = Qt.createQmlObject('import Linphone
											LdapGui{
											}', mainItem)
							mainItem.container.push(layoutUrl("LdapSettingsLayout"), {
								titleText: qsTr("Ajouter un annuaire LDAP"),
								model: ldapGui,
								container: mainItem.container,
								isNew: true})
						}
					}
				}
			}

		}
	}
}
