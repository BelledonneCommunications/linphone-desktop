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
			title: qsTr("Carnet  d'adresse CardDAV"),
			subTitle: qsTr("Ajouter un carnet d’adresse CardDAV pour synchroniser vos contacts Linphone avec un carnet d’adresse tiers."),
			contentComponent: cardDavParametersComponent
		}
	]
	topbarOptionalComponent: topBar
	property alias carddavGui: mainItem.model
	property bool isNew: false
	onSave: {
		if (carddavGui.core.isValid()) {
			carddavGui.core.save()
		} else {
			UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Vérifiez que toutes les informations ont été saisies."), false, mainWindow)
		}
	}
	Connections {
		target: carddavGui.core
		function onSaved(success) {
			if (success)
				UtilsCpp.showInformationPopup(qsTr("Succès"), qsTr("Le carnet d'adresse CardDAV est synchronisé."), true, mainWindow)
			else
				UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Erreur de synchronisation!"), false, mainWindow)
		}
	}
	Component {
		id: topBar
		RowLayout {
			spacing: 20 * DefaultStyle.dp
			BigButton {
				style: ButtonStyle.noBackground
				icon.source: AppIcons.trashCan
				icon.width: 32 * DefaultStyle.dp
				icon.height: 32 * DefaultStyle.dp
				visible: !isNew
				onClicked: {
					var mainWin = UtilsCpp.getMainWindow()
					mainWin.showConfirmationLambdaPopup("",
						qsTr("Supprimer le carnet d'adresse CardDAV ?"),
						"",
						function (confirmed) {
							if (confirmed) {
								carddavGui.core.remove()
								mainItem.container.pop()
							}
						}
					)
				}
			}
		}
	}
	
	Component {
		id: cardDavParametersComponent
		ColumnLayout {
			Layout.fillWidth: true
			spacing: 20 * DefaultStyle.dp
			Layout.rightMargin: 44 * DefaultStyle.dp
			Layout.topMargin: 20 * DefaultStyle.dp
			Layout.leftMargin: 64 * DefaultStyle.dp
			DecoratedTextField {
				propertyName: "displayName"
				propertyOwnerGui: carddavGui
				title: qsTr("Nom d’affichage")
				canBeEmpty: false
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "uri"
				propertyOwnerGui: carddavGui
				title: qsTr("URL du serveur")
				canBeEmpty: false
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "username"
				propertyOwnerGui: carddavGui
				title: qsTr("Nom d’utilisateur")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "password"
				hidden: true
				propertyOwnerGui: carddavGui
				title: qsTr("Mot de passe")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "realm"
				propertyOwnerGui: carddavGui
				title: qsTr("Domaine d’authentification")
				toValidate: true
				Layout.fillWidth: true
			}
			SwitchSetting {
				titleText: qsTr("Stocker ici les contacts nouvellement crées")
				propertyName: "storeNewFriendsInIt"
				propertyOwnerGui: carddavGui
			}
		}
	}
}
