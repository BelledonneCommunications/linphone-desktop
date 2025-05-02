import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp
import UtilsCpp

AbstractSettingsMenu {
	id: mainItem
	layoutsPath: "qrc:/qt/qml/Linphone/view/Page/Layout/Settings"
    //: "Paramètres"
    titleText: qsTr("settings_title")
	families: [
        //: "Appels"
        {title: qsTr("settings_calls_title"), layout: "CallSettingsLayout"},
		//: "Transfert d'appel"
        {title: qsTr("settings_call_forward"), layout: "CallForwardSettingsLayout"},
        //: "Conversations"
        {title: qsTr("settings_conversations_title"), layout: "ChatSettingsLayout", visible: !SettingsCpp.disableChatFeature},
        //: "Contacts"
        {title: qsTr("settings_contacts_title"), layout: "ContactsSettingsLayout"},
        //: "Réunions"
        {title: qsTr("settings_meetings_title"), layout: "MeetingsSettingsLayout", visible: !SettingsCpp.disableMeetingsFeature},
        //: "Affichage"
        //{title: qsTr("settings_user_interface_title"), layout: "DisplaySettingsLayout"},
        //: "Réseau"
        {title: qsTr("settings_network_title"), layout: "NetworkSettingsLayout"},
        //: "Paramètres avancés"
        {title: qsTr("settings_advanced_title"), layout: "AdvancedSettingsLayout"}
	]

	onGoBackRequested: if (!SettingsCpp.isSaved) {
                           //: Modifications non enregistrées
        UtilsCpp.getMainWindow().showConfirmationLambdaPopup(qsTr("contact_editor_popup_abort_confirmation_title"),
            //: Vous avez des modifications non enregistrées. Si vous quittez cette page, vos changements seront perdus. Voulez-vous enregistrer vos modifications avant de continuer ?
            qsTr("contact_editor_popup_abort_confirmation_message"),
				"",
			function (confirmed) {
				if (confirmed) {
					SettingsCpp.save()
				} else {
					SettingsCpp.undo()
				}
				mainItem.goBack()
                //: "Ne pas enregistrer"
            }, qsTr("contact_editor_dialog_abort_confirmation_do_not_save"),
            //: "Enregistrer"
            qsTr("contact_editor_dialog_abort_confirmation_save")
		)
	} else {mainItem.goBack()}
}
