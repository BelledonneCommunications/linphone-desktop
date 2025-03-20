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
            //: Carnet  d'adresse CardDAV
            title: qsTr("settings_contacts_carddav_title"),
            //: "Ajouter un carnet d’adresse CardDAV pour synchroniser vos contacts Linphone avec un carnet d’adresse tiers."
            subTitle: qsTr("settings_contacts_carddav_subtitle"),
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
            UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                          //: "Vérifiez que toutes les informations ont été saisies."
                                          qsTr("settings_contacts_carddav_popup_invalid_error"), false, mainWindow)
		}
	}
	Connections {
		target: carddavGui.core
		function onSaved(success) {
			if (success)
                UtilsCpp.showInformationPopup(qsTr("information_popup_synchronization_success_title"),
                                              //: "Le carnet d'adresse CardDAV est synchronisé."
                                              qsTr("settings_contacts_carddav_synchronization_success_message"), true, mainWindow)
			else
                UtilsCpp.showInformationPopup(qsTr("settings_contacts_carddav_popup_synchronization_error_title"),
                                              //: "Erreur de synchronisation!"
                                              qsTr("settings_contacts_carddav_popup_synchronization_error_message"), false, mainWindow)
		}
	}
	Component {
		id: topBar
		RowLayout {
            spacing: Math.round(20 * DefaultStyle.dp)
			BigButton {
				style: ButtonStyle.noBackground
				icon.source: AppIcons.trashCan
                icon.width: Math.round(32 * DefaultStyle.dp)
                icon.height: Math.round(32 * DefaultStyle.dp)
				visible: !isNew
				onClicked: {
					var mainWin = UtilsCpp.getMainWindow()
					mainWin.showConfirmationLambdaPopup("",
                        //: "Supprimer le carnet d'adresse CardDAV ?"
                        qsTr("settings_contacts_delete_carddav_server_title"),
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
            spacing: Math.round(20 * DefaultStyle.dp)
            Layout.rightMargin: Math.round(44 * DefaultStyle.dp)
            Layout.topMargin: Math.round(20 * DefaultStyle.dp)
            Layout.leftMargin: Math.round(64 * DefaultStyle.dp)
			DecoratedTextField {
				propertyName: "displayName"
				propertyOwnerGui: carddavGui
                //: Nom d'affichage
                title: qsTr("sip_address_display_name")
				canBeEmpty: false
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "uri"
				propertyOwnerGui: carddavGui
                //: "URL du serveur"
                title: qsTr("settings_contacts_carddav_server_url_title")
				canBeEmpty: false
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "username"
				propertyOwnerGui: carddavGui
                title: qsTr("username")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "password"
				hidden: true
				propertyOwnerGui: carddavGui
                title: qsTr("password")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "realm"
				propertyOwnerGui: carddavGui
                //: Domaine d’authentification
                title: qsTr("settings_contacts_carddav_realm_title")
				toValidate: true
				Layout.fillWidth: true
			}
			SwitchSetting {
                //: "Stocker ici les contacts nouvellement crées"
                titleText: qsTr("settings_contacts_carddav_use_as_default_title")
				propertyName: "storeNewFriendsInIt"
				propertyOwnerGui: carddavGui
			}
		}
	}
}
