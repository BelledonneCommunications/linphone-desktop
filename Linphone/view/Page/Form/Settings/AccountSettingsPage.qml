import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp

AbstractSettingsMenu {
	id: mainItem
	layoutsPath: "qrc:/qt/qml/Linphone/view/Page/Layout/Settings"
    //: "Mon compte"
    titleText: qsTr("drawer_menu_manage_account")
	property AccountGui account
	signal accountRemoved()
	families: [
        //: "Général"
        {title: qsTr("settings_general_title"), layout: "AccountSettingsGeneralLayout", model: account},
        //: "Paramètres de compte"
        {title: qsTr("settings_account_title"), layout: "AccountSettingsParametersLayout", model: account}
	]
	Connections {
		target: account.core
		function onRemoved() { accountRemoved() }
	}
	onGoBackRequested: if (!account.core.isSaved) {
                           //: "Modifications non enregistrées"
        UtilsCpp.getMainWindow().showConfirmationLambdaPopup(qsTr("contact_editor_popup_abort_confirmation_title"),
                                                             //: "Vous avez des modifications non enregistrées. Si vous quittez cette page, vos changements seront perdus. Voulez-vous enregistrer vos modifications avant de continuer ?"
            qsTr("contact_editor_popup_abort_confirmation_message"),
			"",
			function (confirmed) {
				if (confirmed) {
					account.core.save()
				} else {
					account.core.undo()
				}
				mainItem.goBack()
                //: "Ne pas enregistrer"
                //: "Enregistrer"
            }, qsTr("contact_editor_dialog_abort_confirmation_do_not_save"), qsTr("contact_editor_dialog_abort_confirmation_save")
		)
	} else {mainItem.goBack()}
}
