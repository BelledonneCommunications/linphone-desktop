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
import SettingsCpp

Item {
	id: mainItem
	property var callObj
	property bool settingsHidden: true
	property bool helpHidden: true
													
	signal addAccountRequest()
	signal openNewCall()
	signal openCallHistory()
	signal displayContact(string contactAddress)
	signal createContactRequested(string name, string address)

	function goToNewCall() {
		tabbar.currentIndex = 0
		mainItem.openNewCall()
	}
	function goToCallHistory() {
		tabbar.currentIndex = 0
		mainItem.openCallHistory()
	}
	function goToContactPage(contactAddress) {
		tabbar.currentIndex = 1
		mainItem.displayContact(contactAddress)
	}

	function createContact(name, address) {
		tabbar.currentIndex = 1
		mainItem.createContactRequested(name, address)
	}

	AccountProxy {
		id: accountProxy
		onDefaultAccountChanged: if (tabbar.currentIndex === 0) defaultAccount.core.lResetMissedCalls()
	}

	Timer {
		id: autoClosePopup
		interval: 5000
		onTriggered: {
			transferSucceedPopup.close()
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
				defaultAccount: accountProxy.defaultAccount
				property int unreadMessages: defaultAccount.core.unreadMessageNotifications
				model: [
					{icon: AppIcons.phone, selectedIcon: AppIcons.phoneSelected, label: qsTr("Appels")},
					{icon: AppIcons.adressBook, selectedIcon: AppIcons.adressBookSelected, label: qsTr("Contacts")},
					{icon: AppIcons.chatTeardropText, selectedIcon: AppIcons.chatTeardropTextSelected, label: qsTr("Conversations"), visible: !SettingsCpp.disableChatFeature},
					{icon: AppIcons.videoconference, selectedIcon: AppIcons.videoconferenceSelected, label: qsTr("Réunions"), visible: !SettingsCpp.disableMeetingsFeature}
				]
				onCurrentIndexChanged: {
                    if (currentIndex === 0) accountProxy.defaultAccount.core.lResetMissedCalls()
					if (!mainItem.settingsHidden) {
						mainStackView.pop()
						mainItem.settingsHidden = true
					}
					if (!mainItem.helpHidden) {
						mainStackView.pop()
						mainItem.helpHidden = true
					}
				}
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
						focusedBorderColor: DefaultStyle.main1_500_main
						onTextChanged: {
							if (text.length != 0) listPopup.open()
							else listPopup.close()
						}
						component MagicSearchButton: Button {
							id: button
							width: 45 * DefaultStyle.dp
							height: 45 * DefaultStyle.dp
							topPadding: 16 * DefaultStyle.dp
							bottomPadding: 16 * DefaultStyle.dp
							leftPadding: 16 * DefaultStyle.dp
							rightPadding: 16 * DefaultStyle.dp
							contentImageColor: DefaultStyle.main2_500main
							icon.width: 24 * DefaultStyle.dp
							icon.height: 24 * DefaultStyle.dp
							background: Rectangle {
								anchors.fill: parent
								radius: 40 * DefaultStyle.dp
								color: DefaultStyle.main2_200
							}
						}

						Popup {
							id: listPopup
							width: magicSearchBar.width
							height: Math.min(magicSearchContent.contentHeight + topPadding + bottomPadding, 400 * DefaultStyle.dp)
							y: magicSearchBar.height
							// closePolicy: Popup.NoAutoClose
							topPadding: 20 * DefaultStyle.dp
							bottomPadding: 20 * DefaultStyle.dp
							rightPadding: 20 * DefaultStyle.dp
							leftPadding: 20 * DefaultStyle.dp
							
							background: Item {
								anchors.fill: parent
								Rectangle {
									id: popupBg
									radius: 16 * DefaultStyle.dp
									color: DefaultStyle.grey_0
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
							
							contentItem: Control.ScrollView {
								id: magicSearchContent
								contentWidth: width
								contentHeight: content.height
								Control.ScrollBar.vertical: ScrollBar {
									id: scrollbar
									policy: Control.ScrollBar.AsNeeded
									interactive: true
									height: magicSearchContent.availableHeight
									anchors.top: listPopup.top
									anchors.bottom: listPopup.bottom
									anchors.right: parent.right
								}
								ColumnLayout {
									id: content
									spacing: 10 * DefaultStyle.dp
									width: magicSearchContent.width - scrollbar.width - 5 * DefaultStyle.dp
									Text {
										visible: contactList.count > 0
										text: qsTr("Contact")
										color: DefaultStyle.main2_500main
										font {
											pixelSize: 13 * DefaultStyle.dp
											weight: 700 * DefaultStyle.dp
										}
									}
									ContactsList {
										id: contactList
										visible: magicSearchBar.text.length != 0
										Layout.preferredHeight: contentHeight
										Layout.fillWidth: true
										Layout.rightMargin: 5 * DefaultStyle.dp
										initialHeadersVisible: false
										contactMenuVisible: false
										actionLayoutVisible: true
										selectionEnabled: false
										Control.ScrollBar.vertical.visible: false
										model: MagicSearchProxy {
											searchText: magicSearchBar.text.length === 0 ? "*" : magicSearchBar.text
											aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
										}
									}
									Text {
										text: qsTr("Suggestion")
										color: DefaultStyle.main2_500main
										font {
											pixelSize: 13 * DefaultStyle.dp
											weight: 700 * DefaultStyle.dp
										}
									}
									RowLayout {
										Layout.fillWidth: true
										Layout.rightMargin: 5 * DefaultStyle.dp
										spacing: 10 * DefaultStyle.dp
										Avatar {
											Layout.preferredWidth: 45 * DefaultStyle.dp
											Layout.preferredHeight: 45 * DefaultStyle.dp
											address: magicSearchBar.text
										}
										ColumnLayout {
											Text {
												text: magicSearchBar.text
												font {
													pixelSize: 12 * DefaultStyle.dp
													weight: 300 * DefaultStyle.dp
												}
											}
										}
										Item {
											Layout.fillWidth: true
										}
										MagicSearchButton {
											Layout.preferredWidth: 45 * DefaultStyle.dp
											Layout.preferredHeight: 45 * DefaultStyle.dp
											icon.source: AppIcons.phone
											onClicked: {
												UtilsCpp.createCall(magicSearchBar.text)
												magicSearchBar.clearText()
											}
										}
										MagicSearchButton {
											// TODO : visible true when chat available
											// visible: false
											Layout.preferredWidth: 45 * DefaultStyle.dp
											Layout.preferredHeight: 45 * DefaultStyle.dp
											icon.source: AppIcons.chatTeardropText
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
									accountProxy: accountProxy
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
									visible: !SettingsCpp.hideAccountSettings
									iconSize: 32 * DefaultStyle.dp
									text: qsTr("Mon compte")
									iconSource: AppIcons.manageProfile
									onClicked: console.log("TODO : manage profile")
								}
								IconLabelButton {
									Layout.preferredHeight: 32 * DefaultStyle.dp
									visible: !SettingsCpp.hideSettings
									iconSize: 32 * DefaultStyle.dp
									text: qsTr("Paramètres")
									iconSource: AppIcons.settings
									onClicked: {
										if (!mainItem.helpHidden) {
											mainStackView.pop()
											mainItem.helpHidden = true
										}
										if (mainItem.settingsHidden) {
											mainStackView.push(settingsPageComponent)
											settingsButton.popup.close()
											mainItem.settingsHidden = false
										} else {
											settingsButton.popup.close()
										}
									}
								}
								IconLabelButton {
									Layout.preferredHeight: 32 * DefaultStyle.dp
									visible: !SettingsCpp.disableCallRecordingsFeature
									iconSize: 32 * DefaultStyle.dp
									text: qsTr("Enregistrements")
									iconSource: AppIcons.micro
								}
								IconLabelButton {
									Layout.preferredHeight: 32 * DefaultStyle.dp
									iconSize: 32 * DefaultStyle.dp
									text: qsTr("Aide")
									iconSource: AppIcons.question
									onClicked: {
										if (!mainItem.settingsHidden) {
											mainStackView.pop()
											mainItem.settingsHidden = true
										}
										if (mainItem.helpHidden) {
											mainStackView.push(helpPageComponent)
											settingsButton.popup.close()
											mainItem.helpHidden = false
										} else {
											settingsButton.popup.close()
										}
									}
								}
								Rectangle {
									Layout.fillWidth: true
									Layout.preferredHeight: 1 * DefaultStyle.dp
									visible: addAccountButton.visible
									color: DefaultStyle.main2_400
								}
								IconLabelButton {
									id: addAccountButton
									Layout.preferredHeight: 32 * DefaultStyle.dp
									visible: SettingsCpp.maxAccount == 0 || SettingsCpp.maxAccount > accountProxy.count
									iconSize: 32 * DefaultStyle.dp
									text: qsTr("Ajouter un compte")
									iconSource: AppIcons.plusCircle
									onClicked: mainItem.addAccountRequest()
								}
							}
						}
					}
				}
				Component {
					id: mainStackLayoutComponent
					StackLayout {
						id: mainStackLayout
						currentIndex: tabbar.currentIndex
						CallPage {
							id: callPage
							Connections {
								target: mainItem
								function onOpenNewCall(){ callPage.goToNewCall()}
								function onOpenCallHistory(){ callPage.goToCallHistory()}
							}
							onCreateContactRequested: (name, address) => {
								mainItem.createContact(name, address)
							}
						}
						ContactPage{
							id: contactPage
							Connections {
								target: mainItem
								function onCreateContactRequested (name, address) {
									contactPage.createContact(name, address)
								}
								function onDisplayContact (contactAddress) {
									contactPage.displayContact(contactAddress)
								}		
							}
						}
						Item{}
						//ConversationPage{}
						MeetingPage{}
					}
				}
				Component {
					id: settingsPageComponent
					SettingsPage {
						onGoBack: {
							mainStackView.pop()
							mainItem.settingsHidden = true
						}
					}
				}
				Component {
					id: helpPageComponent
					HelpPage {
						onGoBack: {
							mainStackView.pop()
							mainItem.helpHidden = true
						}
					}
				}
				Control.StackView {
					id: mainStackView
					property Transition noTransition: Transition {
						PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0 }
					}
					pushEnter: noTransition
					pushExit: noTransition
					popEnter: noTransition
					popExit: noTransition
					Layout.topMargin: 24 * DefaultStyle.dp
					Layout.fillWidth: true
					Layout.fillHeight: true
					initialItem: mainStackLayoutComponent
				}
			}
		}
	}
} 
 
