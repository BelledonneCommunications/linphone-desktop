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
	property var contextualMenuOpenedComponent: undefined
	
	signal addAccountRequest()
	signal openNewCallRequest()
	signal openCallHistory()
	signal openNumPadRequest()
	signal displayContactRequested(string contactAddress)
	signal createContactRequested(string name, string address)

	function goToNewCall() {
		tabbar.currentIndex = 0
		mainItem.openNewCallRequest()
	}
	function goToCallHistory() {
		tabbar.currentIndex = 0
		mainItem.openCallHistory()
	}
	function displayContactPage(contactAddress) {
		tabbar.currentIndex = 1
		mainItem.displayContactRequested(contactAddress)
	}

	function createContact(name, address) {
		tabbar.currentIndex = 1
		mainItem.createContactRequested(name, address)
	}
	
	function openContextualMenuComponent(component) {
		if (mainItem.contextualMenuOpenedComponent && mainItem.contextualMenuOpenedComponent != component) {
			mainStackView.pop()
			mainItem.contextualMenuOpenedComponent = undefined
		}
		if (!mainItem.contextualMenuOpenedComponent) {
			mainStackView.push(component)
			mainItem.contextualMenuOpenedComponent = component
		}
		settingsButton.popup.close()
	}
	
	function closeContextualMenuComponent() {
		mainStackView.pop()
		mainItem.contextualMenuOpenedComponent = undefined
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
				currentIndex: SettingsCpp.getLastActiveTabIndex()
				model: [
					{icon: AppIcons.phone, selectedIcon: AppIcons.phoneSelected, label: qsTr("Appels")},
					{icon: AppIcons.adressBook, selectedIcon: AppIcons.adressBookSelected, label: qsTr("Contacts")},
					{icon: AppIcons.chatTeardropText, selectedIcon: AppIcons.chatTeardropTextSelected, label: qsTr("Conversations"), visible: !SettingsCpp.disableChatFeature},
					{icon: AppIcons.videoconference, selectedIcon: AppIcons.videoconferenceSelected, label: qsTr("Réunions"), visible: !SettingsCpp.disableMeetingsFeature}
				]
				onCurrentIndexChanged: {
					SettingsCpp.setLastActiveTabIndex(currentIndex)
                    if (currentIndex === 0) accountProxy.defaultAccount.core.lResetMissedCalls()
					if (mainItem.contextualMenuOpenedComponent) {
						closeContextualMenuComponent()
					}
				}
				Keys.onPressed: (event)=>{
					if(event.key == Qt.Key_Right){
						mainStackView.currentItem.forceActiveFocus()
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
						numericPadButton.visible: text.length === 0
						numericPadButton.checkable: false
						Connections {
							target: magicSearchBar.numericPadButton
							function onClicked() {
								mainItem.goToNewCall()
								mainItem.openNumPadRequest()
							}
						}
						onTextChanged: {
							if (text.length != 0) listPopup.open()
							else listPopup.close()
						}
						KeyNavigation.down: contactList.count > 0 ? contactList : contactList.footerItem
						KeyNavigation.up: contactList.footerItem
						
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
							property int maxHeight: 400 * DefaultStyle.dp
							property bool displayScrollbar: contactList.contentHeight + topPadding + bottomPadding> maxHeight
							height: Math.min(contactList.contentHeight + topPadding + bottomPadding, maxHeight)
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
									border.color: DefaultStyle.main1_500_main
									border.width: contactList.activeFocus ? 2 : 0
									
								}
								MultiEffect {
									source: popupBg
									anchors.fill: popupBg
									shadowEnabled: true
									shadowBlur: 1
									shadowColor: DefaultStyle.grey_1000
									shadowOpacity: 0.1
								}
								ScrollBar {
									id: scrollbar
									Component.onCompleted: x = -10 * DefaultStyle.dp
									policy: Control.ScrollBar.AsNeeded// Don't work as expected
									visible: listPopup.displayScrollbar
									interactive: true
									anchors.top: parent.top
									anchors.bottom: parent.bottom
									anchors.right: parent.right
									anchors.margins: 10 * DefaultStyle.dp
									
								}
							}
							contentItem: ContactsList {
								id: contactList
								visible: magicSearchBar.text.length != 0
								Layout.preferredHeight: contentHeight
								Layout.fillWidth: true
								Layout.rightMargin: 5 * DefaultStyle.dp
								initialHeadersVisible: false
								contactMenuVisible: false
								actionLayoutVisible: true
								selectionEnabled: false
								Control.ScrollBar.vertical: scrollbar
								model: MagicSearchProxy {
									searchText: magicSearchBar.text.length === 0 ? "*" : magicSearchBar.text
									aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
								}
								
								Keys.onPressed: (event) => {
									if(event.key == Qt.Key_Down){
										if(contactList.currentIndex == contactList.count -1) {
											contactList.currentIndex = -1
											contactList.footerItem.forceActiveFocus()
											event.accepted = true
										}
									} else if(event.key == Qt.Key_Up){
										if(contactList.currentIndex <= 0) {
											contactList.currentIndex = -1
											contactList.footerItem.forceActiveFocus()
											event.accepted = true
										}
									}
								}
								header: Text {
									visible: contactList.count > 0
									text: qsTr("Contact")
									color: DefaultStyle.main2_500main
									font {
										pixelSize: 13 * DefaultStyle.dp
										weight: 700 * DefaultStyle.dp
									}
								}
								footer:  FocusScope{
									id: suggestionFocusScope
									width: contactList.width
									height: content.implicitHeight
									onActiveFocusChanged: if(activeFocus) contactList.positionViewAtEnd()
									Rectangle{
										anchors.left: parent.left
										anchors.right: parent.right
										anchors.bottom: parent.bottom
										height: suggestionRow.implicitHeight
										color: suggestionFocusScope.activeFocus ? DefaultStyle.numericPadPressedButtonColor : 'transparent'
									}
									ColumnLayout {
										id: content
										anchors.fill: parent
										anchors.rightMargin: 5 * DefaultStyle.dp
										
										spacing: 10 * DefaultStyle.dp			
										Text {
											text: qsTr("Suggestion")
											color: DefaultStyle.main2_500main
											font {
												pixelSize: 13 * DefaultStyle.dp
												weight: 700 * DefaultStyle.dp
											}
										}
										
										Keys.onPressed: (event) => {
											if(contactList.count <= 0) return;
											if(event.key == Qt.Key_Down){
												contactList.currentIndex = 0
												event.accepted = true
											} else if(event.key == Qt.Key_Up){
												contactList.currentIndex = contactList.count - 1
												event.accepted = true
											}
										}
										RowLayout {
											id: suggestionRow
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
												id: callButton
												Layout.preferredWidth: 45 * DefaultStyle.dp
												Layout.preferredHeight: 45 * DefaultStyle.dp
												icon.source: AppIcons.phone
												focus: true
												onClicked: {
													UtilsCpp.createCall(magicSearchBar.text)
													magicSearchBar.clearText()
												}
												KeyNavigation.right: chatButton
												KeyNavigation.left: chatButton
											}
											MagicSearchButton {
												id: chatButton
												// TODO : visible true when chat available
												// visible: false
												Layout.preferredWidth: 45 * DefaultStyle.dp
												Layout.preferredHeight: 45 * DefaultStyle.dp
												icon.source: AppIcons.chatTeardropText
												KeyNavigation.right: callButton
												KeyNavigation.left: callButton
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
							Layout.preferredWidth: 54 * DefaultStyle.dp
							Layout.preferredHeight: width
							popup.padding: 14 * DefaultStyle.dp
							contentItem: Avatar {
								id: avatar
								height: avatarButton.height
								width: avatarButton.width
								account: accountProxy.defaultAccount
							}
							popup.contentItem: ColumnLayout {
								Accounts {
									id: accounts
									accountProxy: accountProxy
									onAddAccountRequest: mainItem.addAccountRequest()
								}
							}
						}
						PopupButton {
							id: settingsMenuButton
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							popup.width: 271 * DefaultStyle.dp
							popup.padding: 14 * DefaultStyle.dp
							popup.contentItem: FocusScope {
								id: popupFocus
								implicitHeight: settingsButtons.implicitHeight
								Keys.onPressed: (event)=> {
										if (event.key == Qt.Key_Left || event.key == Qt.Key_Escape) {
											settingsMenuButton.popup.close()
										event.accepted = true;
									}
								}
								ColumnLayout {
									id: settingsButtons
									anchors.fill: parent
									spacing: 20 * DefaultStyle.dp
									
									function getPreviousItem(index){
										if(visibleChildren.length == 0) return null
										--index
										while(index >= 0){
											if( index!= 4 && children[index].visible) return children[index]
											--index
										}
										return getPreviousItem(children.length)
									}
									function getNextItem(index){
										++index
										while(index < children.length){
											if( index!= 4 && children[index].visible) return children[index]
											++index
										}
										return getNextItem(-1)
									}
									
									IconLabelButton {
										id: accountButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										visible: !SettingsCpp.hideAccountSettings
										focus: visible
										iconSize: 32 * DefaultStyle.dp
										text: qsTr("Mon compte")
										iconSource: AppIcons.manageProfile
										onClicked: openContextualMenuComponent(myAccountSettingsPageComponent)
										KeyNavigation.up: visibleChildren.length != 0 ? settingsButtons.getPreviousItem(0) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsButtons.getNextItem(0) : null
									}
									IconLabelButton {
										id: settingsButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										visible: !SettingsCpp.hideSettings
										focus: !accountButton.visible && visible
										iconSize: 32 * DefaultStyle.dp
										text: qsTr("Paramètres")
										iconSource: AppIcons.settings
										onClicked:  openContextualMenuComponent(settingsPageComponent)
										KeyNavigation.up: visibleChildren.length != 0 ? settingsButtons.getPreviousItem(1) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsButtons.getNextItem(1) : null
									}
									IconLabelButton {
										id: recordsButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										visible: !SettingsCpp.disableCallRecordingsFeature
										focus: !accountButton.visible && !settingsButton.visible && visible
										iconSize: 32 * DefaultStyle.dp
										text: qsTr("Enregistrements")
										iconSource: AppIcons.micro
										KeyNavigation.up: visibleChildren.length != 0 ?  settingsButtons.getPreviousItem(2) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsButtons.getNextItem(2) : null
									}
									IconLabelButton {
										id: helpButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										iconSize: 32 * DefaultStyle.dp
										focus: !accountButton.visible && !settingsButton.visible && !recordsButton.visible
										text: qsTr("Aide")
										iconSource: AppIcons.question
										onClicked: openContextualMenuComponent(helpPageComponent)
										KeyNavigation.up: visibleChildren.length != 0 ? settingsButtons.getPreviousItem(3) : null
										KeyNavigation.down: visibleChildren.length != 0 ?  settingsButtons.getNextItem(3) : null
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
										Layout.fillWidth: true
										visible: SettingsCpp.maxAccount == 0 || SettingsCpp.maxAccount > accountProxy.count
										iconSize: 32 * DefaultStyle.dp
										text: qsTr("Ajouter un compte")
										iconSource: AppIcons.plusCircle
										onClicked: mainItem.addAccountRequest()
										KeyNavigation.up: visibleChildren.length != 0 ? settingsButtons.getPreviousItem(5) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsButtons.getNextItem(5) : null
									}
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
						onActiveFocusChanged: if(activeFocus) children[currentIndex].forceActiveFocus()
						CallPage {
							id: callPage
							Connections {
								target: mainItem
								function onOpenNewCallRequest(){ callPage.goToNewCall()}
								function onOpenCallHistory(){ callPage.goToCallHistory()}
								function onOpenNumPadRequest(){ callPage.openNumPadRequest()}
							}
							onCreateContactRequested: (name, address) => {
								mainItem.createContact(name, address)
							}
						}
						ContactPage{
							id: contactPage
							Connections {
								target: mainItem
								function onCreateContactRequested(name, address) {
									contactPage.createContact(name, address)
								}
								function onDisplayContactRequested(contactAddress) {
									contactPage.initialFriendToDisplay = contactAddress
								}
							}
						}
						Item{}
						//ConversationPage{}
						MeetingPage{}
					}
				}
				Component {
					id: myAccountSettingsPageComponent
					AccountSettingsPage {
						account: accountProxy.defaultAccount
						onGoBack: closeContextualMenuComponent()
					}
				}
				Component {
					id: settingsPageComponent
					SettingsPage {
						onGoBack: closeContextualMenuComponent()
					}
				}
				Component {
					id: helpPageComponent
					HelpPage {
						onGoBack: closeContextualMenuComponent()
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
 
