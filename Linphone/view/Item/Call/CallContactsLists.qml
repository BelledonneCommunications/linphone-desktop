import QtQuick
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects

import Linphone
import UtilsCpp 1.0

Item {
	id: mainItem
	property bool groupCallVisible
	property color searchBarColor: DefaultStyle.grey_100
	property color searchBarBorderColor: "transparent"
	signal callButtonPressed(string address)
	signal groupCallCreationRequested()
	property NumericPad numPad
	clip: true

	Popup {
		id: startCallPopup
		property FriendGui contact
		onContactChanged: {
			console.log("contact changed", contact)
		}
		underlineColor: DefaultStyle.main1_500_main
		anchors.centerIn: parent
		width: parent.width
		modal: true
		leftPadding: 15 * DefaultStyle.dp
		rightPadding: 15 * DefaultStyle.dp
		topPadding: 20 * DefaultStyle.dp
		bottomPadding: 25 * DefaultStyle.dp
		contentItem: ColumnLayout {
			spacing: 10 * DefaultStyle.dp
			RowLayout {
				Text {
					text: qsTr("Which channel do you choose?")
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				Item{Layout.fillWidth: true}
				Button {
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					background: Item{}
					icon.source:AppIcons.closeX
					width: 24 * DefaultStyle.dp
					height: 24 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					contentItem: Image {
						anchors.fill: parent
						source: AppIcons.closeX
					}
					onClicked: startCallPopup.close()
				}
			}
			ListView {
				id: popuplist
				model: VariantList {
					model: startCallPopup.contact && startCallPopup.contact.core.allAddresses || []
				}
				Layout.fillWidth: true
				Layout.preferredHeight: contentHeight
				delegate: Item {
					width: parent.width
					height: 56 * DefaultStyle.dp
					ColumnLayout {
						width: parent.width
						anchors.verticalCenter: parent.verticalCenter
						spacing: 10 * DefaultStyle.dp
						ColumnLayout {
							Text {
								Layout.leftMargin: 5 * DefaultStyle.dp
								text: modelData.label
								font {
									pixelSize: 13 * DefaultStyle.dp
									weight: 700 * DefaultStyle.dp
								}
							}
							Text {
								Layout.leftMargin: 5 * DefaultStyle.dp
								text: modelData.address
								font {
									pixelSize: 14 * DefaultStyle.dp
									weight: 400 * DefaultStyle.dp
								}
							}
						}
						Rectangle {
							visible: index != popuplist.model.count - 1
							Layout.fillWidth: true
							Layout.preferredHeight: 1 * DefaultStyle.dp
							color: DefaultStyle.main2_200
						}
					}
					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
						onClicked: mainItem.callButtonPressed(modelData.address)
					}
				}
			}
		}
	}

	Control.Control {
		id: listLayout
		anchors.fill: parent
		background: Item {
			anchors.fill: parent
		}
		contentItem: ColumnLayout {
			anchors.fill: parent
			spacing: 10 * DefaultStyle.dp
			SearchBar {
				id: searchBar
				Layout.alignment: Qt.AlignTop
				Layout.fillWidth: true
				Layout.maximumWidth: mainItem.width
				Layout.rightMargin: 39 * DefaultStyle.dp
				color: mainItem.searchBarColor
				borderColor: mainItem.searchBarBorderColor
				placeholderText: qsTr("Rechercher un contact")
				numericPad: mainItem.numPad
			}
			Control.ScrollView {
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.topMargin: 25 * DefaultStyle.dp
				contentWidth: width
				contentHeight: content.height
				clip: true
				Control.ScrollBar.vertical: ScrollBar {
					active: true
					interactive: true
					policy: Control.ScrollBar.AsNeeded
					// Layout.fillWidth: true
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					anchors.right: parent.right
					anchors.rightMargin: 8 * DefaultStyle.dp
					// x: mainItem.x + mainItem.width - width
					// anchors.left: control.right
				}

				ColumnLayout {
					id: content
					width: parent.width
					spacing: 25 * DefaultStyle.dp
					Button {
						visible: mainItem.groupCallVisible
						Layout.preferredWidth: 320 * DefaultStyle.dp
						padding: 0
						background: Rectangle {
							gradient: Gradient {
								orientation: Gradient.Horizontal
								GradientStop { position: 0.0; color: DefaultStyle.main2_100}
								GradientStop { position: 1.0; color: DefaultStyle.grey_0}
							}
							anchors.fill: parent
							radius: 50 * DefaultStyle.dp
						}
						contentItem: RowLayout {
							anchors.verticalCenter: parent.verticalCenter
							Image {
								source: AppIcons.groupCall
								Layout.preferredWidth: 44 * DefaultStyle.dp
								sourceSize.width: 44 * DefaultStyle.dp
								fillMode: Image.PreserveAspectFit
							}
							Text {
								text: "Appel de groupe"
								color: DefaultStyle.grey_1000
								font {
									pixelSize: 16 * DefaultStyle.dp
									weight: 800 * DefaultStyle.dp
								}
							}
							Item {
								Layout.fillWidth: true
							}
							Image {
								source: AppIcons.rightArrow
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
							}
						}
						onClicked: mainItem.groupCallCreationRequested()
					}

					// RowLayout {
						// 	//DEBUG
						// 	visible: searchBar.text.length > 0
						// 	Layout.maximumWidth: parent.width
						// 	Layout.fillWidth: true
						// 	Text {
						// 		text: searchBar.text
						// 		maximumLineCount: 1
						// 		elide: Text.ElideRight
						// 	}
						// 	Item {
						// 		Layout.fillWidth: true
						// 	}
						// 	Button {
						// 		implicitWidth: 30 * DefaultStyle.dp
						// 		implicitHeight: 30 * DefaultStyle.dp
						// 		background: Item {
						// 			visible: false
						// 		}
						// 		icon.source: AppIcons.phone
						// 		width: 20 * DefaultStyle.dp
						// 		height: 20 * DefaultStyle.dp
						// 		onClicked: {
						// 			mainItem.callButtonPressed(searchBar.text)
						// 		}
						// 	}
					// }
					ColumnLayout {
						Text {
							text: qsTr("All contacts")
							font {
								pixelSize: 16 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						ContactsList{
							id: contactList
							Layout.fillWidth: true
							Layout.preferredHeight: contentHeight
							Control.ScrollBar.vertical.visible: false
							contactMenuVisible: false
							model: MagicSearchProxy {
								searchText: searchBar.text.length === 0 ? "*" : searchBar.text
							}
							onSelectedContactChanged: {
								if (selectedContact) {
									if (selectedContact.core.allAddresses.length > 1) {
										startCallPopup.contact = selectedContact
										startCallPopup.open()

									} else {
										mainItem.callButtonPressed(selectedContact.core.defaultAddress)
									}
								}
							}
							// onContactSelected: (contact) => {
							// 	if (contact.core.allAddresses.length > 1) {
							// 		startCallPopup.contact = contact
							// 		startCallPopup.open()

							// 	} else {
							// 		mainItem.callButtonPressed(contact.core.defaultAddress)
							// 	}
							// }
						}
					}
					ColumnLayout {
						Text {
							text: qsTr("Suggestions")
							font {
								pixelSize: 16 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						ContactsList{
							contactMenuVisible: false
							Layout.fillWidth: true
							Layout.fillHeight: true
							Control.ScrollBar.vertical.visible: false
							Layout.preferredHeight: contentHeight
							initialHeadersVisible: false
							displayNameCapitalization: false
							model: MagicSearchProxy {
								searchText: searchBar.text.length === 0 ? "*" : searchBar.text
								sourceFlags: LinphoneEnums.MagicSearchSource.All
								aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
							}
							onSelectedContactChanged: {
								if (selectedContact) {
									if (selectedContact.core.allAddresses.length > 1) {
										startCallPopup.contact = selectedContact
										startCallPopup.open()

									} else {
										var addressToCall = selectedContact.core.defaultAddress.length === 0 
											? selectedContact.core.phoneNumbers.length === 0
												? ""
												: selectedContact.core.phoneNumbers[0].address
											: selectedContact.core.defaultAddress
										if (addressToCall.length != 0) mainItem.callButtonPressed(addressToCall)
									}
								}
							}
							// onContactSelected: (contact) => {
							// 	if (contact.core.allAddresses.length > 1) {
							// 		startCallPopup.contact = contact
							// 		startCallPopup.open()

							// 	} else {
							// 		var addressToCall = contact.core.defaultAddress.length === 0 
							// 			? contact.core.phoneNumbers.length === 0
							// 				? ""
							// 				: contact.core.phoneNumbers[0].address
							// 			: contact.core.defaultAddress
							// 		if (addressToCall.length != 0) mainItem.callButtonPressed(addressToCall)
							// 	}
							// }
						}
					}
					Item {
						Layout.fillHeight: true
					}
				}
			}
		}
	}
}
