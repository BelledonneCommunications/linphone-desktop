import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import ConstantsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem
    spacing: Utils.getSizeWithScreenRatio(8)

	FormItemLayout {
		id: username
        Layout.preferredWidth: Utils.getSizeWithScreenRatio(346)
        //: Nom d'utilisateur : username
        label: qsTr("username")
		mandatory: true
		enableErrorText: true
		contentItem: TextField {
			id: usernameEdit
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(360)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
			isError: username.errorTextVisible || (errorText.isVisible && text.length > 0)
			onAccepted: passwordEdit.forceActiveFocus()
			//: "%1 mandatory"
			Accessible.name: qsTr("mandatory_field_accessible_name").arg(qsTr("username"))
		}
	}
	Item {
		Layout.preferredHeight: password.implicitHeight
		FormItemLayout {
			id: password
            width: Utils.getSizeWithScreenRatio(346)
            //: Mot de passe
            label: qsTr("password")
			mandatory: true
			enableErrorText: true
			contentItem: TextField {
				id: passwordEdit
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(360)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
				isError: password.errorTextVisible || (errorText.isVisible && text.length > 0)
				hidden: true
				onAccepted: connectionButton.trigger()
				Accessible.name: qsTr("password")
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
        Layout.topMargin: Utils.getSizeWithScreenRatio(7)
        spacing: Utils.getSizeWithScreenRatio(29)
		BigButton {
			id: connectionButton
			style: ButtonStyle.main
			Accessible.name: qsTr("assistant_account_login") 
			contentItem: StackLayout {
				id: connectionButtonContent
				currentIndex: 0
				Text {
                    //: "Connexion"
                    text: qsTr("assistant_account_login")
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
					indicatorWidth: Utils.getSizeWithScreenRatio(25)
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
                        //: "Veuillez saisir un nom d'utilisateur"
                        username.errorMessage = qsTr("assistant_account_login_missing_username")
					if (passwordEdit.text.length == 0)
                        //: "Veuillez saisir un mot de passe"
                        password.errorMessage = qsTr("assistant_account_login_missing_password")
					return
				}
				LoginPageCpp.login(usernameEdit.text, passwordEdit.text)
				connectionButton.enabled = false
				connectionButtonContent.currentIndex = 1
			}

			onPressed: connectionButton.trigger()
		}
		SmallButton {
			id: forgottenButton
			style: ButtonStyle.noBackground
            //: "Mot de passe oublié ?"
            text: qsTr("assistant_forgotten_password")
			underline: true
			onClicked: Qt.openUrlExternally(ConstantsCpp.PasswordRecoveryUrl)
		}
	
	}
}
