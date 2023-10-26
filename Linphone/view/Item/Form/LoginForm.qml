import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone

ColumnLayout {
	id: mainItem
	Layout.alignment: Qt.AlignBottom
	signal useSIPButtonClicked()
	RowLayout {
		ColumnLayout {
			Layout.fillHeight: true
			Layout.fillWidth: true
			clip: true

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

				RowLayout {
					id: lastFormLineLayout
					Button {
						text: 'Log in'
						Layout.rightMargin: 20
						onClicked: {
							LoginPageCpp.login(username.inputText, password.inputText);
						}
					}
					Text {
						color: DefaultStyle.grayColor
						text: "Forgotten password?"
						font.underline: true
						font.pointSize: DefaultStyle.defaultTextSize
					}
				
				}

				Button {
					Layout.topMargin: 40
					inversedColors: true
					text: "Use SIP Account"
					onClicked: {mainItem.useSIPButtonClicked()}
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
	Item {
		Layout.fillHeight: true
	}
}