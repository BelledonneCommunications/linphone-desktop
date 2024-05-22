import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp 1.0

AbstractMainPage {
	id: mainItem
	noItemButtonText: qsTr("Ajouter un contact")
	emptyListText: qsTr("Aucun contact pour le moment")
	newItemIconSource: AppIcons.plusCircle

	// disable left panel contact list interaction while a contact is being edited
	property bool leftPanelEnabled: true
	property FriendGui selectedContact
	onSelectedContactChanged: {
		if (selectedContact) {
			if (!rightPanelStackView.currentItem || rightPanelStackView.currentItem.objectName != "contactDetail") rightPanelStackView.push(contactDetail)
		} else {
			if (rightPanelStackView.currentItem && rightPanelStackView.currentItem.objectName === "contactDetail") rightPanelStackView.clear()
		}
	}
	signal forceListsUpdate()

	onNoItemButtonPressed: createContact("", "")

	function createContact(name, address) {
		var friendGui = Qt.createQmlObject('import Linphone
											FriendGui{
											}', mainItem)
		friendGui.core.givenName = UtilsCpp.getGivenNameFromFullName(name)
		friendGui.core.familyName = UtilsCpp.getFamilyNameFromFullName(name)
		friendGui.core.defaultAddress = address
		rightPanelStackView.push(contactEdition, {"contact": friendGui, "title": qsTr("Nouveau contact"), "saveButtonText": qsTr("Créer")})
	}

	function editContact(friendGui) {
		rightPanelStackView.push(contactEdition, {"contact": friendGui, "title": qsTr("Modifier contact"), "saveButtonText": qsTr("Enregistrer")})
	}

	// rightPanelStackView.initialItem: contactDetail
	Binding {
		mainItem.showDefaultItem: false
		when: rightPanelStackView.currentItem
		restoreMode: Binding.RestoreBinding
	}

	showDefaultItem: contactList.model.sourceModel.count === 0
	
	property MagicSearchProxy allFriends: MagicSearchProxy {
		searchText: searchBar.text.length === 0 ? "*" : searchBar.text
		aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
	}

	Dialog {
		id: dialog
		property var contact
		text: (contact ? contact.core.displayName : "Contact") + " is about to be deleted. Do you want to continue ?"
		onAccepted: contact.core.remove()
	}

	leftPanelContent: Item {
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
				background: Item {
				}
				icon.source: AppIcons.plusCircle
				Layout.preferredWidth: 30 * DefaultStyle.dp
				Layout.preferredHeight: 30 * DefaultStyle.dp
				icon.width: 30 * DefaultStyle.dp
				icon.height: 30 * DefaultStyle.dp
				onClicked: {
					mainItem.createContact("", "")
				}
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
			}
			Item {
				id: contactsArea
				Layout.fillWidth: true
				Layout.fillHeight: true
				
				Control.ScrollView {
					id: listLayout
					anchors.fill: parent
					contentWidth: width
					contentHeight: content.height
					clip: true
					Control.ScrollBar.vertical: contactsScrollbar

					ColumnLayout {
						id: content
						width: parent.width
						// anchors.fill: parent
						spacing: 15 * DefaultStyle.dp
						Text {
							text: qsTr("Aucun contact")
							font {
								pixelSize: 16 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
							visible: contactList.count === 0 && favoriteList.count === 0
							Layout.alignment: Qt.AlignHCenter
						}
						ColumnLayout {
							visible: favoriteList.contentHeight > 0
							Layout.leftMargin: leftPanel.leftMargin
							Layout.rightMargin: leftPanel.rightMargin
							spacing: 16 * DefaultStyle.dp
							RowLayout {
								spacing: 0
								Text {
									text: qsTr("Favoris")
									font {
										pixelSize: 16 * DefaultStyle.dp
										weight: 800 * DefaultStyle.dp
									}
								}
								Item {
									Layout.fillWidth: true
								}
								Button {
									background: Item{}
									icon.source: favoriteList.visible ? AppIcons.upArrow : AppIcons.downArrow
									Layout.preferredWidth: 24 * DefaultStyle.dp
									Layout.preferredHeight: 24 * DefaultStyle.dp
									icon.width: 24 * DefaultStyle.dp
									icon.height: 24 * DefaultStyle.dp
									onClicked: favoriteList.visible = !favoriteList.visible
								}
							}
							ContactsList{
								id: favoriteList
								hoverEnabled: mainItem.leftPanelEnabled
								Layout.fillWidth: true
								Layout.preferredHeight: contentHeight
								Control.ScrollBar.vertical.visible: false
								showOnlyFavourites: true
								contactMenuVisible: true
								model: allFriends
								onSelectedContactChanged: {
									if (selectedContact) {
										contactList.currentIndex = -1
									}
									mainItem.selectedContact = selectedContact
								}
								onContactDeletionRequested: (contact) => {
									dialog.contact = contact
									dialog.open()
								}
							}
						}
						ColumnLayout {
							visible: contactList.count > 0
							Layout.leftMargin: leftPanel.leftMargin
							Layout.rightMargin: leftPanel.rightMargin
							spacing: 16 * DefaultStyle.dp
							RowLayout {
								spacing: 0
								Text {
									text: qsTr("All contacts")
									font {
										pixelSize: 16 * DefaultStyle.dp
										weight: 800 * DefaultStyle.dp
									}
								}
								Item {
									Layout.fillWidth: true
								}
								Button {
									background: Item{}
									icon.source: contactList.visible ? AppIcons.upArrow : AppIcons.downArrow
									Layout.preferredWidth: 24 * DefaultStyle.dp
									Layout.preferredHeight: 24 * DefaultStyle.dp
									icon.width: 24 * DefaultStyle.dp
									icon.height: 24 * DefaultStyle.dp
									onClicked: contactList.visible = !contactList.visible
								}
							}
							ContactsList{
								id: contactList
								Layout.fillWidth: true
								Layout.preferredHeight: contentHeight
								interactive: false
								Control.ScrollBar.vertical.visible: false
								hoverEnabled: mainItem.leftPanelEnabled
								contactMenuVisible: true
								searchBarText: searchBar.text
								model: allFriends
								Connections {
									target: allFriends
									onFriendCreated: (index) => {
										contactList.currentIndex = index
									}
								}
								onSelectedContactChanged: {
									if (selectedContact) {
										favoriteList.currentIndex = -1
									}
									mainItem.selectedContact = selectedContact
								}
								onContactDeletionRequested: (contact) => {
									dialog.contact = contact
									dialog.open()
								}
							}
						}
					}

					ScrollBar {
						id: contactsScrollbar
						anchors.right: listLayout.right
						anchors.rightMargin: 8 * DefaultStyle.dp
						anchors.top: listLayout.top
						anchors.bottom: listLayout.bottom
						height: listLayout.availableHeight
						active: true
						interactive: true
						policy: Control.ScrollBar.AlwaysOn //Control.ScrollBar.AsNeeded
					}

				}

			}
		}
	}

	Component {
		id: contactDetail
		RowLayout {
			property string objectName: "contactDetail"
			visible: mainItem.selectedContact != undefined
			Layout.fillWidth: true
			Layout.fillHeight: true
			Control.StackView.onActivated:
				mainItem.leftPanelEnabled = true
			Control.StackView.onDeactivated: mainItem.leftPanelEnabled = false
			ContactLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				Layout.topMargin: 45 * DefaultStyle.dp
				Layout.leftMargin: 74 * DefaultStyle.dp
				contact: mainItem.selectedContact
				Layout.preferredWidth: 360 * DefaultStyle.dp
				buttonContent: Button {
					width: 24 * DefaultStyle.dp
					height: 24 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					background: Item{}
					onClicked: mainItem.editContact(mainItem.selectedContact)
					icon.source: AppIcons.pencil
				}
				detailContent: ColumnLayout {
					Layout.fillWidth: false
					Layout.preferredWidth: 360 * DefaultStyle.dp
					spacing: 32 * DefaultStyle.dp
					ColumnLayout {
						spacing: 15 * DefaultStyle.dp
						Text {
							text: qsTr("Informations")
							font {
								pixelSize: 16 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						
						RoundedBackgroundControl {
							Layout.preferredHeight: Math.min(226 * DefaultStyle.dp, addrList.contentHeight + topPadding + bottomPadding)
							height: Math.min(226 * DefaultStyle.dp, addrList.contentHeight)
							Layout.fillWidth: true
							contentItem: ListView {
								id: addrList
								width: 360 * DefaultStyle.dp
								height: contentHeight
								clip: true
								model: VariantList {
									model:  mainItem.selectedContact ? mainItem.selectedContact.core.allAddresses : []
								}
								delegate: Item {
									width: addrList.width
									height: 70 * DefaultStyle.dp

									ColumnLayout {
										anchors.fill: parent
										anchors.topMargin: 5 * DefaultStyle.dp
										RowLayout {
											Layout.fillWidth: true
											// Layout.fillHeight: true
											// Layout.alignment: Qt.AlignVCenter
											Layout.topMargin: 10 * DefaultStyle.dp
											Layout.bottomMargin: 10 * DefaultStyle.dp
											ColumnLayout {
												Layout.fillWidth: true
												Text {
													Layout.fillWidth: true
													text: modelData.label
													font {
														pixelSize: 13 * DefaultStyle.dp
														weight: 700 * DefaultStyle.dp
													}
												}
												Text {
													Layout.fillWidth: true
													text: modelData.address
													font {
														pixelSize: 14 * DefaultStyle.dp
														weight: 400 * DefaultStyle.dp
													}
												}
											}
											Item {
												Layout.fillWidth: true
											}
											Button {
												background: Item{}
												Layout.preferredWidth: 24 * DefaultStyle.dp
												Layout.preferredHeight: 24 * DefaultStyle.dp
												icon.source: AppIcons.phone
												width: 24 * DefaultStyle.dp
												height: 24 * DefaultStyle.dp
												icon.width: 24 * DefaultStyle.dp
												icon.height: 24 * DefaultStyle.dp
												onClicked: {
													UtilsCpp.createCall(modelData.address)
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
					}
					RoundedBackgroundControl {
						visible: companyText.text.length != 0 || jobText.text.length != 0
						Layout.fillWidth: true
						// Layout.fillHeight: true

						contentItem: ColumnLayout {
							// height: 100 * DefaultStyle.dp
							RowLayout {
								height: 50 * DefaultStyle.dp
								Text {
									text: qsTr("Company :")
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
								Text {
									text: qsTr("Job :")
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
					ColumnLayout {
						visible: false
						Text {
							text: qsTr("Medias")
							font {
								pixelSize: 16 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						Button {
							Rectangle {
								anchors.fill: parent
								color: DefaultStyle.grey_0
								radius: 15 * DefaultStyle.dp
							}
							contentItem: RowLayout {
								Image {
									Layout.preferredWidth: 24 * DefaultStyle.dp
									Layout.preferredHeight: 24 * DefaultStyle.dp
									source: AppIcons.shareNetwork
								}
								Text {
									text: qsTr("Show media shared")
									font {
										pixelSize: 14 * DefaultStyle.dp
										weight: 400 * DefaultStyle.dp
									}
								}
							}
							onClicked: console.debug("TODO : go to shared media")
						}
					}
				}
			}
			ColumnLayout {
				spacing: 10 * DefaultStyle.dp
				ColumnLayout {
					visible: false
					RowLayout {
						Text {
							text: qsTr("Confiance")
							font {
								pixelSize: 16 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
					}
					RoundedBackgroundControl {
						contentItem: ColumnLayout {
							Text {
								text: qsTr("Niveau de confiance - Appareils vérifiés")
							}
						}
					}
				}
				ColumnLayout {
					Text {
						text: qsTr("Other actions")
						font {
							pixelSize: 16 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
					}
					RoundedBackgroundControl {
						Layout.preferredWidth: 360 * DefaultStyle.dp
						contentItem: ColumnLayout {
							width: parent.width
							
							IconLabelButton {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 50 * DefaultStyle.dp
								iconSize: 24 * DefaultStyle.dp
								iconSource: AppIcons.pencil
								text: qsTr("Edit")
								onClicked: mainItem.editContact(mainItem.selectedContact)
							}
							Rectangle {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 1 * DefaultStyle.dp
								color: DefaultStyle.main2_200
							}
							IconLabelButton {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 50 * DefaultStyle.dp
								iconSize: 24 * DefaultStyle.dp
								iconSource: mainItem.selectedContact && mainItem.selectedContact.core.starred ? AppIcons.heartFill : AppIcons.heart
								text: mainItem.selectedContact && mainItem.selectedContact.core.starred ? qsTr("Remove from favourites") : qsTr("Add to favourites")
								onClicked: if (mainItem.selectedContact) mainItem.selectedContact.core.lSetStarred(!mainItem.selectedContact.core.starred)
							}
							Rectangle {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 1 * DefaultStyle.dp
								color: DefaultStyle.main2_200
							}
							IconLabelButton {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 50 * DefaultStyle.dp
								iconSize: 24 * DefaultStyle.dp
								iconSource: AppIcons.shareNetwork
								text: qsTr("Share")
								onClicked: console.log("TODO : share contact")
							}
							Rectangle {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 1 * DefaultStyle.dp
								color: DefaultStyle.main2_200
							}
							IconLabelButton {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 50 * DefaultStyle.dp
								iconSize: 24 * DefaultStyle.dp
								iconSource: AppIcons.bellSlash
								text: qsTr("Mute")
								onClicked: console.log("TODO : mute contact")
							}
							Rectangle {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 1 * DefaultStyle.dp
								color: DefaultStyle.main2_200
							}
							IconLabelButton {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 50 * DefaultStyle.dp
								iconSize: 24 * DefaultStyle.dp
								iconSource: AppIcons.empty
								text: qsTr("Block")
								onClicked: console.log("TODO : block contact")
							}
							Rectangle {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 1 * DefaultStyle.dp
								color: DefaultStyle.main2_200
							}
							IconLabelButton {
								Layout.fillWidth: true
								Layout.leftMargin: 15 * DefaultStyle.dp
								Layout.rightMargin: 15 * DefaultStyle.dp
								Layout.preferredHeight: 50 * DefaultStyle.dp
								iconSize: 24 * DefaultStyle.dp
								iconSource: AppIcons.trashCan
								color: DefaultStyle.danger_500main
								text: qsTr("Delete this contact")
								onClicked: {
									// mainItem.selectedContact.core.remove()
									dialog.contact = mainItem.selectedContact
									dialog.open()
								}
							}
						}
					}
				}
				// TODO : find device by friend
			}
		}
	}

	Component {
		id: contactEdition
		ContactEdition {
			Control.StackView.onActivated: console.log("edit/create contact")
			onCloseEdition: {
				if (rightPanelStackView.depth <= 1) rightPanelStackView.clear()
				else rightPanelStackView.pop(Control.StackView.Immediate)
			}
		}
	}
}