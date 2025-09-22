import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import ConstantsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

LoginLayout {
	id: mainItem
	signal goBack()
	signal goToRegister()
	property bool showBackButton: false
	
	titleContent: [
		RowLayout {
            Layout.leftMargin: Math.round(119 * DefaultStyle.dp)
			visible: !SettingsCpp.assistantHideThirdPartyAccount
            spacing: Math.round(21 * DefaultStyle.dp)
			Button {
				id: backButton
				visible: mainItem.showBackButton 
                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
				icon.source: AppIcons.leftArrow
				style: ButtonStyle.noBackground
				onClicked: {
					console.debug("[SIPLoginPage] User: return")
					mainItem.goBack()
				}
				//: Return
				Accessible.name: qsTr("return_accessible_name")
			}
			EffectImage {
				fillMode: Image.PreserveAspectFit
				imageSource: AppIcons.profile
                Layout.preferredHeight: Math.round(34 * DefaultStyle.dp)
                Layout.preferredWidth: Math.round(34 * DefaultStyle.dp)
				colorizationColor: DefaultStyle.main2_600
			}
			Text {
                //: Compte SIP tiers
                text: qsTr("assistant_login_third_party_sip_account_title")
				font {
                    pixelSize: Typography.h1.pixelSize
                    weight: Typography.h1.weight
				}
				scaleLettersFactor: 1.1
			}
		},
		Item {
			Layout.fillWidth: true
		},
		RowLayout {
			visible: !SettingsCpp.assistantHideCreateAccount
            Layout.rightMargin: Math.round(51 * DefaultStyle.dp)
            spacing: Math.round(20 * DefaultStyle.dp)
			Text {
                Layout.rightMargin: Math.round(15 * DefaultStyle.dp)
                //: Pas encore de compte ?
                text: qsTr("assistant_no_account_yet")
				font {
                    pixelSize: Typography.p1.pixelSize
                    weight: Typography.p1.weight
				}
			}
			BigButton {
				Layout.alignment: Qt.AlignRight
                //: S'inscrire
                text: qsTr("assistant_account_register")
				style: ButtonStyle.main
				onClicked: {
					console.debug("[SIPLoginPage] User: go to register page")
					mainItem.goToRegister()
				}
			}
		}
	]
	
	Component {
		id: firstItem
		Flickable {
			width: Math.round(361 * DefaultStyle.dp)
			contentWidth: content.implicitWidth
			contentHeight: content.implicitHeight
			clip: true
			flickableDirection: Flickable.VerticalFlick

            Control.ScrollBar.vertical: scrollbar

			ColumnLayout {
                id: content
                // rightMargin is negative margin
                width: parent.width - scrollbar.width*2
                spacing: Math.round(85 * DefaultStyle.dp)
				ColumnLayout {
					spacing: 0
					ColumnLayout {
                        spacing: Math.round(28 * DefaultStyle.dp)
						Text {
							Layout.fillWidth: true
							Layout.preferredWidth: rootStackView.width
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_900
							font {
                                pixelSize: Typography.p1.pixelSize
                                weight: Typography.p1.weight
							}
                            text: qsTr("Certaines fonctionnalités telles que les conversations de groupe, les vidéo-conférences, etc… nécessitent un compte %1.\n\nCes fonctionnalités seront masquées si vous utilisez un compte SIP tiers.\n\nPour les activer dans un projet commercial, merci de nous contacter.").arg(applicationName)
						}
					}
					SmallButton {
						id: openLinkButton
						Layout.alignment: Qt.AlignCenter
                        Layout.topMargin: Math.round(18 * DefaultStyle.dp)
						text: "linphone.org/contact"
						style: ButtonStyle.secondary
						onClicked: {
							Qt.openUrlExternally(ConstantsCpp.ContactUrl)
						}
						KeyNavigation.up: backButton
						KeyNavigation.down: createAccountButton
					}
				}
				ColumnLayout {
                    spacing: Math.round(20 * DefaultStyle.dp)
					BigButton {
						id: createAccountButton
						style: ButtonStyle.secondary
						Layout.fillWidth: true
                        //: "Créer un compte linphone"
                        text: qsTr("assistant_third_party_sip_account_create_linphone_account")
						onClicked: {
							console.debug("[SIPLoginPage] User: click register")
							mainItem.goToRegister()
						}
						KeyNavigation.up: openLinkButton
						KeyNavigation.down: continueButton
					}
					BigButton {
						id: continueButton
						Layout.fillWidth: true
                        //: "Je comprends"
                        text: qsTr("assistant_third_party_sip_account_warning_ok")
						style: ButtonStyle.main
						onClicked: {
							rootStackView.replace(secondItem)
						}
						KeyNavigation.up: createAccountButton
					}
				}
				Item {
					Layout.fillHeight: true
				}
			}
		}
	}
	Component {
		id: secondItem
		Flickable {
            id: formFlickable
			width: Math.round(770 * DefaultStyle.dp)
			contentWidth: content.implicitWidth
			contentHeight: content.implicitHeight
			clip: true
			flickableDirection: Flickable.VerticalFlick

            Control.ScrollBar.vertical: scrollbar

			RowLayout {
				id: content
				width: formFlickable.width - scrollbar.width*2
				spacing: Math.round(50 * DefaultStyle.dp)
				ColumnLayout {
					spacing: Math.round(2 * DefaultStyle.dp)
					Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
					Layout.fillHeight: true
					ColumnLayout {
						spacing: Math.round(22 * DefaultStyle.dp)
						// alignment item
						Item {
							Layout.preferredHeight: advancedParametersTitle.implicitHeight
						}
						ColumnLayout {
							spacing: Math.round(10 * DefaultStyle.dp)
							FormItemLayout {
								id: username
								//: "Nom d'utilisateur"
								label: qsTr("username")
								mandatory: true
								enableErrorText: true
								Layout.fillWidth: true
								contentItem: TextField {
									id: usernameEdit
									isError: username.errorTextVisible || (LoginPageCpp.badIds && errorText.isVisible)
									Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
									KeyNavigation.down: passwordEdit
									//: "%1 mandatory"
									Accessible.name: qsTr("mandatory_field_accessible_name").arg(qsTr("username"))
								}
							}
							FormItemLayout {
								id: password
								label: qsTr("password")
								mandatory: true
								enableErrorText: true
								Layout.fillWidth: true
								contentItem: TextField {
									id: passwordEdit
									isError: password.errorTextVisible || (LoginPageCpp.badIds && errorText.isVisible)
									hidden: true
									Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
									KeyNavigation.up: usernameEdit
									KeyNavigation.down: domainEdit
									Accessible.name: qsTr("password")
								}
							}
							FormItemLayout {
								id: domain
								//: "Domaine"
								label: qsTr("sip_address_domain")
								mandatory: true
								enableErrorText: true
								Layout.fillWidth: true
								contentItem: TextField {
									id: domainEdit
									isError: domain.errorTextVisible
									initialText: SettingsCpp.assistantThirdPartySipAccountDomain
									Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
									KeyNavigation.up: passwordEdit
									KeyNavigation.down: displayName
									//: "%1 mandatory"
									Accessible.name: qsTr("mandatory_field_accessible_name").arg(qsTr("sip_address_domain"))
								}
								Connections {
									target: SettingsCpp
									function onAssistantThirdPartySipAccountDomainChanged() {
										domainEdit.resetText()
									}
								}
							}
							FormItemLayout {
								//: Nom d'affichage
								label: qsTr("sip_address_display_name")
								Layout.fillWidth: true
								contentItem: TextField {
									id: displayName
									Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
									KeyNavigation.up: domainEdit
									KeyNavigation.down: transportCbox
									Accessible.name: qsTr("sip_address_display_name")
								}
							}
							FormItemLayout {
								//: "Transport"
								label: qsTr("transport")
								Layout.fillWidth: true
								contentItem: ComboBox {
									id: transportCbox
									height: Math.round(49 * DefaultStyle.dp)
									width: Math.round(360 * DefaultStyle.dp)
									textRole: "text"
									valueRole: "value"
									model: [
										{text: "TCP", value: LinphoneEnums.TransportType.Tcp},
										{text: "UDP", value: LinphoneEnums.TransportType.Udp},
										{text: "TLS", value: LinphoneEnums.TransportType.Tls},
										{text: "DTLS", value: LinphoneEnums.TransportType.Dtls}
									]
									currentIndex: Utils.findIndex(model, function (entry) {
										return entry.text === SettingsCpp.assistantThirdPartySipAccountTransport.toUpperCase()
									})
									KeyNavigation.up: displayName
									KeyNavigation.down: outboundProxyUriEdit
									Accessible.name: qsTr("transport")
								}
							}
						}
					}

					TemporaryText {
						id: errorText
						Layout.fillWidth: true
						Connections {
							target: LoginPageCpp
							function onErrorMessageChanged(error) {
								errorText.setText(error)
							}
						}
					}

					BigButton {
						id: connectionButton
						Layout.topMargin: Math.round(15 * DefaultStyle.dp)
						style: ButtonStyle.main
						property Item tabTarget
						Accessible.name: qsTr("assistant_account_login")
						contentItem: StackLayout {
							id: connectionButtonContent
							currentIndex: 0
							Text {
								text: qsTr("assistant_account_login")
								horizontalAlignment: Text.AlignHCenter
								verticalAlignment: Text.AlignVCenter

								font {
									pixelSize: Typography.b1.pixelSize
									weight: Typography.b1.weight
								}
								color: DefaultStyle.grey_0
							}
							BusyIndicator {
								implicitWidth: parent.height
								implicitHeight: parent.height
								Layout.alignment: Qt.AlignCenter
								indicatorColor: DefaultStyle.grey_0
								indicatorWidth: Math.round(25 * DefaultStyle.dp)
							}
							Connections {
								target: LoginPageCpp
								function onRegistrationStateChanged() {
									if (LoginPageCpp.registrationState != LinphoneEnums.RegistrationState.Progress) {
										connectionButton.enabled = true
										connectionButtonContent.currentIndex = 0
									}
								}
								function onErrorMessageChanged(error) {
									if (error.length != 0) {
										connectionButton.enabled = true
										connectionButtonContent.currentIndex = 0
									}
								}
							}
						}

						function trigger() {
							username.errorMessage = ""
							password.errorMessage = ""
							domain.errorMessage = ""
							errorText.clear()

							loginDelay.restart()
						}
						onPressed: trigger()
						KeyNavigation.up: connectionId
						KeyNavigation.tab: tabTarget
						Timer{
							id: loginDelay
							interval: 200
							onTriggered: {
								if (usernameEdit.text.length == 0 || passwordEdit.text.length == 0 || domainEdit.text.length == 0) {
									if (usernameEdit.text.length == 0)
										username.errorMessage = qsTr("assistant_account_login_missing_username")
									if (passwordEdit.text.length == 0)
										password.errorMessage = qsTr("assistant_account_login_missing_password")
									if (domainEdit.text.length == 0)
										//: "Veuillez saisir un nom de domaine
										domain.errorMessage = qsTr("assistant_account_login_missing_domain")
									return
								}
								console.debug("[SIPLoginPage] User: Log in")
								LoginPageCpp.login(usernameEdit.text, passwordEdit.text, displayName.text, domainEdit.text, 
								transportCbox.currentValue, serverAddressEdit.text, connectionIdEdit.text);
								connectionButton.enabled = false
								connectionButtonContent.currentIndex = 1
							}
						}
					}
					
					Item {
						Layout.fillHeight: true
					}
				}
				ColumnLayout {
					Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
					Layout.fillHeight: true
					spacing: Math.round(22 * DefaultStyle.dp)
					Text {
						id: advancedParametersTitle
						//: Advanced parameters
						text: qsTr("login_advanced_parameters_label")
						font: Typography.h3m
					}
					ColumnLayout {
						spacing: Math.round(10 * DefaultStyle.dp)
						FormItemLayout {
							id: outboundProxyUri
							//: "Outbound SIP Proxy URI"
							label: qsTr("login_proxy_server_url")
							//: "If this field is filled, the outbound proxy will be enabled automatically. Leave it empty to disable it."
							tooltip: qsTr("login_proxy_server_url_tooltip")
							Layout.fillWidth: true
							contentItem: TextField {
								id: outboundProxyUriEdit
								Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
								Accessible.name: qsTr("login_proxy_server_url")
								KeyNavigation.up: transportCbox
								KeyNavigation.down: registrarUriEdit
							}
						}
						FormItemLayout {
							id: registrarUri
							//: "Registrar URI"
							label: qsTr("login_registrar_uri")
							Layout.fillWidth: true
							contentItem: TextField {
								id: registrarUriEdit
								Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
								Accessible.name: qsTr("login_registrar_uri")
								KeyNavigation.up: outboundProxyUriEdit
								KeyNavigation.down: connectionIdEdit
							}
						}
						FormItemLayout {
							id: connectionId
							//: "Authentication ID (if different)"
							label: qsTr("login_id")
							Layout.fillWidth: true
							contentItem: TextField {
								id: connectionIdEdit
								Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
								KeyNavigation.up: registrarUriEdit
								Accessible.name: qsTr("login_id")
							}
						}
					}
					Item{Layout.fillHeight: true}
				}
				Item{Layout.fillHeight: true}
			}
		}
	}

	centerContent: [
		ScrollBar {
			id: scrollbar
			z: 1
			active: true
			interactive: true
			parent: rootStackView.currentItem
			visible: parent.contentHeight > parent.height
			policy: Control.ScrollBar.AsNeeded
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.right: parent.right
			// Layout.leftMargin: Math.round(119 * DefaultStyle.dp)
			// anchors.leftMargin: Math.round(119 * DefaultStyle.dp)
			// anchors.rightMargin: -8 * DefaultStyle.dp
		},
		Control.StackView {
			id: rootStackView
			initialItem: SettingsCpp.assistantGoDirectlyToThirdPartySipAccountLogin ? secondItem : firstItem
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.leftMargin: Math.round(127 * DefaultStyle.dp)
			width: currentItem ? currentItem.width : 0
		},
        // Item {
		// 	id: sipItem
		// 	// spacing: Math.round(8 * Defaultstyle.dp)
        //     anchors.fill: parent
        //     anchors.rightMargin: Math.round(50 * DefaultStyle.dp) + image.width
        // },
		Image {
			id: image
			z: -1
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
