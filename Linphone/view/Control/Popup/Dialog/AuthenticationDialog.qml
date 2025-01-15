import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs

import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Dialog {
	id: mainItem
	
	property string identity
	property string domain
	readonly property string password: passwordEdit.text
	property var callback// Define cb(var) function
		
	topPadding: 20 * DefaultStyle.dp
	bottomPadding: 20 * DefaultStyle.dp
	leftPadding: 20 * DefaultStyle.dp
	rightPadding: 20 * DefaultStyle.dp
	width: 637 * DefaultStyle.dp
	modal: true
	closePolicy: Popup.NoAutoClose
	
	onAccepted: {
		if( callback) callback.cb(password)
		close()
	}
	onRejected: close()
	Component.onDestruction: if(callback) callback.destroy()
	
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
				id: passwordItem
				Layout.fillWidth: true
				label: qsTr("Mot de passe")
				enableErrorText: true
				mandatory: true
				contentItem: TextField {
					id: passwordEdit
					hidden: true
					isError: passwordItem.errorTextVisible
					KeyNavigation.up: usernameEdit
					KeyNavigation.down: cancelButton
				}
			}
		}
	}

	buttons: [
		MediumButton {
			id: cancelButton
			Layout.topMargin: 10 * DefaultStyle.dp
			text: qsTr("Annuler")
			style: ButtonStyle.secondary
			onClicked: mainItem.rejected()
			KeyNavigation.up: passwordEdit
			KeyNavigation.right: connectButton
		},
		MediumButton {
			id: connectButton
			Layout.topMargin: 10 * DefaultStyle.dp
			text: qsTr("Se connecter")
			style: ButtonStyle.main
			KeyNavigation.up: passwordEdit
			KeyNavigation.right: cancelButton
			onClicked: {
				passwordItem.errorMessage = ""
				if (passwordEdit.text.length == 0) {
					passwordItem.errorMessage = qsTr("Veuillez saisir un mot de passe")
					return
				}
				mainItem.accepted()
			}
		}
	]
}
