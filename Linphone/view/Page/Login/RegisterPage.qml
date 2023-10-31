import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: mainItem
	signal returnToLogin()
	signal registerCalled(countryCode: string, phoneNumber: string, email: string)
	readonly property string countryCode: phoneNumberInput.countryCode
	readonly property string phoneNumber: phoneNumberInput.phoneNumber
	readonly property string email: emailInput.inputText

	titleContent: RowLayout {
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		Text {
			Layout.preferredWidth: width
			text: "Register"
			font.pointSize: DefaultStyle.title2FontPointSize
			font.bold: true
			wrapMode: Text.NoWrap
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
		Text {
			Layout.rightMargin: 15
			color: DefaultStyle.questionTextColor
			text: "Already have an account ?"
			font.pointSize: DefaultStyle.defaultTextSize
		}
		Button {
			// Layout.alignment: Qt.AlignRight
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
					spacing: 15
					RowLayout {
						TextInput {
							label: "Username"
							mandatory: true
							textInputWidth: 250
						}
						ComboBox {
							label: " "
							enabled: false
							modelList: [{text:"@sip.linphone.org"}]
						}
					}
					PhoneNumberInput {
						id: phoneNumberInput
						label: "Phone number"
						mandatory: true
						placeholderText: "Phone number"
						textInputWidth: 250
					}
					RowLayout {
						ColumnLayout {
							TextInput {
								label: "Password"
								mandatory: true
								hidden: true
								textInputWidth: 250
							}
							Text {
								text: "The password must contain 6 characters minimum"
								font {
									pointSize: DefaultStyle.defaultTextSize
								}
							}
						}
						ColumnLayout {
							TextInput {
								label: "Confirm password"
								mandatory: true
								hidden: true
								textInputWidth: 250
							}
							Text {
								text: "The password must contain 6 characters minimum"
								font {
									pointSize: DefaultStyle.defaultTextSize
								}
							}
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							text: "I would like to suscribe to the newsletter"
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							Layout.preferredWidth: 450
							text: "I accept the Terms and Conditions : Read the Terms and Conditions. <br>I accept the Privacy policy : Read the Privacy policy."
						}
					}
					Button {
						text: "Register"
						onClicked:{
							console.log("[RegisterPage] User: Call register with phone number", phoneNumberInput.phoneNumber)
							mainItem.registerCalled(phoneNumberInput.countryCode, phoneNumberInput.phoneNumber, "")
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
					spacing: 15
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
							enabled: false
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
						ColumnLayout {
							TextInput {
								id: pwdInput
								label: "Password"
								mandatory: true
								hidden: true
								textInputWidth: 250
							}
							Text {
								text: "The password must contain 6 characters minimum"
								font {
									pointSize: DefaultStyle.defaultTextSize
								}
							}
						}
						ColumnLayout {
							TextInput {
								id: confirmPwdInput
								label: "Confirm password"
								mandatory: true
								hidden: true
								textInputWidth: 250
							}
							Text {
								text: "The password must contain 6 characters minimum"
								font {
									pointSize: DefaultStyle.defaultTextSize
								}
							}
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							text: "I would like to suscribe to the newsletter"
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							Layout.preferredWidth: 450
							text: "I accept the Terms and Conditions : Read the Terms and Conditions. <br>I accept the Privacy policy : Read the Privacy policy."
						}
					}
					Button {
						text: "Register"
						onClicked:{
							console.log("[RegisterPage] User: Call register with email", emailInput.inputText)
							if (emailInput.inputText.length == 0) {
								emailInput.errorMessage = "You must enter an email"
								return
							}
							mainItem.registerCalled("", "", emailInput.inputText)
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
 
