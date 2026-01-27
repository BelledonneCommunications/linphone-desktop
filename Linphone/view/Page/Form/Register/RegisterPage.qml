import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
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
            spacing: Utils.getSizeWithScreenRatio(21)
            Layout.leftMargin: Utils.getSizeWithScreenRatio(79)
			BigButton {
				style: ButtonStyle.noBackground
				icon.source: AppIcons.leftArrow
				onClicked: {
					console.debug("[RegisterPage] User: return")
					returnToLogin()
				}
				//: Return
				Accessible.name: qsTr("return_accessible_name")
			}
			EffectImage {
				fillMode: Image.PreserveAspectFit
				imageSource: AppIcons.profile
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(34)
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(34)
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
            spacing: Utils.getSizeWithScreenRatio(20)
            Layout.rightMargin: Math.max(Utils.getSizeWithScreenRatio(10), Utils.getSizeWithScreenRatio(51 - ((51/(DefaultStyle.defaultWidth - mainWindow.minimumWidth))*(DefaultStyle.defaultWidth-mainWindow.width))))
			Text {
                Layout.rightMargin: Utils.getSizeWithScreenRatio(15)
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
            anchors.leftMargin: Utils.getSizeWithScreenRatio(127)
            spacing: Utils.getSizeWithScreenRatio(50)

			TabBar {
				Layout.fillWidth: true
				id: bar
    			spacing: Utils.getSizeWithScreenRatio(40)
                Layout.rightMargin: Math.max(Utils.getSizeWithScreenRatio(5), Utils.getSizeWithScreenRatio(127 - ((127/(DefaultStyle.defaultWidth - mainWindow.minimumWidth))*(DefaultStyle.defaultWidth-mainWindow.width))))
                // "S'inscrire avec un numéro de téléphone"
                model: [qsTr("assistant_account_register_with_phone_number"),
                    // "S'inscrire avec un email"
                    qsTr("assistant_account_register_with_email")]
				capitalization: Font.MixedCase
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
					anchors.rightMargin: Utils.getSizeWithScreenRatio(8)
					anchors.right: parent.right
				}

				ColumnLayout {
					id: contentLayout
                    spacing: Utils.getSizeWithScreenRatio(8)
					ColumnLayout {
						id: formLayout
                        spacing: Utils.getSizeWithScreenRatio(24)
						RowLayout {
							FormItemLayout {
								id: usernameItem
                                label: qsTr("username")
								mandatory: true
								enableErrorText: true
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(346)
								contentItem: TextField {
									id: usernameInput
									backgroundBorderColor: usernameItem.errorMessage.length > 0 ? DefaultStyle.danger_500_main : DefaultStyle.grey_200
									//: "%1 mandatory"
									Accessible.name: qsTr("mandatory_field_accessible_name").arg(qsTr("username"))
								}
							}
							RowLayout {
                                spacing: Utils.getSizeWithScreenRatio(10)
								Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
								ComboBox {
                                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(210)
                                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
									enabled: false
									model: [{text:"@sip.linphone.org"}]
									Accessible.name: qsTr("domain")
								}
								EffectImage {
                                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(16)
                                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(16)
									imageSource: AppIcons.lock
									colorizationColor: DefaultStyle.main2_600
								}
							}
						}
						StackLayout {
							currentIndex: bar.currentIndex
							PhoneNumberInput {
								id: phoneNumberInput
								Layout.fillWidth: false
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(390)
								property string completePhoneNumber: countryCode + phoneNumber
                                //: "Numéro de téléphone"
                                label: qsTr("phone_number")
								enableErrorText: true
								mandatory: true
                                placeholderText: qsTr("phone_number")
								defaultCallingCode: "33"
								//: "%1 mandatory"
								Accessible.name: qsTr("mandatory_field_accessible_name").arg(qsTr("phone_number"))
							}
							FormItemLayout {
								id: emailItem
								Layout.fillWidth: false
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(346)
                                label: qsTr("email")
								mandatory: true
								enableErrorText: true
								contentItem: TextField {
									id: emailInput
									backgroundBorderColor: emailItem.errorMessage.length > 0 ? DefaultStyle.danger_500_main : DefaultStyle.grey_200
									//: "%1 mandatory"
									Accessible.name: qsTr("mandatory_field_accessible_name").arg(qsTr("email"))
								}
							}
						}
						ColumnLayout {
							spacing: 0
							Layout.preferredHeight: rowlayout.height
							clip: false
							RowLayout {
								id: rowlayout
                                spacing: Utils.getSizeWithScreenRatio(16)
								FormItemLayout {
									id: passwordItem
                                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(346)
                                    label: qsTr("password")
									mandatory: true
									enableErrorText: true
									contentItem: TextField {
										id: pwdInput
										hidden: true
                                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(346)
										backgroundBorderColor: passwordItem.errorMessage.length > 0 ? DefaultStyle.danger_500_main : DefaultStyle.grey_200
										//: "%1 mandatory"
										Accessible.name: qsTr("mandatory_field_accessible_name").arg(qsTr("password"))
									}
								}
								FormItemLayout {
                                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(346)
									Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
                                    //: "Confirmation mot de passe"
                                    label: qsTr("assistant_account_register_password_confirmation")
									mandatory: true
                                    enableErrorText: false
									contentItem: TextField {
										id: confirmPwdInput
										hidden: true
                                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(346)
										backgroundBorderColor: passwordItem.errorMessage.length > 0 ? DefaultStyle.danger_500_main : DefaultStyle.grey_200
										//: "%1 mandatory"
										Accessible.name: qsTr("mandatory_field_accessible_name").arg(qsTr("assistant_account_register_password_confirmation"))
									}
								}
							}
						}
					}
					TemporaryText {
						id: otherErrorText
						Layout.fillWidth: true
						Layout.preferredHeight: implicitHeight
						// Layout.topMargin: Utils.getSizeWithScreenRatio(5)
					}
					// ColumnLayout {
                    // 	spacing: Utils.getSizeWithScreenRatio(18)
					// 	RowLayout {
                    // 		spacing: Utils.getSizeWithScreenRatio(10)
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
						id: acceptCguAndPrivacyPolicyItem
                        spacing: Utils.getSizeWithScreenRatio(10)
						//: "J'accepte les %1 et la %2"
						property string associatedText: qsTr("assistant_dialog_cgu_and_privacy_policy_message")
                            //: "conditions d'utilisation"
                            .arg(("<a href='%1'><font color='DefaultStyle.main2_600'>%2</font></a>").arg(ConstantsCpp.CguUrl).arg(qsTr("assistant_dialog_general_terms_label")))
                            //: "politique de confidentialité"
                            .arg(("<a href='%1'><font color='DefaultStyle.main2_600'>%2</font></a>").arg(ConstantsCpp.PrivatePolicyUrl).arg(qsTr("assistant_dialog_privacy_policy_label")))
						CheckBox {
							id: termsCheckBox
							Accessible.name: acceptCguAndPrivacyPolicyItem.associatedText
                        }
                        Text {
							id: privacyLinkText
                            text: acceptCguAndPrivacyPolicyItem.associatedText
                            onLinkActivated: (link) => Qt.openUrlExternally(link)
                            font {
                                pixelSize: Typography.p1.pixelSize
                                weight: Typography.p1.weight
                            }
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: (mouse) => {
									mouse.accepted = false
									if (parent.hoveredLink) {
										privacyLinkText.linkActivated(privacyLinkText.linkAt(mouse.x, mouse.y))
									}
									else {
										termsCheckBox.toggle()
									}
								}
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
									RegisterPageCpp.registerNewAccount(usernameInput.text, pwdInput.text, "", phoneNumberInput.countryCode, phoneNumberInput.phoneNumber)
								else
									RegisterPageCpp.registerNewAccount(usernameInput.text, pwdInput.text, emailInput.text)
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
            anchors.topMargin: Utils.getSizeWithScreenRatio(129)
            anchors.rightMargin: Utils.getSizeWithScreenRatio(127)
            width: Utils.getSizeWithScreenRatio(395)
            height: Utils.getSizeWithScreenRatio(350)
			fillMode: Image.PreserveAspectFit
			source: AppIcons.loginImage
		}
	]
}
 
