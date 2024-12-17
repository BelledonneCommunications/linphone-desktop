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
	titleText: qsTr("Mon compte")
	property AccountGui account
	signal accountRemoved()
	families: [
		{title: qsTr("Général"), layout: "AccountSettingsGeneralLayout", model: account},
		{title: qsTr("Paramètres de compte"), layout: "AccountSettingsParametersLayout", model: account}
	]
	Connections {
		target: account.core
		onRemoved: accountRemoved()
	}
	onGoBackRequested: if (!account.core.isSaved) {
		UtilsCpp.getMainWindow().showConfirmationLambdaPopup(qsTr("Modifications non enregistrées"),
			qsTr("Vous avez des modifications non enregistrées. Si vous quittez cette page, vos changements seront perdus. Voulez-vous enregistrer vos modifications avant de continuer ?"),
			"",
			function (confirmed) {
				if (confirmed) {
					account.core.save()
				} else {
					account.core.undo()
				}
				mainItem.goBack()
			}, qsTr("Ne pas enregistrer"), qsTr("Enregistrer")
		)
	} else {mainItem.goBack()}
}
