import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import EnumsToStringCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

AbstractMainPage {
	id: mainItem
	noItemButtonText: qsTr("Ajouter un contact")
	emptyListText: qsTr("Aucun contact pour le moment")
	newItemIconSource: AppIcons.plusCircle

	// disable left panel contact list interaction while a contact is being edited
	property bool leftPanelEnabled: !rightPanelStackView.currentItem || rightPanelStackView.currentItem.objectName != "contactEdition"
	property FriendGui selectedContact
	property string initialFriendToDisplay
	onInitialFriendToDisplayChanged: if (initialFriendToDisplay != '' && contactList.selectContact(initialFriendToDisplay) != -1) initialFriendToDisplay = ""

	onVisibleChanged: if (!visible) {
		rightPanelStackView.clear()
		contactList.resetSelections()
	}

	onSelectedContactChanged: {
		if (selectedContact) {
			if (!rightPanelStackView.currentItem || rightPanelStackView.currentItem.objectName != "contactDetail") rightPanelStackView.push(contactDetail)
		} else {
			if (rightPanelStackView.currentItem && rightPanelStackView.currentItem.objectName === "contactDetail") rightPanelStackView.clear()
		}
	}

	onNoItemButtonPressed: createContact("", "")

	function createContact(name, address) {
		var friendGui = Qt.createQmlObject('import Linphone
											FriendGui{
											}', mainItem)
		friendGui.core.givenName = UtilsCpp.getGivenNameFromFullName(name)
		friendGui.core.familyName = UtilsCpp.getFamilyNameFromFullName(name)
		friendGui.core.defaultAddress = address
		friendGui.core.defaultFullAddress = address
		if (!rightPanelStackView.currentItem || rightPanelStackView.currentItem.objectName != "contactEdition")
			rightPanelStackView.push(contactEdition, {"contact": friendGui, "title": qsTr("Nouveau contact"), "saveButtonText": qsTr("Créer")})
	}

	function editContact(friendGui) {
		rightPanelStackView.push(contactEdition, {"contact": friendGui, "title": qsTr("Modifier contact"), "saveButtonText": qsTr("Enregistrer")})
	}

	// rightPanelStackView.initialItem: contactDetail
	
	showDefaultItem: rightPanelStackView.depth == 0 && !contactList.haveContacts && searchBar.text.length === 0
	
	function deleteContact(contact) {
		if (!contact) return
		var mainWin = UtilsCpp.getMainWindow()
		mainWin.showConfirmationLambdaPopup("",
            qsTr("%1 sera supprimé des contacts. Voulez-vous continuer ?").arg(contact.core.fullName),
			"",
			function (confirmed) {
				if (confirmed) {
					var name = contact.core.fullName
					contact.core.remove()
					contactList.resetSelections()
					UtilsCpp.showInformationPopup(qsTr("Supprimé"), qsTr("%1 a été supprimé").arg(name))				}
			}
		)
	}

	Dialog {
		id: verifyDevicePopup
		property string deviceName
		property string deviceAddress
		padding: 30 * DefaultStyle.dp
		width: 637 * DefaultStyle.dp
		anchors.centerIn: parent
		closePolicy: Control.Popup.CloseOnEscape
		modal: true
		onAboutToHide: neverDisplayAgainCheckbox.checked = false
		title: qsTr("Augmenter la confiance")
		text: qsTr("Pour augmenter le niveau de confiance vous devez appeler les différents appareils de votre contact et valider un code.<br><br>Vous êtes sur le point d’appeler “%1” voulez vous continuer ?").arg(verifyDevicePopup.deviceName)
		buttons: RowLayout {
			RowLayout {
				spacing: 7 * DefaultStyle.dp
				CheckBox{
					id: neverDisplayAgainCheckbox
				}
				Text {
					text: qsTr("Ne plus afficher")
					font.pixelSize: 14 * DefaultStyle.dp
					MouseArea {
						anchors.fill: parent
						onClicked: neverDisplayAgainCheckbox.toggle()
					}
				}
			}
			Item{Layout.fillWidth: true}
			RowLayout {
				spacing: 15 * DefaultStyle.dp
				BigButton {
					style: ButtonStyle.secondary
					text: qsTr("Annuler")
					onClicked: verifyDevicePopup.close()
				}
				BigButton {
					style: ButtonStyle.main
					text: qsTr("Appeler")
					onClicked: {
						SettingsCpp.setDisplayDeviceCheckConfirmation(!neverDisplayAgainCheckbox.checked)
						UtilsCpp.createCall(verifyDevicePopup.deviceAddress, {}, LinphoneEnums.MediaEncryption.Zrtp)
						onClicked: verifyDevicePopup.close()
					}
				}
			}
		}
	}
	Dialog {
		id: trustInfoDialog
		width: 637 * DefaultStyle.dp
		title: qsTr("Niveau de confiance")
		text: qsTr("Vérifiez les appareils de votre contact pour confirmer que vos communications seront sécurisées et sans compromission. <br>Quand tous seront vérifiés, vous atteindrez le niveau de confiance maximal.")
		content: RowLayout {
			spacing: 50 * DefaultStyle.dp
			Avatar {
				_address: "sip:a.c@sip.linphone.org"
				Layout.preferredWidth: 45 * DefaultStyle.dp
				Layout.preferredHeight: 45 * DefaultStyle.dp
			}
			EffectImage {
				imageSource: AppIcons.arrowRight
				colorizationColor: DefaultStyle.main2_600
				Layout.preferredWidth: 45 * DefaultStyle.dp
				Layout.preferredHeight: 45 * DefaultStyle.dp
			}
			Avatar {
				_address: "sip:a.c@sip.linphone.org"
				secured: true
				Layout.preferredWidth: 45 * DefaultStyle.dp
				Layout.preferredHeight: 45 * DefaultStyle.dp
			}
		}
		buttons: Button {
			text: qsTr("Ok")
			style: ButtonStyle.main
			leftPadding: 30 * DefaultStyle.dp
			rightPadding: 30 * DefaultStyle.dp
			onClicked: trustInfoDialog.close()
		}
	}

	leftPanelContent: FocusScope {
		id: leftPanel
		property int leftMargin: 45 * DefaultStyle.dp
		property int rightMargin: 39 * DefaultStyle.dp
		Layout.fillHeight: true
		Layout.fillWidth: true

		RowLayout {
			id: title
			spacing: 0
			anchors.top: leftPanel.top
			anchors.right: leftPanel.right
			anchors.left: leftPanel.left
			anchors.leftMargin: leftPanel.leftMargin
			anchors.rightMargin: leftPanel.rightMargin

			Text {
				text: qsTr("Contacts")
				color: DefaultStyle.main2_700
				font.pixelSize: 29 * DefaultStyle.dp
				font.weight: 800 * DefaultStyle.dp
			}
			Item {
				Layout.fillWidth: true
			}
			Button {
				id: createContactButton
				visible: !rightPanelStackView.currentItem || rightPanelStackView.currentItem.objectName !== "contactEdition"
				style: ButtonStyle.noBackground
				icon.source: AppIcons.plusCircle
				Layout.preferredWidth: 28 * DefaultStyle.dp
				Layout.preferredHeight: 28 * DefaultStyle.dp
				icon.width: 28 * DefaultStyle.dp
				icon.height: 28 * DefaultStyle.dp
				onClicked: {
					mainItem.createContact("", "")
				}
				KeyNavigation.down: searchBar
			}
		}

		ColumnLayout {
			anchors.top: title.bottom
			anchors.right: leftPanel.right
			anchors.left: leftPanel.left
			anchors.bottom: leftPanel.bottom
			enabled: mainItem.leftPanelEnabled
			spacing: 38 * DefaultStyle.dp
			SearchBar {
				id: searchBar
				Layout.leftMargin: leftPanel.leftMargin
				Layout.rightMargin: leftPanel.rightMargin
				Layout.topMargin: 18 * DefaultStyle.dp
				Layout.fillWidth: true
				placeholderText: qsTr("Rechercher un contact")
				KeyNavigation.up: createContactButton
				KeyNavigation.down: contactList
			}
			ColumnLayout {
				id: content
				spacing: 15 * DefaultStyle.dp
				Text {
					visible: !contactList.loading && !contactList.haveContacts
					Layout.alignment: Qt.AlignHCenter
					Layout.topMargin: 137 * DefaultStyle.dp
					text: qsTr("Aucun contact%1").arg(searchBar.text.length !== 0 ? " correspondant" : "")
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				AllContactListView{
					id: contactList
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.leftMargin: 45 * DefaultStyle.dp
					searchBarText: searchBar.text
					hideSuggestions: true
					showDefaultAddress: false
					sourceFlags: LinphoneEnums.MagicSearchSource.Friends | LinphoneEnums.MagicSearchSource.FavoriteFriends | LinphoneEnums.MagicSearchSource.LdapServers | LinphoneEnums.MagicSearchSource.RemoteCardDAV
					onHighlightedContactChanged: mainItem.selectedContact = highlightedContact
					onContactDeletionRequested: (contact) => {
						mainItem.deleteContact(contact)
					}
					onLoadingChanged: {
						if(!loading && initialFriendToDisplay.length !== 0) {
							Qt.callLater(function(){
								if (selectContact(initialFriendToDisplay) != -1) initialFriendToDisplay = ""
							})
						}
					}
				}
			}
		}
	}

	Component {
		id: contactDetail
		Item {
			width: parent?.width
			height: parent?.height
			property string objectName: "contactDetail"
			component ContactDetailLayout: ColumnLayout {
				id: contactDetailLayout
				spacing: 15 * DefaultStyle.dp
				property string label
				property var icon
				property alias content: contentControl.contentItem
				signal titleIconClicked()
				RowLayout {
					spacing: 10 * DefaultStyle.dp
					Text {
						text: contactDetailLayout.label
						color: DefaultStyle.main1_500_main
						font {
							pixelSize: 16 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
					}
					RoundButton {
						visible: contactDetailLayout.icon != undefined
						icon.source: contactDetailLayout.icon
						style: ButtonStyle.noBackgroundOrange
						onClicked: contactDetailLayout.titleIconClicked()
					}
					Item{Layout.fillWidth: true}
					RoundButton {
						id: expandButton
						style: ButtonStyle.noBackground
						checkable: true
						checked: true
						icon.source: checked ? AppIcons.upArrow : AppIcons.downArrow
						KeyNavigation.down: contentControl
					}
				}
				RoundedPane {
					id: contentControl
					visible: expandButton.checked
					Layout.fillWidth: true
					leftPadding: 20 * DefaultStyle.dp
					rightPadding: 20 * DefaultStyle.dp
					topPadding: 17 * DefaultStyle.dp
					bottomPadding: 17 * DefaultStyle.dp
				}
			}
			ContactLayout {
				id: contactDetail
				anchors.fill: parent
				contact: mainItem.selectedContact
				button.color: DefaultStyle.main1_100
				button.text: qsTr("Modifier")
				button.style: ButtonStyle.tertiary
				button.icon.source: AppIcons.pencil
				button.onClicked: mainItem.editContact(mainItem.selectedContact)
				button.visible: !mainItem.selectedContact?.core.readOnly
				property string contactAddress: contact ? contact.core.defaultAddress : ""
				property var computedContactNameObj: UtilsCpp.getDisplayName(contactAddress)
				property string computedContactName: computedContactNameObj ? computedContactNameObj.value : ""
				property string contactName: contact
					? contact.core.fullName
					: computedContactName
				component LabelButton: ColumnLayout {
					id: labelButton
					// property alias image: buttonImg
					property alias button: button
					property string label
					spacing: 8 * DefaultStyle.dp
					RoundButton {
						id: button
						Layout.alignment: Qt.AlignHCenter
						Layout.preferredWidth: 56 * DefaultStyle.dp
						Layout.preferredHeight: 56 * DefaultStyle.dp
						style: ButtonStyle.grey
					}
					Text {
						Layout.alignment: Qt.AlignHCenter
						text: labelButton.label
						font {
							pixelSize: 14 * DefaultStyle.dp
							weight: 400 * DefaultStyle.dp
						}
					}
				}
				component ActionsButtons: RowLayout {
					spacing: 58 * DefaultStyle.dp
					LabelButton {
						button.icon.source: AppIcons.phone
						label: qsTr("Appel")
						width: 56 * DefaultStyle.dp
						height: 56 * DefaultStyle.dp
						button.icon.width: 24 * DefaultStyle.dp
						button.icon.height: 24 * DefaultStyle.dp
						button.onClicked: mainWindow.startCallWithContact(contactDetail.contact, false, mainItem)
					}
					LabelButton {
						button.icon.source: AppIcons.chatTeardropText
						visible: !SettingsCpp.disableChatFeature
						label: qsTr("Message")
						width: 56 * DefaultStyle.dp
						height: 56 * DefaultStyle.dp
						button.icon.width: 24 * DefaultStyle.dp
						button.icon.height: 24 * DefaultStyle.dp
						button.onClicked: console.debug("[ContactLayout.qml] TODO : open conversation")
					}
					LabelButton {
						button.icon.source: AppIcons.videoCamera
						label: qsTr("Appel vidéo")
						width: 56 * DefaultStyle.dp
						height: 56 * DefaultStyle.dp
						button.icon.width: 24 * DefaultStyle.dp
						button.icon.height: 24 * DefaultStyle.dp
						button.onClicked: mainWindow.startCallWithContact(contactDetail.contact, true, mainItem)
					}
				}
				bannerContent: [
					ColumnLayout {
						spacing: 0
						Text {
							text: contactDetail.contactName
							Layout.fillWidth: true
							maximumLineCount: 1
							font {
								pixelSize: 29 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
								capitalization: Font.Capitalize
							}
						}
						Text {
							visible: contactDetail.contact
							property var mode : contactDetail.contact ? contactDetail.contact.core.consolidatedPresence : -1
							horizontalAlignment: Text.AlignLeft
							Layout.fillWidth: true
							text: mode === LinphoneEnums.ConsolidatedPresence.Online
								? qsTr("En ligne")
								: mode === LinphoneEnums.ConsolidatedPresence.Busy
									? qsTr("Occupé")
									: mode === LinphoneEnums.ConsolidatedPresence.DoNotDisturb
										? qsTr("Ne pas déranger")
										: qsTr("Hors ligne")
							color: mode === LinphoneEnums.ConsolidatedPresence.Online
								? DefaultStyle.success_500main
								: mode === LinphoneEnums.ConsolidatedPresence.Busy
									? DefaultStyle.warning_600
									: mode === LinphoneEnums.ConsolidatedPresence.DoNotDisturb
										? DefaultStyle.danger_500main
										: DefaultStyle.main2_500main
							font.pixelSize: 14 * DefaultStyle.dp
						}
					},
					ActionsButtons {
						visible: !contactDetail.useVerticalLayout
					}
				]
				secondLineContent: ActionsButtons{}
				content: Flickable {
					contentWidth: parent.width
					ColumnLayout {
						spacing: 32 * DefaultStyle.dp
						anchors.left: parent.left
						anchors.right: parent.right
						ColumnLayout {
							spacing: 15 * DefaultStyle.dp
							Layout.fillWidth: true
							ContactDetailLayout {
								id: infoLayout
								Layout.fillWidth: true
								label: qsTr("Informations")
								content: ListView {
									id: addrList
									height: contentHeight
									implicitHeight: contentHeight
									width: parent.width
									clip: true
									spacing: 9 * DefaultStyle.dp
									model: VariantList {
										model:  mainItem.selectedContact ? mainItem.selectedContact.core.allAddresses : []
									}
									delegate: Item {
										property var listViewModelData: modelData
										width: addrList.width
										height: 46 * DefaultStyle.dp

										ColumnLayout {
											anchors.fill: parent
											// anchors.topMargin: 5 * DefaultStyle.dp
											RowLayout {
												Layout.fillWidth: true
												// Layout.fillHeight: true
												// Layout.alignment: Qt.AlignVCenter
												// Layout.topMargin: 10 * DefaultStyle.dp
												// Layout.bottomMargin: 10 * DefaultStyle.dp
												ColumnLayout {
													Layout.fillWidth: true
													Text {
														Layout.fillWidth: true
														text: listViewModelData.label
														font {
															pixelSize: 13 * DefaultStyle.dp
															weight: 700 * DefaultStyle.dp
														}
													}
													Text {
														Layout.fillWidth: true
														property string _text: listViewModelData.address
														text: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(_text) : _text
														font {
															pixelSize: 14 * DefaultStyle.dp
															weight: 400 * DefaultStyle.dp
														}
													}
												}
												Item {
													Layout.fillWidth: true
												}
												RoundButton {
													style: ButtonStyle.noBackground
													icon.source: AppIcons.phone
													onClicked: {
														UtilsCpp.createCall(listViewModelData.address)
													}
												}
											}

											Rectangle {
												visible: index != addrList.model.count - 1
												Layout.fillWidth: true
												Layout.preferredHeight: 1 * DefaultStyle.dp
												Layout.rightMargin: 3 * DefaultStyle.dp
												Layout.leftMargin: 3 * DefaultStyle.dp
												color: DefaultStyle.main2_200
												clip: true
											}
										}
									}
								}
							}
							RoundedPane {
								visible: infoLayout.visible && companyText.text.length != 0 || jobText.text.length != 0
								Layout.fillWidth: true
								topPadding: 17 * DefaultStyle.dp
								bottomPadding: 17 * DefaultStyle.dp
								leftPadding: 20 * DefaultStyle.dp
								rightPadding: 20 * DefaultStyle.dp

								contentItem: ColumnLayout {
									RowLayout {
										height: 50 * DefaultStyle.dp
										visible: companyText.text.length != 0
										Text {
											text: qsTr("Société :")
											font {
												pixelSize: 13 * DefaultStyle.dp
												weight: 700 * DefaultStyle.dp
											}
										}
										Text {
											id: companyText
											text: mainItem.selectedContact && mainItem.selectedContact.core.organization
											font {
												pixelSize: 14 * DefaultStyle.dp
												weight: 400 * DefaultStyle.dp
											}
										}
									}
									RowLayout {
										height: 50 * DefaultStyle.dp
										visible: jobText.text.length != 0
										Text {
											text: qsTr("Poste :")
											font {
												pixelSize: 13 * DefaultStyle.dp
												weight: 700 * DefaultStyle.dp
											}
										}
										Text {
											id: jobText
											text: mainItem.selectedContact && mainItem.selectedContact.core.job
											font {
												pixelSize: 14 * DefaultStyle.dp
												weight: 400 * DefaultStyle.dp
											}
										}
									}
								}
							}
						}
						ContactDetailLayout {
							visible: !SettingsCpp.disableChatFeature
							label: qsTr("Medias")
							Layout.fillWidth: true
							content: Button {
								style: ButtonStyle.noBackground
								contentItem: RowLayout {
									EffectImage {
										Layout.preferredWidth: 24 * DefaultStyle.dp
										Layout.preferredHeight: 24 * DefaultStyle.dp
										source: AppIcons.shareNetwork
										colorizationColor: DefaultStyle.main2_600
									}
									Text {
										text: qsTr("Afficher les medias partagés")
										font {
											pixelSize: Typography.p1.pixelSize
											weight: Typography.p1.weight
										}
									}
									Item{Layout.fillWidth: true}
									EffectImage {
										Layout.preferredWidth: 24 * DefaultStyle.dp
										Layout.preferredHeight: 24 * DefaultStyle.dp
										imageSource: AppIcons.rightArrow
										colorizationColor: DefaultStyle.main2_600
									}
								}
								onClicked: console.debug("TODO : go to shared media")
							}
						}
						ContactDetailLayout {
							Layout.fillWidth: true
							label: qsTr("Confiance")
							icon: AppIcons.question
							onTitleIconClicked: trustInfoDialog.open()
							content:  ColumnLayout {
								spacing: 13 * DefaultStyle.dp
								Text {
									text: qsTr("Niveau de confiance - Appareils vérifiés")
									font {
										pixelSize: 13 * DefaultStyle.dp
										weight: 700 * DefaultStyle.dp
									}
								}
								Text {
									visible: deviceList.count === 0
									text: qsTr("Aucun appareil")
								}
								ProgressBar {
									visible: deviceList.count > 0
									Layout.fillWidth: true
									Layout.preferredHeight: 28 * DefaultStyle.dp
                                    value: mainItem.selectedContact ? mainItem.selectedContact.core.verifiedDeviceCount / deviceList.count : 0
								}
								ListView {
									id: deviceList
									Layout.fillWidth: true
									Layout.preferredHeight: Math.min(200 * DefaultStyle.dp, contentHeight)
									clip: true
									model: mainItem.selectedContact ? mainItem.selectedContact.core.devices : []
									spacing: 16 * DefaultStyle.dp
									delegate: RowLayout {
										id: deviceDelegate
										width: deviceList.width
										height: 30 * DefaultStyle.dp
										property var listViewModelData: modelData
										property var callObj
										property CallGui deviceCall: callObj ? callObj.value : null
										property string deviceName: listViewModelData.name.length != 0 ? listViewModelData.name : qsTr("Appareil sans nom")
										Text {
											text: deviceDelegate.deviceName
											font.pixelSize: 14 * DefaultStyle.dp
										}
										Item{Layout.fillWidth: true}
										Image{
											visible: listViewModelData.securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
											source: AppIcons.trusted
											width: 22 * DefaultStyle.dp
											height: 22 * DefaultStyle.dp
										}
										
										SmallButton {
											// Layout.preferredHeight: 30 * DefaultStyle.dp
											visible: listViewModelData.securityLevel != LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
											icon.source: AppIcons.warningCircle
											style: ButtonStyle.tertiary
											text: qsTr("Vérifier")
											onClicked: {
												if (SettingsCpp.getDisplayDeviceCheckConfirmation()) {
													verifyDevicePopup.deviceName = deviceDelegate.deviceName
													verifyDevicePopup.deviceAddress = listViewModelData.address
													verifyDevicePopup.open()
												}
												else {
													UtilsCpp.createCall(listViewModelData.address, {}, LinphoneEnums.MediaEncryption.Zrtp)
													parent.callObj = UtilsCpp.getCallByAddress(listViewModelData.address)
												}
											}
										}
									}
								}
							}
						}
						ContactDetailLayout {
							Layout.fillWidth: true
							label: qsTr("Autres actions")
							content:  ColumnLayout {
								width: parent.width
								IconLabelButton {
									Layout.fillWidth: true
									Layout.preferredHeight: 50 * DefaultStyle.dp
									icon.source: AppIcons.pencil
									text: qsTr("Éditer")
									onClicked: mainItem.editContact(mainItem.selectedContact)
									visible: !mainItem.selectedContact?.core.readOnly
									style: ButtonStyle.noBackground
								}
								Rectangle {
									Layout.fillWidth: true
									Layout.preferredHeight: 1 * DefaultStyle.dp
									color: DefaultStyle.main2_200
								}
								IconLabelButton {
									Layout.fillWidth: true
									Layout.preferredHeight: 50 * DefaultStyle.dp
									icon.source: mainItem.selectedContact && mainItem.selectedContact.core.starred ? AppIcons.heartFill : AppIcons.heart
									text: mainItem.selectedContact && mainItem.selectedContact.core.starred ? qsTr("Retirer des favoris") : qsTr("Ajouter aux favoris")
									style: ButtonStyle.noBackground
									onClicked: if (mainItem.selectedContact) mainItem.selectedContact.core.lSetStarred(!mainItem.selectedContact.core.starred)
								}
								Rectangle {
									Layout.fillWidth: true
									Layout.preferredHeight: 1 * DefaultStyle.dp
									color: DefaultStyle.main2_200
								}
								IconLabelButton {
									Layout.fillWidth: true
									Layout.preferredHeight: 50 * DefaultStyle.dp
									icon.source: AppIcons.shareNetwork
									text: qsTr("Partager")
									style: ButtonStyle.noBackground
									onClicked: {
										if (mainItem.selectedContact) {
											var vcard = mainItem.selectedContact.core.getVCard()
											var username = mainItem.selectedContact.core.givenName + mainItem.selectedContact.core.familyName
											var filepath = UtilsCpp.createVCardFile(username, vcard)
											if (filepath == "") UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La création du fichier vcard a échoué"), false)
											else mainWindow.showInformationPopup(qsTr("VCard créée"), qsTr("VCard du contact enregistrée dans %1").arg(filepath))
											UtilsCpp.shareByEmail(qsTr("Partage de contact"), vcard, filepath)
										}
									}
								}
								Rectangle {
									Layout.fillWidth: true
									Layout.preferredHeight: 1 * DefaultStyle.dp
									color: DefaultStyle.main2_200
								}
								// IconLabelButton {
								// 	Layout.fillWidth: true
								// 	Layout.preferredHeight: 50 * DefaultStyle.dp
								// 	icon.source: AppIcons.bellSlash
								// 	text: qsTr("Mettre en sourdine")
								// 	onClicked: console.log("TODO : mute contact")
								// }
								// Rectangle {
								// 	Layout.fillWidth: true
								// 	Layout.preferredHeight: 1 * DefaultStyle.dp
								// 	color: DefaultStyle.main2_200
								// }
								// IconLabelButton {
								// 	Layout.fillWidth: true
								// 	Layout.preferredHeight: 50 * DefaultStyle.dp
								// 	icon.source: AppIcons.empty
								// 	text: qsTr("Bloquer")
								// 	onClicked: console.log("TODO : block contact")
								// }
								// Rectangle {
								// 	Layout.fillWidth: true
								// 	Layout.preferredHeight: 1 * DefaultStyle.dp
								// 	color: DefaultStyle.main2_200
								// }
								IconLabelButton {
									Layout.fillWidth: true
									Layout.preferredHeight: 50 * DefaultStyle.dp
									icon.source: AppIcons.trashCan
									text: qsTr("Supprimer ce contact")
									visible: !mainItem.selectedContact?.core.readOnly
									onClicked: {
										mainItem.deleteContact(mainItem.selectedContact)
									}
									style: ButtonStyle.noBackgroundRed
								}
							}
							
						}
						Item{
							Layout.fillHeight: true
						}
					}
				}
			}
		}
	}

	Component {
		id: contactEdition
		ContactEdition {
			property string objectName: "contactEdition"
			onCloseEdition: {
				if (rightPanelStackView.depth <= 1) rightPanelStackView.clear()
				else rightPanelStackView.pop(Control.StackView.Immediate)
			}
		}
	}
}
