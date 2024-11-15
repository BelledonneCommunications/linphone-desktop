
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
			title: qsTr("Annuaires LDAP"),
			subTitle: qsTr("Ajouter vos annuaires LDAP pour pouvoir effectuer des recherches dans la magic search bar."),
			contentComponent: ldapParametersComponent,
			hideTopMargin: true
		},
		{
			title: qsTr("Carnet d'adresse CardDAV"),
			subTitle: qsTr("Ajouter un carnet d’adresse CardDAV pour synchroniser vos contacts Linphone avec un carnet d’adresse tiers."),
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
			addText: qsTr("Ajouter un annuaire LDAP")
			editText: qsTr("Modifier un annuaire LDAP")
			proxyModel: LdapProxy {}
			newItemGui: createGuiObject('Ldap')
			settingsLayout: layoutUrl("LdapSettingsLayout")
			owner: mainItem
			titleProperty: "server"
			supportsEnableDisable: true
			showAddButton: true
		}
	}

	// CardDAV parameters
	/////////////////////

	Component {
		id: cardDavParametersComponent
		ContactsSettingsProviderLayout {
			id: carddavProvider
			addText: qsTr("Ajouter un carnet d'adresse CardDAV")
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
