import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import Linphone
import SettingsCpp 1.0
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

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
            spacing: Math.round(20 * DefaultStyle.dp)
			Button {
				style: ButtonStyle.noBackground
				icon.source: AppIcons.trashCan
                icon.width: Math.round(32 * DefaultStyle.dp)
                icon.height: Math.round(32 * DefaultStyle.dp)
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
            spacing: Math.round(20 * DefaultStyle.dp)
            Layout.rightMargin: Math.round(44 * DefaultStyle.dp)
            Layout.topMargin: Math.round(20 * DefaultStyle.dp)
            Layout.leftMargin: Math.round(64 * DefaultStyle.dp)
			DecoratedTextField {
				id: server
				propertyName: "serverUrl"
				propertyOwnerGui: ldapGui
				title: qsTr("URL du serveur (ne peut être vide)")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "bindDn"
				propertyOwnerGui: ldapGui
				title: qsTr("Bind DN")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "password"
				hidden: true
				propertyOwnerGui: ldapGui
				title: qsTr("Mot de passe")
				toValidate: true
				Layout.fillWidth: true
			}
			SwitchSetting {
				titleText: qsTr("Utiliser TLS")
				propertyName: "tls"
				propertyOwnerGui: ldapGui
			}
			DecoratedTextField {
				propertyName: "baseObject"
				propertyOwnerGui: ldapGui
				title: qsTr("Base de recherche (ne peut être vide)")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "filter"
				propertyOwnerGui: ldapGui
				title: qsTr("Filtre")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "limit"
				propertyOwnerGui: ldapGui
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
				title: qsTr("Nombre maximum de résultats")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "delay"
				propertyOwnerGui: ldapGui
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
				title: qsTr("Délai entre 2 requêtes (en millisecondes)")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "timeout"
				propertyOwnerGui: ldapGui
				title: qsTr("Durée maximun (en secondes)")
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "minCharacters"
				propertyOwnerGui: ldapGui
				title: qsTr("Nombre minimum de caractères pour la requête")
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "nameAttribute"
				propertyOwnerGui: ldapGui
				title: qsTr("Attributs de nom")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "sipAttribute"
				propertyOwnerGui: ldapGui
				title: qsTr("Attributs SIP")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "sipDomain"
				propertyOwnerGui: ldapGui
				title: qsTr("Domaine SIP")
				toValidate: true
				Layout.fillWidth: true
			}
			SwitchSetting {
				titleText: qsTr("Débogage")
				propertyName: "debug"
				propertyOwnerGui: ldapGui
			}
		}
	}
}
