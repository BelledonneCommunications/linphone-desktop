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
		
    topPadding:Math.round( 20 * DefaultStyle.dp)
    bottomPadding:Math.round( 20 * DefaultStyle.dp)
    leftPadding:Math.round( 20 * DefaultStyle.dp)
    rightPadding:Math.round( 20 * DefaultStyle.dp)
    width:Math.round( 637 * DefaultStyle.dp)
	modal: true
	closePolicy: Popup.NoAutoClose
	
	onAccepted: {
		if( callback) callback.cb(password)
		close()
	}
	onRejected: close()
	Component.onDestruction: if(callback) callback.destroy()
	
	content: ColumnLayout {
        spacing:Math.round( 20 * DefaultStyle.dp)
		id: contentLayout
        Text {
            Layout.fillWidth: true
            Layout.preferredWidth:Math.round( 250 * DefaultStyle.dp)
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font {
                pixelSize: Typography.h3.pixelSize
                weight: Typography.h3.weight
            }
            //: "Authentification requise"
            text: qsTr("account_settings_dialog_invalid_password_title")
        }
		Text {
			Layout.fillWidth: true
            Layout.preferredWidth:Math.round( 250 * DefaultStyle.dp)
			Layout.alignment: Qt.AlignHCenter
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.Wrap
            //: La connexion a échoué pour le compte %1. Vous pouvez renseigner votre mot de passe à nouveau ou bien vérifier les options de configuration de votre compte.
            text: qsTr("account_settings_dialog_invalid_password_message").arg(mainItem.identity)
            font.pixelSize:Math.round( 16 * DefaultStyle.dp)
            font {
                pixelSize: Typography.h4.pixelSize
                weight: Typography.h4.weight
            }
		}
        FormItemLayout {
            id: passwordItem
            Layout.fillWidth: true
            label: qsTr("password")
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

	buttons: [
		MediumButton {
			id: cancelButton
            Layout.topMargin: Math.round( 10 * DefaultStyle.dp)
            //: "Annuler
            text: qsTr("cancel")
			style: ButtonStyle.secondary
			onClicked: mainItem.rejected()
			KeyNavigation.up: passwordEdit
			KeyNavigation.right: connectButton
		},
		MediumButton {
			id: connectButton
            Layout.topMargin:Math.round( 10 * DefaultStyle.dp)
            //: Connexion
            text: qsTr("assistant_account_login")
			style: ButtonStyle.main
			KeyNavigation.up: passwordEdit
			KeyNavigation.right: cancelButton
			onClicked: {
				passwordItem.errorMessage = ""
                if (passwordEdit.text.length == 0) {
                    //: Veuillez saisir un mot de passe
                    passwordItem.errorMessage = qsTr("assistant_account_login_missing_password")
					return
				}
				mainItem.accepted()
			}
		}
	]
}
