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
            title: qsTr("settings_contacts_ldap_title"),
            subTitle: qsTr("settings_contacts_ldap_subtitle"),
			contentComponent: ldapParametersComponent
		}
	]

	topbarOptionalComponent: topBar
	property alias ldapGui: mainItem.model
	property bool isNew: false
	
	onSave: {
		if (ldapGui.core.isValid()) {
			ldapGui.core.save()
            UtilsCpp.showInformationPopup(qsTr("information_popup_success_title"),
                                          //: "L'annuaire LDAP a été sauvegardé"
                                          qsTr("settings_contacts_ldap_success_toast"), true, mainWindow)
		} else {
            UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                          //: "Une erreur s'est produite, la configuration LDAP n'a pas été sauvegardée !"
                                          qsTr("settings_contacts_ldap_error_toast"), false, mainWindow)
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
                        //: "Supprimer l'annuaire LDAP ?"
                        qsTr("settings_contacts_ldap_delete_confirmation_message"),
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
                //: "URL du serveur (ne peut être vide)"
                title: qsTr("settings_contacts_ldap_server_url_title")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "bindDn"
				propertyOwnerGui: ldapGui
                //: "Bind DN"
                title: qsTr("settings_contacts_ldap_bind_dn_title")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "password"
				hidden: true
				propertyOwnerGui: ldapGui
                //: "Mot de passe"
                title: qsTr("settings_contacts_ldap_password_title")
				toValidate: true
				Layout.fillWidth: true
			}
			SwitchSetting {
                //: "Utiliser TLS"
                titleText: qsTr("settings_contacts_ldap_use_tls_title")
				propertyName: "tls"
				propertyOwnerGui: ldapGui
			}
			DecoratedTextField {
				propertyName: "baseObject"
				propertyOwnerGui: ldapGui
                //: "Base de recherche (ne peut être vide)"
                title: qsTr("settings_contacts_ldap_search_base_title")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "filter"
				propertyOwnerGui: ldapGui
                //: "Filtre"
                title: qsTr("settings_contacts_ldap_search_filter_title")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "limit"
				propertyOwnerGui: ldapGui
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
                //: "Nombre maximum de résultats"
                title: qsTr("settings_contacts_ldap_max_results_title")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "delay"
				propertyOwnerGui: ldapGui
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
                //: "Délai entre 2 requêtes (en millisecondes)"
                title: qsTr("settings_contacts_ldap_request_delay_title")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "timeout"
				propertyOwnerGui: ldapGui
                //: "Durée maximun (en secondes)"
                title: qsTr("settings_contacts_ldap_request_timeout_title")
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "minCharacters"
				propertyOwnerGui: ldapGui
                //: "Nombre minimum de caractères pour la requête"
                title: qsTr("settings_contacts_ldap_min_characters_title")
				validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "nameAttribute"
				propertyOwnerGui: ldapGui
                //: "Attributs de nom"
                title: qsTr("settings_contacts_ldap_name_attributes_title")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "sipAttribute"
				propertyOwnerGui: ldapGui
                //: "Attributs SIP"
                title: qsTr("settings_contacts_ldap_sip_attributes_title")
				toValidate: true
				Layout.fillWidth: true
			}
			DecoratedTextField {
				propertyName: "sipDomain"
				propertyOwnerGui: ldapGui
                //: "Domaine SIP"
                title: qsTr("settings_contacts_ldap_sip_domain_title")
				toValidate: true
				Layout.fillWidth: true
			}
			SwitchSetting {
                //: "Débogage"
                titleText: qsTr("settings_contacts_ldap_debug_title")
				propertyName: "debug"
				propertyOwnerGui: ldapGui
			}
		}
	}
}
