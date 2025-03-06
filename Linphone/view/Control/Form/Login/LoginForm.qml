import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import ConstantsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem
    spacing: Math.round(10 * DefaultStyle.dp)

	FormItemLayout {
		id: username
        Layout.preferredWidth: Math.round(346 * DefaultStyle.dp)
		label: qsTr("Nom d'utilisateur")
		mandatory: true
		enableErrorText: true
		contentItem: TextField {
			id: usernameEdit
            Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
			isError: username.errorTextVisible || (errorText.isVisible && text.length > 0)
		}
	}
	Item {
		Layout.preferredHeight: password.implicitHeight
		FormItemLayout {
			id: password
            width: Math.round(346 * DefaultStyle.dp)
			label: qsTr("Mot de passe")
			mandatory: true
			enableErrorText: true
			contentItem: TextField {
				id: passwordEdit
                Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
				isError: password.errorTextVisible || (errorText.isVisible && text.length > 0)
				hidden: true
			}
			TemporaryText {
				id: errorText
				anchors.bottom: parent.bottom
				Connections {
					target: LoginPageCpp
					function onErrorMessageChanged() {
						if (passwordEdit.text.length > 0 || usernameEdit.text.length > 0)
							errorText.setText(LoginPageCpp.errorMessage)
					}
				}
			}
		}

	}

	RowLayout {
        Layout.topMargin: Math.round(7 * DefaultStyle.dp)
        spacing: Math.round(29 * DefaultStyle.dp)
		BigButton {
			id: connectionButton
			style: ButtonStyle.main
			contentItem: StackLayout {
				id: connectionButtonContent
				currentIndex: 0
				Text {
					text: qsTr("Connexion")
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter

					font {
                        pixelSize: Typography.b1.pixelSize
                        weight: Typography.b1.weight
					}
					color: DefaultStyle.grey_0
				}
				BusyIndicator {
					implicitWidth: parent.height
					implicitHeight: parent.height
					Layout.alignment: Qt.AlignCenter
					indicatorColor: DefaultStyle.grey_0
				}
				Connections {
					target: LoginPageCpp
					function onRegistrationStateChanged() {
						if (LoginPageCpp.registrationState != LinphoneEnums.RegistrationState.Progress) {
							connectionButton.enabled = true
							connectionButtonContent.currentIndex = 0
						}
					}
					function onErrorMessageChanged() {
						connectionButton.enabled = true
						connectionButtonContent.currentIndex = 0
					}
				}
			}

			function trigger() {
				username.errorMessage = ""
				password.errorMessage = ""
				errorText.text = ""

				if (usernameEdit.text.length == 0 || passwordEdit.text.length == 0) {
					if (usernameEdit.text.length == 0)
						username.errorMessage = qsTr("Veuillez saisir un nom d'utilisateur")
					if (passwordEdit.text.length == 0)
						password.errorMessage = qsTr("Veuillez saisir un mot de passe")
					return
				}
				LoginPageCpp.login(usernameEdit.text, passwordEdit.text)
				connectionButton.enabled = false
				connectionButtonContent.currentIndex = 1
			}

			Shortcut {
				sequences: ["Return", "Enter"]
				onActivated: if(passwordEdit.activeFocus) connectionButton.trigger()
							else if( usernameEdit.activeFocus) passwordEdit.forceActiveFocus()
			}
			onPressed: connectionButton.trigger()
		}
		SmallButton {
			id: forgottenButton
			style: ButtonStyle.noBackground
			text: qsTr("Mot de passe oublié ?")
			underline: true
			onClicked: Qt.openUrlExternally(ConstantsCpp.PasswordRecoveryUrl)
		}
	
	}
}
