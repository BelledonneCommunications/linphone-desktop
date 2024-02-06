/**
* Qml template used for welcome and login/register pages
**/

import QtCore
import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects

import Linphone
import UtilsCpp

Item {
	id: mainItem
	
	signal addAccountRequest()

	function goToNewCall() {
		tabbar.currentIndex = 0
		callPage.goToNewCall()
	}

	function transferCallSucceed() {
		transferSucceedPopup.open()
	}

	Timer {
		id: autoClosePopup
		interval: 5000
		onTriggered: {
			transferSucceedPopup.close()
		} 
	}
	Popup {
		id: transferSucceedPopup
		onVisibleChanged: if (visible) autoClosePopup.restart()
		closePolicy: Control.Popup.NoAutoClose
		x : parent.x + parent.width - width
		y : parent.y + parent.height - height
		rightMargin: 20 * DefaultStyle.dp
		bottomMargin: 20 * DefaultStyle.dp
		padding: 20 * DefaultStyle.dp
		underlineColor: DefaultStyle.success_500main
		radius: 0
		contentItem: RowLayout {
			spacing: 15 * DefaultStyle.dp
			EffectImage {
				source: AppIcons.smiley
				colorizationColor: DefaultStyle.success_500main
				Layout.preferredWidth: 32 * DefaultStyle.dp
				Layout.preferredHeight: 32 * DefaultStyle.dp
				width: 32 * DefaultStyle.dp
				height: 32 * DefaultStyle.dp
			}
			Rectangle {
				Layout.preferredWidth: 1 * DefaultStyle.dp
				Layout.preferredHeight: parent.height
				color: DefaultStyle.main2_200
			}
			ColumnLayout {
				Text {
					text: qsTr("Appel transféré")
					color: DefaultStyle.success_500main
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				Text {
					Layout.alignment: Qt.AlignHCenter
					Layout.fillWidth: true
					text: qsTr("Votre correspondant a été transféré au contact sélectionné")
					color: DefaultStyle.main2_500main
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 300 * DefaultStyle.dp
					}
				}
			}
		}
	}

	RowLayout {
		anchors.fill: parent
		// spacing: 30
		anchors.topMargin: 18 * DefaultStyle.dp
		VerticalTabBar {
			id: tabbar
			Layout.fillHeight: true
			model: [
				{icon: AppIcons.phone, selectedIcon: AppIcons.phoneSelected, label: qsTr("Appels")},
				{icon: AppIcons.adressBook, selectedIcon: AppIcons.adressBookSelected, label: qsTr("Contacts")},
				{icon: AppIcons.chatTeardropText, selectedIcon: AppIcons.chatTeardropTextSelected, label: qsTr("Conversations")},
				{icon: AppIcons.usersThree, selectedIcon: AppIcons.usersThreeSelected, label: qsTr("Réunions")}
			]
		}
		ColumnLayout {
			Layout.fillWidth: true
			Layout.fillHeight: true
			RowLayout {
				id: topRow
				Layout.leftMargin: 25 * DefaultStyle.dp
				Layout.rightMargin: 41 * DefaultStyle.dp
				SearchBar {
					id: magicSearchBar
					Layout.fillWidth: true
					placeholderText: qsTr("Rechercher un contact, appeler ou envoyer un message...")
					onTextChanged: {
						if (text.length != 0) listPopup.open()
						else listPopup.close()
					}
					Popup {
						id: listPopup
						width: magicSearchList.width + listPopup.rightPadding + listPopup.leftPadding
						height: Math.min(magicSearchList.contentHeight, 300 * DefaultStyle.dp + topPadding + bottomPadding)
						y: magicSearchBar.height
						closePolicy: Popup.NoAutoClose
						topPadding: 10 * DefaultStyle.dp
						bottomPadding: 10 * DefaultStyle.dp
						rightPadding: 10 * DefaultStyle.dp
						leftPadding: 10 * DefaultStyle.dp
						background: Item {
							anchors.fill: parent
							Rectangle {
								id: popupBg
								radius: 15 * DefaultStyle.dp
								anchors.fill: parent
								// width: magicSearchList.width + listPopup.rightPadding + listPopup.leftPadding
							}
							MultiEffect {
								source: popupBg
								anchors.fill: popupBg
								shadowEnabled: true
								shadowBlur: 1
								shadowColor: DefaultStyle.grey_1000
								shadowOpacity: 0.1
							}
						}
						Control.ScrollBar {
							id: scrollbar
							height: parent.height
							anchors.right: parent.right
						}
						ContactsList {
							id: magicSearchList
							visible: magicSearchBar.text.length != 0
							height: Math.min(contentHeight, listPopup.height)
							width: magicSearchBar.width
							initialHeadersVisible: false
							contactMenuVisible: false
							model: MagicSearchProxy {
								searchText: magicSearchBar.text.length === 0 ? "*" : magicSearchBar.text
								aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
							}
							Control.ScrollBar.vertical: scrollbar
							header: ColumnLayout {
								width: magicSearchList.width
								RowLayout {
									Layout.fillWidth: true
									spacing: 10 * DefaultStyle.dp
									Avatar {
										Layout.preferredWidth: 45 * DefaultStyle.dp
										Layout.preferredHeight: 45 * DefaultStyle.dp
										address: sipAddr.text
									}
									ColumnLayout {
										Text {
											text: magicSearchBar.text
											font {
												pixelSize: 14 * DefaultStyle.dp
												weight: 700 * DefaultStyle.dp
											}
										}
										Text {
											id: sipAddr
											text: UtilsCpp.generateLinphoneSipAddress(magicSearchBar.text)
										}
									}
									Item {
										Layout.fillWidth: true
									}
									Button {
										background: Item{}
										Layout.preferredWidth: 24 * DefaultStyle.dp
										Layout.preferredHeight: 24 * DefaultStyle.dp
										contentItem: Image {
											width: 24 * DefaultStyle.dp
											height: 24 * DefaultStyle.dp
											source: AppIcons.phone
										}
										onClicked: {
											var callObj = UtilsCpp.createCall(sipAddr)
										}
									}
								}
								Button {
									Layout.fillWidth: true
									color: DefaultStyle.main2_200
									pressedColor: DefaultStyle.main2_400
									background: Rectangle {
										anchors.fill: parent
										color: DefaultStyle.main2_200
									}
									contentItem: RowLayout {
										spacing: 10 * DefaultStyle.dp
										Image {
											source: AppIcons.userPlus
										}
										Text {
											text: qsTr("Ajouter ce contact")
											font {
												pixelSize: 14 * DefaultStyle.dp
												weight: 700 * DefaultStyle.dp
												capitalization: Font.AllUppercase
											}
										}
										Item {Layout.fillWidth: true}
									}
									onClicked: {
										var currentItem = mainStackLayout.children[mainStackLayout.currentIndex]
										listPopup.close()
										currentItem.createContact(magicSearchBar.text, sipAddr.text)
									}
								}
							}
							delegateButtons: Button {
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								background: Item{}
								contentItem: Image {
									anchors.fill: parent
									width: 24 * DefaultStyle.dp
									height: 24 * DefaultStyle.dp
									source: AppIcons.phone
								}
							}
						}
					}
				}
				Control.Button {
					id: avatarButton
					AccountProxy{
						id: accountProxy
						//property bool haveAvatar: defaultAccount && defaultAccount.core.pictureUri || false
					}
					
					Layout.preferredWidth: 54 * DefaultStyle.dp
					Layout.preferredHeight: width
					background: Item {
						visible: false
					}
					contentItem: Avatar {
						id: avatar
						height: avatarButton.height
						width: avatarButton.width
						account: accountProxy.defaultAccount
					}
					onClicked: {
						accountList.open()
					}
					Popup{
						id: accountList
						x: -width + parent.width
						y: settingsButton.height + (10 * DefaultStyle.dp)
						contentWidth: accounts.width
						contentHeight: accounts.height
						Accounts{
							id: accounts
							onAddAccountRequest: mainItem.addAccountRequest()
						}
					}
				}
				PopupButton {
					id: settingsButton
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					popup.x: width - popup.width
					popup.width: 271 * DefaultStyle.dp
					popup.contentItem: ColumnLayout {
						spacing: 20 * DefaultStyle.dp
						IconLabelButton {
							Layout.preferredHeight: 32 * DefaultStyle.dp
							iconSize: 32 * DefaultStyle.dp
							text: qsTr("Mon compte")
							iconSource: AppIcons.manageProfile
							onClicked: console.log("TODO : manage profile")
						}
						IconLabelButton {
							Layout.preferredHeight: 32 * DefaultStyle.dp
							iconSize: 32 * DefaultStyle.dp
							text: qsTr("Paramètres")
							iconSource: AppIcons.settings
						}
						IconLabelButton {
							Layout.preferredHeight: 32 * DefaultStyle.dp
							iconSize: 32 * DefaultStyle.dp
							text: qsTr("Enregistrements")
							iconSource: AppIcons.micro
						}
						IconLabelButton {
							Layout.preferredHeight: 32 * DefaultStyle.dp
							iconSize: 32 * DefaultStyle.dp
							text: qsTr("Aide")
							iconSource: AppIcons.question
						}
						Rectangle {
							Layout.fillWidth: true
							Layout.preferredHeight: 1 * DefaultStyle.dp
							color: DefaultStyle.main2_400
						}
						IconLabelButton {
							Layout.preferredHeight: 32 * DefaultStyle.dp
							iconSize: 32 * DefaultStyle.dp
							text: qsTr("Ajouter un compte")
							iconSource: AppIcons.plusCircle
							onClicked: mainItem.addAccountRequest()
						}
					}
				}
			}
			StackLayout {
				// width: parent.width
				// height: parent.height
				id: mainStackLayout
				currentIndex: tabbar.currentIndex

				CallPage {
					id: callPage
				}
				ContactPage{}
				//ConversationPage{}
				//MeetingPage{}
			}
		}
	}
} 
 
