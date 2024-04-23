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
	property var callObj
	
	signal addAccountRequest()

	function goToNewCall() {
		tabbar.currentIndex = 0
		callPage.goToNewCall()
	}

	function transferCallSucceed() {
		transferSucceedPopup.open()
	}

	function createContact(name, address) {
		tabbar.currentIndex = 1
		contactPage.createContact(name, address)
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
				imageSource: AppIcons.smiley
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
	Item{
		anchors.fill: parent
		ColumnLayout{
			anchors.fill: parent
			spacing: 0
			Rectangle{
				Layout.fillWidth: true
				Layout.fillHeight: true
				color: DefaultStyle.grey_0
			}
			RowLayout{
				Layout.fillWidth: true
				Layout.preferredHeight: tabbar.cornerRadius
				spacing: 0
				Item{// Transparent corner
					Layout.fillHeight: true
					Layout.preferredWidth: tabbar.cornerRadius
				}
				Rectangle{
					Layout.fillWidth: true
					Layout.fillHeight: true	
					color: DefaultStyle.grey_0
				}
			}
		}
		
		RowLayout {
			anchors.fill: parent
			spacing: 0
			anchors.topMargin: 25 * DefaultStyle.dp
			VerticalTabBar {
				id: tabbar
				Layout.fillHeight: true
				Layout.preferredWidth: 82 * DefaultStyle.dp
				model: [
					{icon: AppIcons.phone, selectedIcon: AppIcons.phoneSelected, label: qsTr("Appels")},
					{icon: AppIcons.adressBook, selectedIcon: AppIcons.adressBookSelected, label: qsTr("Contacts")},
					{icon: AppIcons.chatTeardropText, selectedIcon: AppIcons.chatTeardropTextSelected, label: qsTr("Conversations")},
					{icon: AppIcons.videoconference, selectedIcon: AppIcons.videoconferenceSelected, label: qsTr("Réunions")}
				]

			}
			ColumnLayout {
				spacing:0

				RowLayout {
					id: topRow
					Layout.preferredHeight: 50 * DefaultStyle.dp
					Layout.leftMargin: 45 * DefaultStyle.dp
					Layout.rightMargin: 41 * DefaultStyle.dp
					spacing: 25 * DefaultStyle.dp
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
							width: magicSearchBar.width
							height: Math.min(magicSearchList.contentHeight + topPadding + bottomPadding, 400 * DefaultStyle.dp)
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
							ScrollBar {
								id: scrollbar
								height: parent.height
								anchors.right: listPopup.right
							}
							contentItem: ContactsList {
								id: magicSearchList
								visible: magicSearchBar.text.length != 0
								height: contentHeight
								width: magicSearchBar.width
								headerPositioning: ListView.OverlayHeader
								rightMargin: 15 * DefaultStyle.dp
								initialHeadersVisible: false
								contactMenuVisible: false
								actionLayoutVisible: true
								model: MagicSearchProxy {
									searchText: magicSearchBar.text.length === 0 ? "*" : magicSearchBar.text
									aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
								}
								Control.ScrollBar.vertical: scrollbar
								header: Control.Control {
									z: 2
									width: magicSearchList.width
									leftPadding: 10 * DefaultStyle.dp
									rightPadding: 10 * DefaultStyle.dp
									background: Rectangle {
										color: DefaultStyle.grey_0
									}
									contentItem: ColumnLayout {
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
													anchors.fill: parent
													source: AppIcons.phone
												}
												onClicked: {
													UtilsCpp.createCall(sipAddr.text)
												}
											}
											Button {
												Layout.preferredWidth: 24 * DefaultStyle.dp
												Layout.preferredHeight: 24 * DefaultStyle.dp
												background: Item{}
												contentItem: Image {
													anchors.fill: parent
													source: AppIcons.videoCamera
												}
												onClicked: UtilsCpp.createCall(sipAddr.text, {'localVideoEnabled':true})
											}
										}
										Button {
											Layout.fillWidth: true
											Layout.preferredHeight: 30 * DefaultStyle.dp
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
												mainItem.createContact(magicSearchBar.text, sipAddr.text)
												listPopup.close()
											}
										}
									}
								}
							}
						}
					}
					RowLayout {
						spacing: 10 * DefaultStyle.dp
						PopupButton {
							id: avatarButton
							AccountProxy{
								id: accountProxy
								//property bool haveAvatar: defaultAccount && defaultAccount.core.pictureUri || false
							}
							background.visible: false
							Layout.preferredWidth: 54 * DefaultStyle.dp
							Layout.preferredHeight: width
							contentItem: Avatar {
								id: avatar
								height: avatarButton.height
								width: avatarButton.width
								account: accountProxy.defaultAccount
							}
							popup.x: width - popup.width
							popup.padding: 0
							popup.contentItem: ColumnLayout {
								Accounts {
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
				}
				StackLayout {
					id: mainStackLayout
					currentIndex: tabbar.currentIndex
					Layout.topMargin: 24 * DefaultStyle.dp
					CallPage {
						id: callPage
						onCreateContactRequested: (name, address) => {
							mainItem.createContact(name, address)
						}
					}
					ContactPage{
						id: contactPage
					}
					Item{}
					//ConversationPage{}
					MeetingPage{}
				}
			}
		}
	}
} 
 
