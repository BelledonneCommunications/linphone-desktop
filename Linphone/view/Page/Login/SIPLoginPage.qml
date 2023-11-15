import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control
import Linphone
import ConstantsCpp 1.0

LoginLayout {
	id: mainItem
	signal returnToLogin()
	signal goToRegister()
	signal connectionSucceed()
	
	titleContent: RowLayout {
		Control.Button {
			Layout.preferredHeight: 40
    		Layout.preferredWidth: 40
			icon.width: 40
			icon.height: 40
			icon.source: AppIcons.returnArrow
			background: Rectangle {
				color: "transparent"
			}
			onClicked: {
				console.debug("[SIPLoginPage] User: return")
				mainItem.returnToLogin()
			}
		}
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		Text {
			text: "Use a SIP Account"
			font.pointSize: DefaultStyle.title2FontPointSize
			font.bold: true
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
		Text {
			Layout.rightMargin: 15
			text: "No account yet ?"
			font.pointSize: DefaultStyle.defaultTextSize
		}
		Button {
			Layout.alignment: Qt.AlignRight
			inversedColors: true
			text: "Register"
			onClicked: {
				console.debug("[SIPLoginPage] User: go to register page")
				mainItem.goToRegister()
			}
		}
	}
	
	centerContent: ColumnLayout {
		signal useSIPButtonClicked()
		RowLayout {
			Control.StackView {
				id: rootStackView
				initialItem: firstItem
				Layout.preferredWidth: 280
				Layout.fillHeight: true
				Layout.alignment: Qt.AlignTop
			}
			Component {
				id: firstItem
				ColumnLayout {
					ColumnLayout {
						Layout.bottomMargin: 60
						Text {
							Layout.fillWidth: true
							Layout.preferredWidth: rootStackView.width
							width: rootStackView.width
							wrapMode: Text.WordWrap
							color: DefaultStyle.darkGrayColor
							font.pointSize: DefaultStyle.defaultTextSize
							text: "<p>Some features require a Linphone account, such as group messaging, video conferences...</p> 
							<p>These features are hidden when you register with a third party SIP account.</p>
							<p>To enable it in a commercial projet, please contact us. </p>"
						}
						Button {
							text: "linphone.org/contact"
							textSize: 8
							inversedColors: true
							leftPadding: 8
							rightPadding: 8
							topPadding: 5
							bottomPadding: 5
							onClicked: {
								Qt.openUrlExternally(ConstantsCpp.ContactUrl)
							}
						}
					}
					ColumnLayout {
						spacing: 10
						Layout.bottomMargin: 20
						Button {
							Layout.fillWidth: true
							inversedColors: true
							text: "I prefer creating an account"
							onClicked: {
								console.debug("[SIPLoginPage] User: click register")
								mainItem.goToRegister()
							}
						}
						Button {
							Layout.fillWidth: true
							text: "I understand"
							onClicked: {
								rootStackView.replace(secondItem)
							}
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
					spacing: 10
					TextInput {
						id: username
						label: "Username"
						mandatory: true
						textInputWidth: 250
					}
					TextInput {
						id: password
						label: "Password"
						mandatory: true
						hidden: true
						textInputWidth: 250
					}
					TextInput {
						id: domain
						label: "Domain"
						mandatory: true
						textInputWidth: 250
					}
					TextInput {
						id: displayName
						label: "Display Name"
						textInputWidth: 250
					}
					ComboBox {
						label: "Transport"
						backgroundWidth: 250
						modelList:[ "TCP", "UDP", "TLS"]
					}

					Text {
						id: errorText
						text: "Connection has failed. Please verify your credentials"
						color: DefaultStyle.errorMessageColor
						opacity: 0
						states: [
							State{
								name: "Visible"
								PropertyChanges{target: errorText; opacity: 1.0}
							},
							State{
								name:"Invisible"
								PropertyChanges{target: errorText; opacity: 0.0}
							}
						]
						transitions: [
							Transition {
								from: "Visible"
								to: "Invisible"
								NumberAnimation {
									property: "opacity"
									duration: 1000
								}
							}
						]
						Timer {
							id: autoHideErrorMessage
							interval: 2500
							onTriggered: errorText.state = "Invisible"
						}
						Connections {
							target: LoginPageCpp
							onRegistrationStateChanged: {
								if (LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Failed) {
									errorText.state = "Visible"
									autoHideErrorMessage.restart()
								} else if (LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Ok) {
									mainItem.connectionSucceed()
								}
							}
						}
					}

					Button {
						Layout.topMargin: 20
						Layout.bottomMargin: 20

						text: "Log in"
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
				Layout.alignment: Qt.AlignBottom
				Layout.rightMargin: 40
				Layout.preferredWidth: 300
				fillMode: Image.PreserveAspectFit
				source: AppIcons.loginImage
			}
		}
		Item {
			Layout.fillHeight: true
		}
	}
}