import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs

import Linphone
import UtilsCpp
import SettingsCpp

Dialog {
	id: mainItem
	property string identity
	property string domain
	readonly property string password: passwordEdit.text
	onRejected: close()
	modal: true
	closePolicy: Popup.NoAutoClose
	topPadding: 20 * DefaultStyle.dp
	bottomPadding: 20 * DefaultStyle.dp
	leftPadding: 20 * DefaultStyle.dp
	rightPadding: 20 * DefaultStyle.dp
	content: ColumnLayout {
		spacing: 20 * DefaultStyle.dp
		id: contentLayout
		Text {
			Layout.fillWidth: true
			Layout.preferredWidth: 250 * DefaultStyle.dp
			Layout.alignment: Qt.AlignHCenter
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.Wrap
			text: qsTr("Impossible de vous authentifier. Merci de vérifier votre mot de passe.")
			font.pixelSize: 16 * DefaultStyle.dp
		}
		ColumnLayout {
			spacing: 10 * DefaultStyle.dp
			FormItemLayout {
				Layout.fillWidth: true
				label: qsTr("Identité")
				contentItem: TextField {
					enabled: false
					customWidth: parent.width
					initialText: mainItem.identity
				}
			}
			FormItemLayout {
				Layout.fillWidth: true
				label: qsTr("Domaine")
				contentItem: TextField {
					enabled: false
					initialText: mainItem.domain
				}
			}
			FormItemLayout {
				Layout.fillWidth: true
				label: qsTr("Nom d'utilisateur (optionnel)")
				contentItem: TextField {
					id: usernameEdit
					KeyNavigation.down: passwordEdit
				}
			}
			FormItemLayout {
				id: password
				Layout.fillWidth: true
				label: qsTr("Mot de passe")
				enableErrorText: true
				mandatory: true
				contentItem: TextField {
					id: passwordEdit
					hidden: true
					isError: password.errorTextVisible
					KeyNavigation.up: usernameEdit
					KeyNavigation.down: cancelButton
				}
			}
		}
	}

	buttons: [
		Button {
			id: cancelButton
			Layout.topMargin: 10 * DefaultStyle.dp
			text: qsTr("Annuler")
			inversedColors: true
			onClicked: mainItem.rejected()
			KeyNavigation.up: passwordEdit
			KeyNavigation.right: connectButton
		},
		Button {
			id: connectButton
			Layout.topMargin: 10 * DefaultStyle.dp
			text: qsTr("Se connecter")
			KeyNavigation.up: passwordEdit
			KeyNavigation.right: cancelButton
			onClicked: {
				password.errorMessage = ""
				if (passwordEdit.text.length == 0) {
					password.errorMessage = qsTr("Veuillez saisir un mot de passe")
					return
				}
				mainItem.accepted()
			}
		}
	]
}
