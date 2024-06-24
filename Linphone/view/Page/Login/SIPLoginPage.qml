import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control
import Linphone
import ConstantsCpp 1.0

LoginLayout {
	id: mainItem
	signal goBack()
	signal goToRegister()
	signal connectionSucceed()
	
	titleContent: [
		RowLayout {
			Layout.leftMargin: 119 * DefaultStyle.dp
			spacing: 21 * DefaultStyle.dp
			Button {
				Layout.preferredHeight: 24 * DefaultStyle.dp
				Layout.preferredWidth: 24 * DefaultStyle.dp
				icon.source: AppIcons.leftArrow
				icon.width: 24 * DefaultStyle.dp
				icon.height: 24 * DefaultStyle.dp
				background: Item {
					anchors.fill: parent
				}
				onClicked: {
					console.debug("[SIPLoginPage] User: return")
					mainItem.goBack()
				}
			}
			Image {
				fillMode: Image.PreserveAspectFit
				source: AppIcons.profile
				Layout.preferredHeight: 34 * DefaultStyle.dp
				Layout.preferredWidth: 34 * DefaultStyle.dp
				sourceSize.width: 34 * DefaultStyle.dp
				sourceSize.height: 34 * DefaultStyle.dp
			}
			Text {
				text: qsTr("Compte SIP tiers")
				font {
					pixelSize: 36 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
				scaleLettersFactor: 1.1
			}
		},
		Item {
			Layout.fillWidth: true
		},
		RowLayout {
			Layout.rightMargin: 51 * DefaultStyle.dp
			spacing: 20 * DefaultStyle.dp
			Text {
				Layout.rightMargin: 15 * DefaultStyle.dp
				text: qsTr("Pas encore de compte ?")
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 400 * DefaultStyle.dp
				}
			}
			Button {
				Layout.alignment: Qt.AlignRight
				text: qsTr("S'inscrire")
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				onClicked: {
					console.debug("[SIPLoginPage] User: go to register page")
					mainItem.goToRegister()
				}
			}
		}
	]
	
	Component {
		id: firstItem
		ColumnLayout {
			spacing: 0
			Text {
				Layout.fillWidth: true
				Layout.preferredWidth: rootStackView.width
				wrapMode: Text.WordWrap
				color: DefaultStyle.main2_600
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 400* DefaultStyle.dp
				}
				text: "<p>Some features require a Linphone account, such as group messaging, video conferences...</p> 
				<p>These features are hidden when you register with a third party SIP account.</p>
				<p>To enable it in a commercial projet, please contact us. </p>"
			}
			Button {
				Layout.topMargin: 18 * DefaultStyle.dp
				text: "linphone.org/contact"
				textSize: 13 * DefaultStyle.dp
				inversedColors: true
				leftPadding: 12 * DefaultStyle.dp
				rightPadding: 12 * DefaultStyle.dp
				topPadding: 6 * DefaultStyle.dp
				bottomPadding: 6 * DefaultStyle.dp
				onClicked: {
					Qt.openUrlExternally(ConstantsCpp.ContactUrl)
				}
			}
			Button {
				Layout.topMargin: 85 * DefaultStyle.dp
				Layout.preferredWidth: 360 * DefaultStyle.dp
				inversedColors: true
				text: qsTr("I prefer creating an account")
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				onClicked: {
					console.debug("[SIPLoginPage] User: click register")
					mainItem.goToRegister()
				}
			}
			Button {
				Layout.topMargin: 20 * DefaultStyle.dp
				Layout.preferredWidth: 360 * DefaultStyle.dp
				text: qsTr("I understand")
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				onClicked: {
					rootStackView.replace(secondItem)
				}
			}
			Item {
				Layout.fillHeight: true
			}
		}
	}
	Component {
		id: secondItem
		ColumnLayout {
			spacing: 0
			ColumnLayout {
				spacing: 16 * DefaultStyle.dp
				FormItemLayout {
					label: qsTr("Username")
					mandatory: true
					contentItem: TextField {
						id: username
						Layout.preferredWidth: 360 * DefaultStyle.dp
					}
				}
				FormItemLayout {
					label: qsTr("Password")
					mandatory: true
					contentItem: TextField {
						id: password
						hidden: true
						Layout.preferredWidth: 360 * DefaultStyle.dp
					}
				}
				FormItemLayout {
					label: qsTr("Domain")
					mandatory: true
					contentItem: TextField {
						id: domain
						Layout.preferredWidth: 360 * DefaultStyle.dp
					}
				}
				FormItemLayout {
					label: qsTr("Display Name")
					contentItem: TextField {
						id: displayName
						Layout.preferredWidth: 360 * DefaultStyle.dp
					}
				}
				FormItemLayout {
					label: qsTr("Transport")
					contentItem: ComboBox {
						height: 49 * DefaultStyle.dp
						width: 360 * DefaultStyle.dp
						model:[ "TCP", "UDP", "TLS", "DTLS"]
					}
				}
			}

			ErrorText {
				id: errorText
				Connections {
					target: LoginPageCpp
					onRegistrationStateChanged: {
						if (LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Failed) {
							errorText.text = qsTr("Connection has failed. Please verify your credentials")
						} else if (LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Ok) {
							mainItem.connectionSucceed()
						}
					}
				}
			}

			Button {
				Layout.topMargin: 32 * DefaultStyle.dp
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				text: qsTr("Log in")
				onClicked: {
					console.debug("[SIPLoginPage] User: Log in")
					LoginPageCpp.login(username.inputText, password.inputText);
				}
			}
			Item {
				Layout.fillHeight: true
			}
		}
	
	}

	centerContent: [
		Control.StackView {
			id: rootStackView
			initialItem: firstItem
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			anchors.topMargin: 70 * DefaultStyle.dp
			anchors.leftMargin: 127 * DefaultStyle.dp
			width: 361 * DefaultStyle.dp
			clip: true
		},
		Image {
			z: -1
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.topMargin: 129 * DefaultStyle.dp
			anchors.rightMargin: 127 * DefaultStyle.dp
			width: 395 * DefaultStyle.dp
			height: 350 * DefaultStyle.dp
			fillMode: Image.PreserveAspectFit
			source: AppIcons.loginImage
		}
	]
}
