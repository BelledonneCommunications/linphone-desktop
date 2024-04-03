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
	
	titleContent: RowLayout {
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
		Item {
			Layout.fillWidth: true
		}
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
			onClicked: {
				console.debug("[SIPLoginPage] User: go to register page")
				mainItem.goToRegister()
			}
		}
	}
	
	centerContent: RowLayout {
		signal useSIPButtonClicked()
		Layout.topMargin: 85 * DefaultStyle.dp
		Control.StackView {
			id: rootStackView
			initialItem: firstItem
			Layout.preferredWidth: 361 * DefaultStyle.dp
			Layout.fillHeight: true
			Layout.alignment: Qt.AlignVCenter
			clip: true
		}
		Component {
			id: firstItem
			ColumnLayout {
			Layout.alignment: Qt.AlignVCenter
				spacing: 10 * DefaultStyle.dp
				// Layout.bottomMargin: 20 * DefaultStyle.dp
				Text {
					Layout.fillWidth: true
					Layout.preferredWidth: rootStackView.width
					width: rootStackView.width
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
				Item {
					Layout.preferredHeight: 85 * DefaultStyle.dp
				}
				Button {
					Layout.fillWidth: true
					inversedColors: true
					text: qsTr("I prefer creating an account")
					onClicked: {
						console.debug("[SIPLoginPage] User: click register")
						mainItem.goToRegister()
					}
				}
				Button {
					Layout.fillWidth: true
					text: qsTr("I understand")
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
				spacing: 10 * DefaultStyle.dp
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
					Layout.topMargin: 20 * DefaultStyle.dp
					Layout.bottomMargin: 20 * DefaultStyle.dp

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
		Item {
			Layout.fillWidth: true
		}
		Image {
			Layout.alignment: Qt.AlignVCenter
			Layout.rightMargin: 40 * DefaultStyle.dp
			Layout.preferredWidth: 395 * DefaultStyle.dp
			fillMode: Image.PreserveAspectFit
			source: AppIcons.loginImage
		}
		Item {
			Layout.fillHeight: true
		}
	}
}
