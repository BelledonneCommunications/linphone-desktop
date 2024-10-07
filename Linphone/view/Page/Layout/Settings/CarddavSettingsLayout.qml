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
	contentComponent: content
	topbarOptionalComponent: topBar
	property alias carddavGui: mainItem.model
	property bool isNew: false
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
					mainWin.showConfirmationLambdaPopup(
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
			Button {
				text: qsTr("Enregistrer")
				onClicked: {
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
			}
		}
	}
	
	Component {
		id: content
		ColumnLayout {
			width: parent.width
			spacing: 5 * DefaultStyle.dp
			RowLayout {
				Layout.topMargin: 16 * DefaultStyle.dp
				spacing: 5 * DefaultStyle.dp
				ColumnLayout {
					Layout.fillWidth: true
					spacing: 5 * DefaultStyle.dp
					ColumnLayout {
						Layout.preferredWidth: 341 * DefaultStyle.dp
						Layout.maximumWidth: 341 * DefaultStyle.dp
						Layout.minimumWidth: 341 * DefaultStyle.dp
						spacing: 5 * DefaultStyle.dp
						Text {
							Layout.fillWidth: true
							text: qsTr("Carnet  d'adresse CardDAV")
							font: Typography.h4
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_600
						}
						Text {
							text: qsTr("Ajouter un carnet d’adresse CardDAV pour synchroniser vos contacts Linphone avec un carnet d’adresse tiers.")
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
					Layout.fillWidth: true
					spacing: 20 * DefaultStyle.dp
					Layout.rightMargin: 44 * DefaultStyle.dp
					Layout.topMargin: 20 * DefaultStyle.dp
					Layout.leftMargin: 64 * DefaultStyle.dp
					DecoratedTextField {
						propertyName: "displayName"
						propertyOwner: carddavGui.core
						title: qsTr("Nom d’affichage")
						canBeEmpty: false
						toValidate: true
					}
					DecoratedTextField {
						propertyName: "uri"
						propertyOwner: carddavGui.core
						title: qsTr("URL du serveur")
						canBeEmpty: false
						toValidate: true
					}
					DecoratedTextField {
						propertyName: "username"
						propertyOwner: carddavGui.core
						title: qsTr("Nom d’utilisateur")
						toValidate: true
					}
					DecoratedTextField {
						propertyName: "password"
						hidden: true
						propertyOwner: carddavGui.core
						title: qsTr("Mot de passe")
						toValidate: true
					}
					DecoratedTextField {
						propertyName: "realm"
						propertyOwner: carddavGui.core
						title: qsTr("Domaine d’authentification")
						toValidate: true
					}
					SwitchSetting {
						titleText: qsTr("Stocker ici les contacts nouvellement crées")
						propertyName: "storeNewFriendsInIt"
						propertyOwner: carddavGui.core
					}
				}
			}
		}
	}
}
