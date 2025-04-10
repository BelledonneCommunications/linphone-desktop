import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

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
			console.log("set error message", errorMessage)
			if (field == "username") usernameItem.errorMessage = errorMessage
			else if (field == "password") passwordItem.errorMessage = errorMessage
			else if (field == "phone") phoneNumberInput.errorMessage = errorMessage
			else if (field == "email") emailItem.errorMessage = errorMessage
			else otherErrorText.setText(errorMessage)
		}
		function onRegisterNewAccountFailed(errorMessage) {
			console.log("register failed", errorMessage)
			otherErrorText.setText(errorMessage)
		}
	}

	titleContent: [
		RowLayout {
            spacing: Math.round(21 * DefaultStyle.dp)
            Layout.leftMargin: Math.round(79 * DefaultStyle.dp)
			BigButton {
				style: ButtonStyle.noBackground
				icon.source: AppIcons.leftArrow
				onClicked: {
					console.debug("[RegisterPage] User: return")
					returnToLogin()
				}
			}
			EffectImage {
				fillMode: Image.PreserveAspectFit
				imageSource: AppIcons.profile
                Layout.preferredHeight: Math.round(34 * DefaultStyle.dp)
                Layout.preferredWidth: Math.round(34 * DefaultStyle.dp)
				colorizationColor: DefaultStyle.main2_600
			}
			Text {
				Layout.preferredWidth: width
                //: "Inscription
                text: qsTr("assistant_account_register")
				font {
                    pixelSize: Typography.h1.pixelSize
                    weight: Typography.h1.weight
				}
				wrapMode: Text.NoWrap
				scaleLettersFactor: 1.1
			}
		},
		Item {
			Layout.fillWidth: true
		},
		RowLayout {
            spacing: Math.round(20 * DefaultStyle.dp)
            Layout.rightMargin: Math.round(Math.max(10 * DefaultStyle.dp,(51 - ((51/(DefaultStyle.defaultWidth - mainWindow.minimumWidth))*(DefaultStyle.defaultWidth-mainWindow.width))) * DefaultStyle.dp))
			Text {
                Layout.rightMargin: Math.round(15 * DefaultStyle.dp)
				color: DefaultStyle.main2_700
                // "Déjà un compte ?"
                text: qsTr("assistant_already_have_an_account")
				font {
                    pixelSize: Typography.p1.pixelSize
                    weight: Typography.p1.weight
				}
			}
			BigButton {
				style: ButtonStyle.main
                text: qsTr("assistant_account_login")
				onClicked: {
					console.debug("[RegisterPage] User: return")
					returnToLogin()
				}
			}
		}
	]

	centerContent: [
		ColumnLayout {
            id: registerForm
			anchors.fill: parent
            anchors.leftMargin: Math.round(127 * DefaultStyle.dp)
            spacing: Math.round(50 * DefaultStyle.dp)

			TabBar {
				Layout.fillWidth: true
				id: bar
                Layout.rightMargin: Math.round(Math.max(5 * DefaultStyle.dp,(127 - ((127/(DefaultStyle.defaultWidth - mainWindow.minimumWidth))*(DefaultStyle.defaultWidth-mainWindow.width))) * DefaultStyle.dp))
                // "S'inscrire avec un numéro de téléphone"
                model: [qsTr("assistant_account_register_with_phone_number"),
                    // "S'inscrire avec un email"
                    qsTr("assistant_account_register_with_email")]
			}
			Flickable {
				Layout.fillWidth: true
				Layout.fillHeight: true

				contentHeight: contentLayout.height

				Control.ScrollBar.vertical: ScrollBar {
					id: scrollbar
					z: 1
					active: true
					interactive: true
					visible: parent.contentHeight > parent.height
					policy: Control.ScrollBar.AsNeeded
					anchors.rightMargin: 8 * DefaultStyle.dp
					anchors.right: parent.right
				}

				ColumnLayout {
					id: contentLayout
					anchors.left: parent.left
					anchors.right: parent.right
                    spacing: Math.round(8 * DefaultStyle.dp)
					ColumnLayout {
						id: formLayout
                        spacing: Math.round(24 * DefaultStyle.dp)
						RowLayout {
							Layout.preferredHeight: usernameItem.height
                            spacing: Math.round(16 * DefaultStyle.dp)
							FormItemLayout {
								id: usernameItem
                                label: qsTr("username")
								mandatory: true
								enableErrorText: true
                                Layout.preferredWidth: Math.round(346 * DefaultStyle.dp)
								contentItem: TextField {
									id: usernameInput
									backgroundBorderColor: usernameItem.errorMessage.length > 0 ? DefaultStyle.danger_500main : DefaultStyle.grey_200
								}
							}
							RowLayout {
                                spacing: Math.round(10 * DefaultStyle.dp)
								ComboBox {
                                    Layout.preferredWidth: Math.round(210 * DefaultStyle.dp)
                                    Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
									enabled: false
									model: [{text:"@sip.linphone.org"}]
								}
								EffectImage {
                                    Layout.preferredWidth: Math.round(16 * DefaultStyle.dp)
                                    Layout.preferredHeight: Math.round(16 * DefaultStyle.dp)
									imageSource: AppIcons.lock
									colorizationColor: DefaultStyle.main2_600
								}
							}
						}
						StackLayout {
							currentIndex: bar.currentIndex
							PhoneNumberInput {
								id: phoneNumberInput
                                Layout.preferredWidth: Math.round(346 * DefaultStyle.dp)
								property string completePhoneNumber: countryCode + phoneNumber
                                //: "Numéro de téléphone"
                                label: qsTr("phone_number")
								enableErrorText: true
								mandatory: true
                                placeholderText: qsTr("phone_number")
								defaultCallingCode: "33"
							}
							FormItemLayout {
								id: emailItem
								Layout.fillWidth: false
                                Layout.preferredWidth: Math.round(346 * DefaultStyle.dp)
                                label: qsTr("email")
								mandatory: true
								enableErrorText: true
								contentItem: TextField {
									id: emailInput
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
                                spacing: Math.round(16 * DefaultStyle.dp)
								FormItemLayout {
									id: passwordItem
                                    Layout.preferredWidth: Math.round(346 * DefaultStyle.dp)
                                    label: qsTr("password")
									mandatory: true
									enableErrorText: true
									contentItem: TextField {
										id: pwdInput
										hidden: true
                                        Layout.preferredWidth: Math.round(346 * DefaultStyle.dp)
										backgroundBorderColor: passwordItem.errorMessage.length > 0 ? DefaultStyle.danger_500main : DefaultStyle.grey_200
									}
								}
								FormItemLayout {
                                    Layout.preferredWidth: Math.round(346 * DefaultStyle.dp)
                                    //: "Confirmation mot de passe"
                                    label: qsTr("assistant_account_register_password_confirmation")
									mandatory: true
                                    enableErrorText: false
									contentItem: TextField {
										id: confirmPwdInput
										hidden: true
                                        Layout.preferredWidth: Math.round(346 * DefaultStyle.dp)
										backgroundBorderColor: passwordItem.errorMessage.length > 0 ? DefaultStyle.danger_500main : DefaultStyle.grey_200
									}
								}
							}
							TemporaryText {
								id: otherErrorText
								Layout.fillWidth: true
                                Layout.topMargin: Math.round(5 * DefaultStyle.dp)
							}
						}
					}
					// ColumnLayout {
                    // 	spacing: Math.round(18 * DefaultStyle.dp)
					// 	RowLayout {
                    // 		spacing: Math.round(10 * DefaultStyle.dp)
					// 		CheckBox {
					// 			id: subscribeToNewsletterCheckBox
					// 		}
					// 		Text {
					// 			text: qsTr("Je souhaite souscrire à la newletter Linphone.")
					// 			font {
                    // 				pixelSize: Typography.p1.pixelSize
                    // 				weight: Typography.p1.weight
					// 			}
					// 			MouseArea {
					// 				anchors.fill: parent
					// 				onClicked: subscribeToNewsletterCheckBox.toggle()
					// 			}
					// 		}
					// 	}

					RowLayout {
                        spacing: Math.round(10 * DefaultStyle.dp)
						CheckBox {
							id: termsCheckBox
                        }
                        Text {
                            //: "J'accepte les %1 et la %2"
                            text: qsTr("assistant_dialog_cgu_and_privacy_policy_message")
                            //: "conditions d'utilisation"
                            .arg(("<a href='%1'><font color='DefaultStyle.main2_600'>%2</font></a>").arg(ConstantsCpp.CguUrl).arg(qsTr("assistant_dialog_general_terms_label")))
                            //: "politique de confidentialité"
                            .arg(("<a href='%1'><font color='DefaultStyle.main2_600'>%2</font></a>").arg(ConstantsCpp.PrivatePolicyUrl).arg(qsTr("assistant_dialog_privacy_policy_label")))
                            onLinkActivated: (link) => Qt.openUrlExternally(link)
                            font {
                                pixelSize: Typography.p1.pixelSize
                                weight: Typography.p1.weight
                            }
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: termsCheckBox.toggle()
                            }
                        }
                    }
                    // }
					Button {
						enabled: termsCheckBox.checked
						style: ButtonStyle.main
                        //: "Créer"
                        text: qsTr("assistant_account_create")
						onClicked:{
							if (usernameInput.text.length === 0) {
								console.log("ERROR username")
                                //: "Veuillez entrer un nom d'utilisateur"
                                usernameItem.errorMessage = qsTr("assistant_account_create_missing_username_error")
							} else if (pwdInput.text.length === 0) {
								console.log("ERROR password")
                                //: "Veuillez entrer un mot de passe"
                                passwordItem.errorMessage = qsTr("assistant_account_create_missing_password_error")
							} else if (pwdInput.text != confirmPwdInput.text) {
								console.log("ERROR confirm pwd")
                                //: "Les mots de passe sont différents"
                                passwordItem.errorMessage = qsTr("assistant_account_create_confirm_password_error")
							} else if (bar.currentIndex === 0 && phoneNumberInput.phoneNumber.length === 0) {
								console.log("ERROR phone number")
                                //: "Veuillez entrer un numéro de téléphone"
                                phoneNumberInput.errorMessage = qsTr("assistant_account_create_missing_number_error")
							} else if (bar.currentIndex === 1 && emailInput.text.length === 0) {
								console.log("ERROR email")
                                //: "Veuillez entrer un email"
                                emailItem.errorMessage = qsTr("assistant_account_create_missing_email_error")
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
			}
		},
		Image {
			z: -1
//            visible: registerForm.x+registerForm.width < x
			anchors.top: parent.top
			anchors.right: parent.right
            anchors.topMargin: Math.round(129 * DefaultStyle.dp)
            anchors.rightMargin: Math.round(127 * DefaultStyle.dp)
            width: Math.round(395 * DefaultStyle.dp)
            height: Math.round(350 * DefaultStyle.dp)
			fillMode: Image.PreserveAspectFit
			source: AppIcons.loginImage
		}
	]
}
 
