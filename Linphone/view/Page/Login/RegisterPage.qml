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
	readonly property string email: emailInput.text

	titleContent: [
		RowLayout {
			spacing: 21 * DefaultStyle.dp
			Layout.leftMargin: 119 * DefaultStyle.dp
			Image {
				fillMode: Image.PreserveAspectFit
				source: AppIcons.profile
			}
			Text {
				Layout.preferredWidth: width
				text: qsTr("Inscription")
				font {
					pixelSize: 36 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
				wrapMode: Text.NoWrap
				scaleLettersFactor: 1.1
			}
		},
		Item {
			Layout.fillWidth: true
		},
		RowLayout {
			spacing: 20 * DefaultStyle.dp
			Layout.rightMargin: 51 * DefaultStyle.dp
			Text {
				Layout.rightMargin: 15 * DefaultStyle.dp
				color: DefaultStyle.main2_700
				text: qsTr("Déjà un compte ?")
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 400 * DefaultStyle.dp
				}
			}
			Button {
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				text: qsTr("Connexion")
				onClicked: {
					console.debug("[RegisterPage] User: return")
					returnToLogin()
				}
			}
		}
	]

	centerContent: [
		ColumnLayout {
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.topMargin: 51 * DefaultStyle.dp
			anchors.leftMargin: 127 * DefaultStyle.dp
			anchors.rightMargin: 127 * DefaultStyle.dp
			spacing: 50 * DefaultStyle.dp
			TabBar {
				Layout.fillWidth: true
				id: bar
				model: [qsTr("Register with phone number"), qsTr("Register with email")]
			}
			ColumnLayout {
				spacing: 22 * DefaultStyle.dp
				ColumnLayout {
					spacing: 24 * DefaultStyle.dp
					RowLayout {
						spacing: 16 * DefaultStyle.dp
						FormItemLayout {
							label: qsTr("Username")
							mandatory: true
							contentItem: TextField {
								id: usernameInput
								Layout.preferredWidth: 346 * DefaultStyle.dp
							}
						}
						RowLayout {
							spacing: 10 * DefaultStyle.dp
							Layout.alignment: Qt.AlignBottom
							ComboBox {
								enabled: false
								model: [{text:"@sip.linphone.org"}]
								Layout.preferredWidth: 210 * DefaultStyle.dp
								Layout.preferredHeight: 49 * DefaultStyle.dp
							}
							EffectImage {
								imageSource: AppIcons.lock
								colorizationColor: DefaultStyle.main2_600
								Layout.preferredWidth: 16 * DefaultStyle.dp
								Layout.preferredHeight: 16 * DefaultStyle.dp
							}
						}
					}
					StackLayout {
						currentIndex: bar.currentIndex
						Layout.fillWidth: true
						PhoneNumberInput {
							id: phoneNumberInput
							label: qsTr("Phone number")
							mandatory: true
							placeholderText: "Phone number"
							Layout.preferredWidth: 346 * DefaultStyle.dp
						}
						FormItemLayout {
							label: qsTr("Email")
							mandatory: true
							contentItem: TextField {
								id: emailInput
								Layout.preferredWidth: 346 * DefaultStyle.dp
							}
						}
					}
					RowLayout {
						spacing: 16 * DefaultStyle.dp
						ColumnLayout {
							spacing: 5 * DefaultStyle.dp
							FormItemLayout {
								label: qsTr("Password")
								mandatory: true
								contentItem: TextField {
									id: pwdInput
									hidden: true
									Layout.preferredWidth: 346 * DefaultStyle.dp
								}
							}
							Text {
								text: qsTr("The password must contain 6 characters minimum")
								font {
									pixelSize: 12 * DefaultStyle.dp
									weight: 300 * DefaultStyle.dp
								}
							}
						}
						ColumnLayout {
							spacing: 5 * DefaultStyle.dp
							FormItemLayout {
								label: qsTr("Confirm password")
								mandatory: true
								contentItem: TextField {
									id: confirmPwdInput
									hidden: true
									Layout.preferredWidth: 346 * DefaultStyle.dp
								}
							}
							Text {
								text: qsTr("The password must contain 6 characters minimum")
								font {
									pixelSize: 12 * DefaultStyle.dp
									weight: 300 * DefaultStyle.dp
								}
							}
						}
					}
				}
				ColumnLayout {
					spacing: 18 * DefaultStyle.dp
					RowLayout {
						CheckBox {
						}
						Text {
							text: qsTr("I would like to suscribe to the newsletter")
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 400 * DefaultStyle.dp
							}
						}
					}
					RowLayout {
						CheckBox {
							id: termsCheckBox
						}
						RowLayout {
							spacing: 0
							Layout.fillWidth: true
							Text {
								// Layout.preferredWidth: 450 * DefaultStyle.dp
								text: qsTr("I accept the Terms and Conditions: ")
								font {
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
								}
							}
							Text {
								// Layout.preferredWidth: 450 * DefaultStyle.dp
								font {
									underline: true
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
								}
								text: qsTr("Read the Terms and Conditions.")
								MouseArea {
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
									onClicked: console.log("TODO : display terms and conditions")
								}
							}
							Text {
								// Layout.preferredWidth: 450 * DefaultStyle.dp
								text: qsTr("I accept the Privacy policy: ")
								font {
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
								}
							}
							Text {
								// Layout.preferredWidth: 450 * DefaultStyle.dp
								font {
									underline: true
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
								}
								text: qsTr("Read the Privacy policy.")
								MouseArea {
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
									onClicked: console.log("TODO : display privacy policy")
								}
							}
						}
					}
				}
				Button {
					// enabled: termsCheckBox.checked && usernameInput.text.length != 0 && pwdInput.text.length != 0 && confirmPwdInput.text.length != 0
					// && (phoneNumberInput.phoneNumber.length != 0 || emailInput.text.length != 0)
					leftPadding: 20 * DefaultStyle.dp
					rightPadding: 20 * DefaultStyle.dp
					topPadding: 11 * DefaultStyle.dp
					bottomPadding: 11 * DefaultStyle.dp
					text: qsTr("Register")
					onClicked:{
						console.log("[RegisterPage] User: Call register with phone number", phoneNumberInput.phoneNumber)
						mainItem.registerCalled(phoneNumberInput.countryCode, phoneNumberInput.phoneNumber, emailInput.text)
					}
				}
			}
		},
		Image {
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
 
