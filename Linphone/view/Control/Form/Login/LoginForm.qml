import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import ConstantsCpp 1.0

ColumnLayout {
	id: mainItem
	spacing: 25 * DefaultStyle.dp
	signal connectionSucceed()

	FormItemLayout {
		id: username
		label: qsTr("Nom d'utilisateur")
		mandatory: true
		enableErrorText: true
		contentItem: TextField {
			id: usernameEdit
			isError: username.errorTextVisible || errorText.visible
			Layout.preferredWidth: 360 * DefaultStyle.dp
			Layout.preferredHeight: 49 * DefaultStyle.dp
		}
	}
	Item {
		Layout.preferredHeight: password.implicitHeight
		FormItemLayout {
			id: password
			label: qsTr("Mot de passe")
			mandatory: true
			enableErrorText: true
			contentItem: TextField {
				id: passwordEdit
				isError: password.errorTextVisible || errorText.visible
				Layout.preferredWidth: 360 * DefaultStyle.dp
				Layout.preferredHeight: 49 * DefaultStyle.dp
				hidden: true
			}
		}

		TemporaryText {
			id: errorText
			anchors.top: password.bottom
			Connections {
				target: LoginPageCpp
				function onErrorMessageChanged() {
					errorText.setText(LoginPageCpp.errorMessage)
				}
				function onRegistrationStateChanged() {
					if (LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Ok) {
						mainItem.connectionSucceed()
					}
				}
			}
		}
	}

	RowLayout {
		Layout.topMargin: 7 * DefaultStyle.dp
		spacing: 29 * DefaultStyle.dp
		Button {
			id: connectionButton
			leftPadding: 20 * DefaultStyle.dp
			rightPadding: 20 * DefaultStyle.dp
			topPadding: 11 * DefaultStyle.dp
			bottomPadding: 11 * DefaultStyle.dp
			contentItem: StackLayout {
				id: connectionButtonContent
				currentIndex: 0
				Text {
					text: qsTr("Connexion")
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter

					font {
						pixelSize: 18 * DefaultStyle.dp
						weight: 600 * DefaultStyle.dp
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
		Button {
			id: forgottenButton
			background: Item {
				visible: false
			}
			contentItem: Text {
				color: DefaultStyle.main2_500main
				text: qsTr("Mot de passe oublié ?")
				font{
					underline: true
					pixelSize: 13 * DefaultStyle.dp
					weight: 600 * DefaultStyle.dp
				}
			}
			onClicked: Qt.openUrlExternally(ConstantsCpp.PasswordRecoveryUrl)
		}
	
	}
}
