import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control
import Linphone
import ConstantsCpp 1.0

LoginLayout {

	id: sipLoginPage
	signal returnToLogin()

	titleContent: RowLayout {
		Control.Button {
			background: Rectangle {
				color: "transparent"
			}
			contentItem: Image {
				source: AppIcons.returnArrow
				fillMode: Image.PreserveAspectFit
			}
			onClicked: sipLoginPage.returnToLogin()
		}
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		Text {
			text: "Use a SIP Account"
			color: DefaultStyle.titleColor
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
			color: DefaultStyle.defaultTextColor
			font.pointSize: DefaultStyle.defaultTextSize
		}
		Button {
			Layout.alignment: Qt.AlignRight
			inversedColors: true
			text: "Register"
		}
	}

	centerContent: RowLayout {
		Layout.alignment: Qt.AlignBottom
		ColumnLayout {
			Layout.fillHeight: true
			Layout.fillWidth: true
			clip: true

			Control.StackView {
				id: rootStackView
				initialItem: firstItem
				Layout.fillWidth: true
				Layout.fillHeight: true

				Component {
					id: firstItem
					ColumnLayout {

						Text {
							Layout.preferredWidth: 361
							Layout.fillWidth: true
							wrapMode: Text.WordWrap
							color: DefaultStyle.darkGrayColor
							font.pointSize: DefaultStyle.defaultTextSize
							text: "<p>Some features require a Linphone account, such as group messaging, video conferences...</p> 
							<p>These features are hidden when you register with a third party SIP account.</p>
							<p>To enable it in a commercial projet, please contact us. </p>"
						}

						Button {
							text: 'linphone.org/contact'
							textSize: 8
							inversedColors: true
							onClicked: {
								Qt.openUrlExternally(ConstantsCpp.ContactUrl)
							}
						}
						Item {
							Layout.fillHeight: true
						}

						Button {
							Layout.fillWidth: true
							text: 'I prefere create an account'
							inversedColors: true
							onClicked: {
							}
						}

						Button {
							Layout.fillWidth: true
							Layout.bottomMargin: 40
							text: 'I understand'
							onClicked: {
								rootStackView.replace(secondItem)
							}
						}
					}

				}
				Component {
					id: secondItem
					ColumnLayout {
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
							modelList: ["TCP", "UDP", "TLS"]
						}

						Button {
							Layout.bottomMargin: 20

							text: 'Log in'
							onClicked: {
								LoginPageCpp.login(username.inputText, password.inputText);
							}
						}
						Item {
							Layout.fillHeight: true
						}
					}
				}
			}
		}
		Item {
			Layout.fillWidth: true
		}
		Image {
			Layout.rightMargin: 40
			Layout.preferredWidth: 300
			fillMode: Image.PreserveAspectFit
			source: AppIcons.loginImage
		}
	}
}
 
