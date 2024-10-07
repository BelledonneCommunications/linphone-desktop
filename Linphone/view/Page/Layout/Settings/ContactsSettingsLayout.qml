
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import Linphone

AbstractSettingsLayout {
	id: mainItem
	contentComponent: content
	function layoutUrl(name) {
		return layoutsPath+"/"+name+".qml"
	}
	function createGuiObject(name) {
		return Qt.createQmlObject('import Linphone; '+name+'Gui{}', mainItem)
	}
	Component {
		id: content
		ColumnLayout {
			spacing: 5 * DefaultStyle.dp
			ContactsSettingsProviderLayout {
				title: qsTr("Annuaires LDAP")
				addText: qsTr("Ajouter un annuaire LDAP")
				addTextDescription: qsTr("Ajouter vos annuaires LDAP pour pouvoir effectuer des recherches dans la magic search bar.")
				editText: qsTr("Modifier un annuaire LDAP")
				proxyModel: LdapProxy {}
				newItemGui: createGuiObject('Ldap')
				settingsLayout: layoutUrl("LdapSettingsLayout")
				owner: mainItem
				titleProperty: "server"
				supportsEnableDisable: true
				showAddButton: true
			}
			Rectangle {
				Layout.fillWidth: true
				Layout.topMargin: 35 * DefaultStyle.dp
				Layout.bottomMargin: 9 * DefaultStyle.dp
				height: 1 * DefaultStyle.dp
				color: DefaultStyle.main2_500main
			}
			ContactsSettingsProviderLayout {
				id: carddavProvider
				title: qsTr("Carnet d'adresse CardDAV")
				addText: qsTr("Ajouter un carnet d'adresse CardDAV")
				addTextDescription: qsTr("Ajouter un carnet d’adresse CardDAV pour synchroniser vos contacts Linphone avec un carnet d’adresse tiers.")
				editText: qsTr("Modifier un carnet d'adresse CardDAV")
				proxyModel: CarddavProxy {
					onModelReset:  {
						carddavProvider.showAddButton = carddavProvider.proxyModel.count == 0
						carddavProvider.newItemGui = createGuiObject('Carddav')
					}
				}
				newItemGui: createGuiObject('Carddav')
				settingsLayout: layoutUrl("CarddavSettingsLayout")
				owner: mainItem
				titleProperty: "displayName"
				supportsEnableDisable: false
			}
		}
	}
}
