
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import Linphone

AbstractSettingsLayout {
	id: mainItem
	width: parent?.width
	contentModel: [
		{
            //: Annuaires LDAP
            title: qsTr("settings_contacts_ldap_title"),
            //: "Ajouter vos annuaires LDAP pour pouvoir effectuer des recherches dans la barre de recherche."
            subTitle: qsTr("settings_contacts_ldap_subtitle"),
			contentComponent: ldapParametersComponent,
			hideTopMargin: true
		},
		{
            title: qsTr("settings_contacts_carddav_title"),
            subTitle: qsTr("settings_contacts_carddav_subtitle"),
			contentComponent: cardDavParametersComponent,
			hideTopMargin: true
		}
	]

	function layoutUrl(name) {
		return layoutsPath+"/"+name+".qml"
	}
	function createGuiObject(name) {
		return Qt.createQmlObject('import Linphone; '+name+'Gui{}', mainItem)
	}

	// Ldap parameters
	//////////////////

	Component {
		id: ldapParametersComponent
		ContactsSettingsProviderLayout {
            //: "Ajouter un annuaire LDAP"
            addText: qsTr("settings_contacts_add_ldap_server_title")
            //: "Modifier un annuaire LDAP"
            editText: qsTr("settings_contacts_edit_ldap_server_title")
			proxyModel: LdapProxy {}
			newItemGui: createGuiObject('Ldap')
			settingsLayout: layoutUrl("LdapSettingsLayout")
			owner: mainItem
			titleProperty: "serverUrl"
			supportsEnableDisable: true
			showAddButton: true

			Connections {
				target: mainItem
				function onSave() { save()}
				function onUndo() { undo()}
			}
		}
	}

	// CardDAV parameters
	/////////////////////

	Component {
		id: cardDavParametersComponent
		ContactsSettingsProviderLayout {
			id: carddavProvider
            //: "Ajouter un carnet d'adresse CardDAV"
            addText: qsTr("settings_contacts_add_carddav_server_title")
            //: "Modifier un carnet d'adresse CardDAV"
            editText: qsTr("settings_contacts_edit_carddav_server_title")
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

			Connections {
				target: mainItem
				function onSave() { save()}
				function onUndo() { undo()}
			}
		}
	}
}
