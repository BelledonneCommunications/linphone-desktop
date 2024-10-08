import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import ConstantsCpp
import SettingsCpp
import 'qrc:/Linphone/view/Control/Tool/Helper/utils.js' as Utils

LoginLayout {
	id: mainItem
	signal goBack()
	signal goToRegister()
	signal connectionSucceed()
	
	titleContent: [
		RowLayout {
			Layout.leftMargin: 119 * DefaultStyle.dp
			visible: !SettingsCpp.assistantHideThirdPartyAccount
			spacing: 21 * DefaultStyle.dp
			Button {
				id: backButton
				Layout.preferredHeight: 24 * DefaultStyle.dp
				Layout.preferredWidth: 24 * DefaultStyle.dp
				icon.source: AppIcons.leftArrow
				icon.width: 24 * DefaultStyle.dp
				icon.height: 24 * DefaultStyle.dp
				background: Item {
					anchors.fill: parent
				}
				onClicked: {
					console.debug("[SIPLoginPage] User: return")
					mainItem.goBack()
				}
			}
			Image {
				fillMode: Image.PreserveAspectFit
				source: AppIcons.profile
				Layout.preferredHeight: 34 * DefaultStyle.dp
				Layout.preferredWidth: 34 * DefaultStyle.dp
				sourceSize.width: 34 * DefaultStyle.dp
				sourceSize.height: 34 * DefaultStyle.dp
			}
			Text {
				text: qsTr("Compte SIP tiers")
				font {
					pixelSize: 36 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
				scaleLettersFactor: 1.1
			}
		},
		Item {
			Layout.fillWidth: true
		},
		RowLayout {
			visible: !SettingsCpp.assistantHideCreateAccount
			Layout.rightMargin: 51 * DefaultStyle.dp
			spacing: 20 * DefaultStyle.dp
			Text {
				Layout.rightMargin: 15 * DefaultStyle.dp
				text: qsTr("Pas encore de compte ?")
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 400 * DefaultStyle.dp
				}
			}
			Button {
				Layout.alignment: Qt.AlignRight
				text: qsTr("S'inscrire")
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
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
			width: contentWidth
			contentWidth: content.implicitWidth
			contentHeight: content.implicitHeight
			clip: true
			flickableDirection: Flickable.VerticalFlick
			ColumnLayout {
				id: content
				spacing: 85 * DefaultStyle.dp
				ColumnLayout {
					spacing: 0
					ColumnLayout {
						spacing: 28 * DefaultStyle.dp
						Text {
							Layout.fillWidth: true
							Layout.preferredWidth: rootStackView.width
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_900
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 400* DefaultStyle.dp
							}
							text: "Certaines fonctionnalités nécessitent un compte Linphone, comme la messagerie de groupe, les vidéoconférences..."
						}
						Text {
							Layout.fillWidth: true
							Layout.preferredWidth: rootStackView.width
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_900
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 400* DefaultStyle.dp
							}
							text:"Ces fonctionnalités sont cachées lorsque vous vous enregistrez avec un compte SIP tiers."
						}
						Text {
							Layout.fillWidth: true
							Layout.preferredWidth: rootStackView.width
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_900
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 400* DefaultStyle.dp
							}
							text: "Pour les activer dans un projet commercial, veuillez nous contacter. "
						}
					}
					Button {
						id: openLinkButton
						Layout.alignment: Qt.AlignCenter
						Layout.topMargin: 18 * DefaultStyle.dp
						text: "linphone.org/contact"
						textSize: 13 * DefaultStyle.dp
						inversedColors: true
						leftPadding: 12 * DefaultStyle.dp
						rightPadding: 12 * DefaultStyle.dp
						topPadding: 6 * DefaultStyle.dp
						bottomPadding: 6 * DefaultStyle.dp
						onClicked: {
							Qt.openUrlExternally(ConstantsCpp.ContactUrl)
						}
						KeyNavigation.up: backButton
						KeyNavigation.down: createAccountButton
					}
				}
				ColumnLayout {
					spacing: 20 * DefaultStyle.dp
					Button {
						id: createAccountButton
						// Layout.topMargin: 85 * DefaultStyle.dp
						Layout.fillWidth: true
						inversedColors: true
						text: qsTr("Créer un compte linphone")
						leftPadding: 20 * DefaultStyle.dp
						rightPadding: 20 * DefaultStyle.dp
						topPadding: 11 * DefaultStyle.dp
						bottomPadding: 11 * DefaultStyle.dp
						onClicked: {
							console.debug("[SIPLoginPage] User: click register")
							mainItem.goToRegister()
						}
						KeyNavigation.up: openLinkButton
						KeyNavigation.down: continueButton
					}
					Button {
						id: continueButton
						Layout.fillWidth: true
						text: qsTr("Je comprends")
						leftPadding: 20 * DefaultStyle.dp
						rightPadding: 20 * DefaultStyle.dp
						topPadding: 11 * DefaultStyle.dp
						bottomPadding: 11 * DefaultStyle.dp
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
			width: contentWidth
			contentWidth: content.implicitWidth
			contentHeight: content.implicitHeight
			clip: true
			flickableDirection: Flickable.VerticalFlick
			ColumnLayout {
				id: content
				spacing: 2 * DefaultStyle.dp
				ColumnLayout {
					spacing: 16 * DefaultStyle.dp
					FormItemLayout {
						id: username
						label: qsTr("Nom d'utilisateur")
						mandatory: true
						enableErrorText: true
						contentItem: TextField {
							id: usernameEdit
							isError: username.errorTextVisible
							Layout.preferredWidth: 360 * DefaultStyle.dp
							KeyNavigation.down: passwordEdit
						}
					}
					FormItemLayout {
						id: password
						label: qsTr("Mot de passe")
						mandatory: true
						enableErrorText: true
						contentItem: TextField {
							id: passwordEdit
							isError: password.errorTextVisible
							hidden: true
							Layout.preferredWidth: 360 * DefaultStyle.dp
							KeyNavigation.up: usernameEdit
							KeyNavigation.down: domainEdit
						}
					}
					FormItemLayout {
						id: domain
						label: qsTr("Domaine")
						mandatory: true
						enableErrorText: true
						contentItem: TextField {
							id: domainEdit
							isError: domain.errorTextVisible
							initialText: SettingsCpp.assistantThirdPartySipAccountDomain
							Layout.preferredWidth: 360 * DefaultStyle.dp
							KeyNavigation.up: passwordEdit
							KeyNavigation.down: displayName
						}
						Connections {
							target: SettingsCpp
							function onAssistantThirdPartySipAccountDomainChanged() {
								domainEdit.resetText()
							}
						}
					}
					FormItemLayout {
						label: qsTr("Nom d'affichage")
						contentItem: TextField {
							id: displayName
							Layout.preferredWidth: 360 * DefaultStyle.dp
							KeyNavigation.up: domainEdit
							KeyNavigation.down: transportCbox
						}
					}
				}
				FormItemLayout {
					label: qsTr("Transport")
					contentItem: ComboBox {
						id: transportCbox
						height: 49 * DefaultStyle.dp
						width: 360 * DefaultStyle.dp
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
					}
				}

				TemporaryText {
					id: errorText
					Connections {
						target: LoginPageCpp
						function onErrorMessageChanged(error) {
							errorText.text = error
						}
						function onRegistrationStateChanged() {
							if (LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Ok) {
								mainItem.connectionSucceed()
							}
						}
					}
				}

				Button {
					id: connectionButton
					Layout.topMargin: 32 * DefaultStyle.dp
					leftPadding: 20 * DefaultStyle.dp
					rightPadding: 20 * DefaultStyle.dp
					topPadding: 11 * DefaultStyle.dp
					bottomPadding: 11 * DefaultStyle.dp
					contentItem: StackLayout {
						id: connectionButtonContent
						currentIndex: 0
						Text {
							text: qsTr("Connexion")
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter

							font {
								pixelSize: 18 * DefaultStyle.dp
								weight: 600 * DefaultStyle.dp
							}
							color: DefaultStyle.grey_0
						}
						BusyIndicator {
							implicitWidth: parent.height
							implicitHeight: parent.height
							Layout.alignment: Qt.AlignCenter
							indicatorColor: DefaultStyle.grey_0
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
						errorText.text = ""

						if (usernameEdit.text.length == 0 || passwordEdit.text.length == 0 || domainEdit.text.length == 0) {
							if (usernameEdit.text.length == 0)
								username.errorMessage = qsTr("Veuillez saisir un nom d'utilisateur")
							if (passwordEdit.text.length == 0)
								password.errorMessage = qsTr("Veuillez saisir un mot de passe")
							if (domainEdit.text.length == 0)
								domain.errorMessage = qsTr("Veuillez saisir un nom de domaine")
							return
						}
						console.debug("[SIPLoginPage] User: Log in")
						LoginPageCpp.login(usernameEdit.text, passwordEdit.text, displayName.text, domainEdit.text, transportCbox.currentValue);
						connectionButton.enabled = false
						connectionButtonContent.currentIndex = 1
					}
					onPressed: trigger()
					KeyNavigation.up: transportCbox
				}
				Item {
					Layout.fillHeight: true
				}
			}
		}
	}

	centerContent: [
		Control.StackView {
			id: rootStackView
			initialItem: SettingsCpp.assistantGoDirectlyToThirdPartySipAccountLogin ? secondItem : firstItem
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			anchors.topMargin: 70 * DefaultStyle.dp
			anchors.leftMargin: 127 * DefaultStyle.dp
			width: 361 * DefaultStyle.dp
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
