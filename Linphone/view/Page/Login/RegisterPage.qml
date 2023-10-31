import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: mainItem
	signal returnToLogin()
	signal registerCalled()
	readonly property string countryCode: phoneNumberInput.countryCode
	readonly property string phoneNumber: phoneNumberInput.phoneNumber
	readonly property string email: emailInput.inputText

	titleContent: RowLayout {
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		Text {
			textItem.text: "Register"
			textItem.font.pointSize: DefaultStyle.title2FontPointSize
			textItem.font.bold: true
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
		Text {
			Layout.rightMargin: 15
			textItem.text: "Already have an account ?"
			textItem.font.pointSize: DefaultStyle.defaultTextSize
		}
		Button {
			Layout.alignment: Qt.AlignRight
			inversedColors: true
			text: "Log in"
			onClicked: {
				console.debug("[LoginItem] User: return")
				returnToLogin()
			}
		}
	}

	centerContent: ColumnLayout {
		TabBar {
			Layout.fillWidth: true
			id: bar
			model: [qsTr("Register with phone number"), qsTr("Register with email")]
		}
		StackLayout {
			currentIndex: bar.currentIndex
			RowLayout {
				ColumnLayout {
					Layout.fillWidth: true
					Layout.fillHeight: true
					RowLayout {
						TextInput {
							label: "Username"
							mandatory: true
							textInputWidth: 250
						}
						ComboBox {
							label: " "
							modelList: [{text:"@sip.linphone.org"}]
						}
					}
					PhoneNumberInput {
						id: phoneNumberInput
						label: "Phone number"
						mandatory: true
						defaultText: "Phone number"
						textInputWidth: 250
					}
					RowLayout {
						TextInput {
							label: "Password"
							mandatory: true
							hidden: true
							textInputWidth: 250
						}
						TextInput {
							label: "Confirm password"
							mandatory: true
							hidden: true
							textInputWidth: 250
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							textItem.text: "I would like to suscribe to the newsletter"
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							textItem.text: "I accept the Terms and Conditions : Read the Terms and Conditions. <br>I accept the Privacy policy : Read the Privacy policy."
						}
					}
					Button {
						text: "Register"
						onClicked:{
							console.log("[RegisterPage] User: Call register")
							mainItem.registerCalled()
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
			RowLayout {
				ColumnLayout {
					Layout.fillWidth: true
					Layout.fillHeight: true
					RowLayout {
						TextInput {
							label: "Username"
							mandatory: true
							textInputWidth: 250
						}
						ComboBox {
							// if we don't set a label this item is offset
							// due to the invisibility of the upper label
							label: " "
							modelList: [{text:"@sip.linphone.org"}]
						}
					}
					TextInput {
						id: emailInput
						label: "Email"
						mandatory: true
						textInputWidth: 250
					}
					RowLayout {
						TextInput {
							label: "Password"
							mandatory: true
							hidden: true
							textInputWidth: 250
						}
						TextInput {
							label: "Confirm password"
							mandatory: true
							hidden: true
							textInputWidth: 250
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							textItem.text: "I would like to suscribe to the newsletter"
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							textItem.text: "I accept the Terms and Conditions : Read the Terms and Conditions. <br>I accept the Privacy policy : Read the Privacy policy."
						}
					}
					Button {
						text: "Register"
						onClicked:{
							console.log("[RegisterPage] User: Call register")
							mainItem.registerCalled()
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
	}
}
 
