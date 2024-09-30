import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0

LoginLayout {
	id: mainItem
	signal returnToLogin()
	signal browserValidationRequested()
	readonly property string countryCode: phoneNumberInput.countryCode
	readonly property string phoneNumber: phoneNumberInput.phoneNumber
	readonly property string email: emailInput.text

	Connections {
		target: RegisterPageCpp
		function onErrorInField(field, errorMessage) {
			if (field == "username") usernameItem.errorMessage = errorMessage
			else if (field == "password") pwdItem.errorMessage = errorMessage
			else if (field == "phone") phoneNumberInput.errorMessage = errorMessage
			else if (field == "email") emailItem.errorMessage = errorMessage
			else otherErrorText.text = errorMessage
		}
		function onRegisterNewAccountFailed(errorMessage) {
			otherErrorText.text = errorMessage
		}
	}

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
							id: usernameItem
							label: qsTr("Username")
							mandatory: true
							contentItem: TextField {
								id: usernameInput
								Layout.preferredWidth: 346 * DefaultStyle.dp
								backgroundBorderColor: usernameItem.errorMessage.length > 0 ? DefaultStyle.danger_500main : DefaultStyle.grey_200
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
							property string completePhoneNumber: countryCode + phoneNumber
							label: qsTr("Numéro de téléphone")
							mandatory: true
							placeholderText: "Phone number"
							defaultCallingCode: "33"
							Layout.preferredWidth: 346 * DefaultStyle.dp
						}
						FormItemLayout {
							id: emailItem
							label: qsTr("Email")
							mandatory: true
							enableErrorText: true
							contentItem: TextField {
								id: emailInput
								Layout.preferredWidth: 346 * DefaultStyle.dp
								backgroundBorderColor: emailItem.errorMessage.length > 0 ? DefaultStyle.danger_500main : DefaultStyle.grey_200
							}
						}
					}
					ColumnLayout {
						spacing: 0
						Layout.preferredHeight: rowlayout.height
						clip: false
						RowLayout {
							id: rowlayout
							spacing: 16 * DefaultStyle.dp
							ColumnLayout {
								spacing: 5 * DefaultStyle.dp
								FormItemLayout {
									id: passwordItem
									label: qsTr("Mot de passe")
									mandatory: true
									enableErrorText: true
									contentItem: TextField {
										id: pwdInput
										hidden: true
										Layout.preferredWidth: 346 * DefaultStyle.dp
										backgroundBorderColor: passwordItem.errorMessage.length > 0 ? DefaultStyle.danger_500main : DefaultStyle.grey_200
									}
								}
							}
							ColumnLayout {
								spacing: 5 * DefaultStyle.dp
								FormItemLayout {
									label: qsTr("Confirmation mot de passe")
									mandatory: true
									enableErrorText: true
									contentItem: TextField {
										id: confirmPwdInput
										hidden: true
										Layout.preferredWidth: 346 * DefaultStyle.dp
										backgroundBorderColor: passwordItem.errorMessage.length > 0 ? DefaultStyle.danger_500main : DefaultStyle.grey_200
									}
								}
							}
						}
						TemporaryText {
							id: otherErrorText
							Layout.fillWidth: true
							Layout.topMargin: 5 * DefaultStyle.dp
						}
					}
				}
				// ColumnLayout {
				// 	spacing: 18 * DefaultStyle.dp
				// 	RowLayout {
				// 		spacing: 10 * DefaultStyle.dp
				// 		CheckBox {
				// 			id: subscribeToNewsletterCheckBox
				// 		}
				// 		Text {
				// 			text: qsTr("Je souhaite souscrire à la newletter Linphone.")
				// 			font {
				// 				pixelSize: 14 * DefaultStyle.dp
				// 				weight: 400 * DefaultStyle.dp
				// 			}
				// 			MouseArea {
				// 				anchors.fill: parent
				// 				onClicked: subscribeToNewsletterCheckBox.toggle()
				// 			}
				// 		}
				// 	}

					RowLayout {
						spacing: 10 * DefaultStyle.dp
						CheckBox {
							id: termsCheckBox
						}
						RowLayout {
							spacing: 0
							Layout.fillWidth: true
							Text {
								text: qsTr("J'accepte les ")
								font {
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
								}
								MouseArea {
									anchors.fill: parent
									onClicked: termsCheckBox.toggle()
								}
							}
							Text {
								activeFocusOnTab: true
								font {
									underline: true
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
									bold: activeFocus
								}
								text: qsTr("conditions d’utilisation")
								Keys.onPressed: (event)=> {
									if (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
										cguMouseArea.clicked(undefined)
										event.accepted = true;
									}
								}
								MouseArea {
									id: cguMouseArea
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
									onClicked: Qt.openUrlExternally(ConstantsCpp.CguUrl)
								}
							}
							Text {
								text: qsTr(" et la ")
								font {
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
								}
							}
							Text {
								activeFocusOnTab: true
								font {
									underline: true
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
									bold: activeFocus
								}
								text: qsTr("politique de confidentialité.")
								Keys.onPressed: (event)=> {
									if (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
										privateMouseArea.clicked(undefined)
										event.accepted = true;
									}
								}
								MouseArea {
									id: privateMouseArea
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
									onClicked: Qt.openUrlExternally(ConstantsCpp.PrivatePolicyUrl)
								}
							}
						}
					}
				// }
				Button {
					enabled: termsCheckBox.checked
					leftPadding: 20 * DefaultStyle.dp
					rightPadding: 20 * DefaultStyle.dp
					topPadding: 11 * DefaultStyle.dp
					bottomPadding: 11 * DefaultStyle.dp
					text: qsTr("Créer")
					onClicked:{
						if (usernameInput.text.length === 0) {
							console.log("ERROR username")
							usernameItem.errorMessage = qsTr("Veuillez entrer un nom d'utilisateur")
						} else if (pwdInput.text.length === 0) {
							console.log("ERROR password")
							passwordItem.errorMessage = qsTr("Veuillez entrer un mot de passe")
						} else if (pwdInput.text != confirmPwdInput.text) {
							console.log("ERROR confirm pwd")
							passwordItem.errorMessage = qsTr("Les mots de passe sont différents")
						} else if (bar.currentIndex === 0 && phoneNumberInput.phoneNumber.length === 0) {
							console.log("ERROR phone number")
							phoneNumberInput.errorMessage = qsTr("Veuillez entrer un numéro de téléphone")
						} else if (bar.currentIndex === 1 && emailInput.text.length === 0) {
							console.log("ERROR email")
							emailItem.errorMessage = qsTr("Veuillez entrer un email")
						} else {
							console.log("[RegisterPage] User: Call register")
							mainItem.browserValidationRequested()
							if (bar.currentIndex === 0)
								RegisterPageCpp.registerNewAccount(usernameInput.text, pwdInput.text, "", phoneNumberInput.completePhoneNumber)
							else
								RegisterPageCpp.registerNewAccount(usernameInput.text, pwdInput.text, emailInput.text, "")
						}
					}
				}
			}
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
 
