import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import Linphone
import SettingsCpp 1.0
import UtilsCpp

AbstractSettingsLayout {
	id: mainItem
	width: parent?.width
	contentModel: [
		{
			title: qsTr("Annuaires LDAP"),
			subTitle: qsTr("Ajouter vos annuaires LDAP pour pouvoir effectuer des recherches dans la magic search bar."),
			contentComponent: ldapParametersComponent
		}
	]

	topbarOptionalComponent: topBar
	property alias ldapGui: mainItem.model
	property bool isNew: false
	
	onSave: {
		if (ldapGui.core.isValid()) {
			ldapGui.core.save()
			UtilsCpp.showInformationPopup(qsTr("Succès"), qsTr("L'annuaire LDAP a été sauvegardé"), true, mainWindow)
		} else {
			UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Une erreur s'est produite, la configuration LDAP n'a pas été sauvegardée !"), false, mainWindow)
		}
	}

	Component {
		id: topBar
		RowLayout {
			spacing: 20 * DefaultStyle.dp
			Button {
				background: Item{}
				icon.source: AppIcons.trashCan
				icon.width: 32 * DefaultStyle.dp
				icon.height: 32 * DefaultStyle.dp
				contentImageColor: DefaultStyle.main2_600
				visible: !isNew
				onClicked: {
					var mainWin = UtilsCpp.getMainWindow()
					mainWin.showConfirmationLambdaPopup("",
						qsTr("Supprimer l'annuaire LDAP ?"),
						"",
						function (confirmed) {
							if (confirmed) {
								ldapGui.core.remove()
								mainItem.container.pop()
							}
						}
					)
				}
			}
		}
	}
	
	Component {
		id: ldapParametersComponent
		ColumnLayout {
			Layout.fillWidth: true
			spacing: 20 * DefaultStyle.dp
			Layout.rightMargin: 44 * DefaultStyle.dp
			Layout.topMargin: 20 * DefaultStyle.dp
			Layout.leftMargin: 64 * DefaultStyle.dp
			DecoratedTextField {
				id: server
				propertyName: "serverUrl"
				propertyOwner: ldapGui.core
				title: qsTr("URL du serveur (ne peut être vide)")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "bindDn"
				propertyOwner: ldapGui.core
				title: qsTr("Bind DN")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "password"
				hidden: true
				propertyOwner: ldapGui.core
				title: qsTr("Mot de passe")
				toValidate: true
				Layout.fillWidth: true
			}
			SwitchSetting {
				titleText: qsTr("Utiliser TLS")
				propertyName: "tls"
				propertyOwner: ldapGui.core
			}
			DecoratedTextField {
				propertyName: "baseObject"
				propertyOwner: ldapGui.core
				title: qsTr("Base de recherche (ne peut être vide)")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "filter"
				propertyOwner: ldapGui.core
				title: qsTr("Filtre")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "limit"
				propertyOwner: ldapGui.core
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
				title: qsTr("Nombre maximum de résultats")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "delay"
				propertyOwner: ldapGui.core
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
				title: qsTr("Délai entre 2 requêtes (en millisecondes)")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "timeout"
				propertyOwner: ldapGui.core
				title: qsTr("Durée maximun (en secondes)")
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "minCharacters"
				propertyOwner: ldapGui.core
				title: qsTr("Nombre minimum de caractères pour la requête")
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "nameAttribute"
				propertyOwner: ldapGui.core
				title: qsTr("Attributs de nom")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "sipAttribute"
				propertyOwner: ldapGui.core
				title: qsTr("Attributs SIP")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "sipDomain"
				propertyOwner: ldapGui.core
				title: qsTr("Domaine SIP")
				toValidate: true
				Layout.fillWidth: true
			}
			SwitchSetting {
				titleText: qsTr("Débogage")
				propertyName: "debug"
				propertyOwner: ldapGui.core
			}
		}
	}
}
