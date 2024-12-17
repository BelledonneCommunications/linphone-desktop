import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp
import UtilsCpp

AbstractSettingsMenu {
	id: mainItem
	layoutsPath: "qrc:/qt/qml/Linphone/view/Page/Layout/Settings"
	titleText: qsTr("Paramètres")
	families: [
		{title: qsTr("Appels"), layout: "CallSettingsLayout"},
		{title: qsTr("Conversations"), layout: "ChatSettingsLayout", visible: !SettingsCpp.disableChatFeature},
		{title: qsTr("Contacts"), layout: "ContactsSettingsLayout"},
		{title: qsTr("Réunions"), layout: "MeetingsSettingsLayout", visible: !SettingsCpp.disableMeetingsFeature},
		//{title: qsTr("Affichage"), layout: "DisplaySettingsLayout"},
		{title: qsTr("Réseau"), layout: "NetworkSettingsLayout"},
		{title: qsTr("Paramètres avancés"), layout: "AdvancedSettingsLayout"}
	]

	onGoBackRequested: if (!SettingsCpp.isSaved) {
		UtilsCpp.getMainWindow().showConfirmationLambdaPopup(qsTr("Modifications non enregistrées"),
			qsTr("Vous avez des modifications non enregistrées. Si vous quittez cette page, vos changements seront perdus. Voulez-vous enregistrer vos modifications avant de continuer ?"),
				"",
			function (confirmed) {
				if (confirmed) {
					SettingsCpp.save()
				} else {
					SettingsCpp.undo()
				}
				mainItem.goBack()
			}, qsTr("Ne pas enregistrer"), qsTr("Enregistrer")
		)
	} else {mainItem.goBack()}
}
