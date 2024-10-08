/**
* Qml template used for welcome and login/register pages
**/

import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp
import LinphoneAccountsCpp

Item {
	id: mainItem
	property var callObj
	property var contextualMenuOpenedComponent: undefined
	
	signal addAccountRequest()
	signal openNewCallRequest()
	signal callCreated()
	signal openCallHistory()
	signal openNumPadRequest()
	signal displayContactRequested(string contactAddress)
	signal createContactRequested(string name, string address)
	signal accountRemoved()


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
		settingsMenuButton.popup.close()
	}
	
	function closeContextualMenuComponent() {
		mainStackView.pop()
		mainItem.contextualMenuOpenedComponent = undefined
	}

	function openAccountSettings(account: AccountGui) {
		var page = accountSettingsPageComponent.createObject(parent, {"account": account});
		openContextualMenuComponent(page)
	}

	AccountProxy  {
		id: accountProxy
		onDefaultAccountChanged: if (tabbar.currentIndex === 0 && defaultAccount) defaultAccount.core?.lResetMissedCalls()
	}

	CallProxy {
		id: callsModel
	}


	Item{
		Popup {
			id: currentCallNotif
			background: Item{}
			closePolicy: Control.Popup.NoAutoClose
			visible: currentCall
				&& currentCall.core.state != LinphoneEnums.CallState.Idle 
				&& currentCall.core.state != LinphoneEnums.CallState.IncomingReceived
				&& currentCall.core.state != LinphoneEnums.CallState.PushIncomingReceived
			x: mainItem.width/2 - width/2
			y: contentItem.height/2
			property var currentCall: callsModel.currentCall ? callsModel.currentCall : null
			property var peerNameObj: currentCall ? UtilsCpp.getDisplayName(currentCall.core.peerAddress) : null
			property string peerName:peerNameObj ? peerNameObj.value : ""
			contentItem: Button {
				text: currentCallNotif.currentCall 
				? currentCallNotif.currentCall.core.conference
					? ("Réunion en cours : ") + currentCallNotif.currentCall.core.conference.core.subject
					: (("Appel en cours : ") + currentCallNotif.peerName) : "appel en cours"
				color: DefaultStyle.success_500main
				onClicked: {
					var callsWindow = UtilsCpp.getCallsWindow(currentCallNotif.currentCall)
					UtilsCpp.smartShowWindow(callsWindow)
				}
			}
		}
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
				currentIndex: SettingsCpp.getLastActiveTabIndex()
				Binding on currentIndex {
					when: mainItem.contextualMenuOpenedComponent != undefined
					value: -1
					restoreMode: Binding.RestoreBindingOrValue
				}
				model: [
					{icon: AppIcons.phone, selectedIcon: AppIcons.phoneSelected, label: qsTr("Appels")},
					{icon: AppIcons.adressBook, selectedIcon: AppIcons.adressBookSelected, label: qsTr("Contacts")},
					{icon: AppIcons.chatTeardropText, selectedIcon: AppIcons.chatTeardropTextSelected, label: qsTr("Conversations"), visible: !SettingsCpp.disableChatFeature},
					{icon: AppIcons.videoconference, selectedIcon: AppIcons.videoconferenceSelected, label: qsTr("Réunions"), visible: !SettingsCpp.disableMeetingsFeature}
				]
				onCurrentIndexChanged: {
					if (currentIndex == -1) return
					SettingsCpp.setLastActiveTabIndex(currentIndex)
                    if (currentIndex === 0 && accountProxy.defaultAccount) accountProxy.defaultAccount.core?.lResetMissedCalls()
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
						placeholderText: SettingsCpp.disableChatFeature ? qsTr("Rechercher un contact, appeler...") : qsTr("Rechercher un contact, appeler ou envoyer un message...")
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
									shadowBlur: 0.1
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
							contentItem: ContactListView {
								id: contactList
								visible: magicSearchBar.text.length != 0
								Layout.preferredHeight: contentHeight
								Layout.fillWidth: true
								Layout.rightMargin: 5 * DefaultStyle.dp
								initialHeadersVisible: false
								contactMenuVisible: false
								actionLayoutVisible: true
								selectionEnabled: false
								showDefaultAddress: true
								Control.ScrollBar.vertical: scrollbar
								searchText: magicSearchBar.text
								
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
												_address: magicSearchBar.text
											}
											Text {
												text: UtilsCpp.interpretUrl(magicSearchBar.text)
												font {
													pixelSize: 12 * DefaultStyle.dp
													weight: 300 * DefaultStyle.dp
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
												visible: !SettingsCpp.disableChatFeature
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
							id: deactivateDndButton
							Layout.preferredWidth: 32 * DefaultStyle.dp
							Layout.preferredHeight: 32 * DefaultStyle.dp
							popup.padding: 14 * DefaultStyle.dp
							visible: SettingsCpp.dnd
							contentItem: EffectImage {
								imageSource: AppIcons.bellDnd
								width: 32 * DefaultStyle.dp
								height: 32 * DefaultStyle.dp
								Layout.preferredWidth: 32 * DefaultStyle.dp
								Layout.preferredHeight: 32 * DefaultStyle.dp
								fillMode: Image.PreserveAspectFit
								colorizationColor: DefaultStyle.main1_500_main
							}
							popup.contentItem: ColumnLayout {
								IconLabelButton {
									Layout.preferredHeight: 32 * DefaultStyle.dp
									Layout.fillWidth: true
									focus: visible
									iconSize: 32 * DefaultStyle.dp
									text: qsTr("Désactiver ne pas déranger")
									iconSource: AppIcons.bellDnd
									onClicked: {
										deactivateDndButton.popup.close()
										SettingsCpp.dnd = false
									}
								}
							}
						}
						Voicemail {
							id: voicemail
							Layout.preferredWidth: 27 * DefaultStyle.dp
							Layout.preferredHeight: 28 * DefaultStyle.dp
							
							function cumulatedVoicemailCount() {
								var count = 0
								for (var i=0 ; i < accountProxy.count ; i++ )
									count += accountProxy.getAt(i).core.voicemailCount
								return count
							}
							
							voicemailCount: cumulatedVoicemailCount()
							onClicked: {
								if (accountProxy.count > 1) {
									avatarButton.popup.open()
								} else {
									if (accountProxy.defaultAccount.core.mwiServerAddress.length > 0)
										UtilsCpp.createCall(accountProxy.defaultAccount.core.mwiServerAddress)
									else
										UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("L'adresse de la messagerie vocale n'est pas définie."), false)
								}
							}
						}
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
								AccountListView {
									id: accounts
									onAddAccountRequest: mainItem.addAccountRequest()
									onEditAccount: function(account) {
										avatarButton.popup.close()
										openAccountSettings(account)
									}
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
										onClicked: openAccountSettings(accountProxy.defaultAccount ? accountProxy.defaultAccount : accountProxy.firstAccount())
										KeyNavigation.up: visibleChildren.length != 0 ? settingsButtons.getPreviousItem(0) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsButtons.getNextItem(0) : null
									}
									IconLabelButton {
										id: dndButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										iconSize: 32 * DefaultStyle.dp
										text: SettingsCpp.dnd ? qsTr("Désactiver ne pas déranger") : qsTr("Activer ne pas déranger")
										iconSource: AppIcons.bellDnd
										onClicked: {
											settingsMenuButton.popup.close()
											SettingsCpp.dnd = !SettingsCpp.dnd
										}
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
										visible: !SettingsCpp.disableCallRecordings
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
									IconLabelButton {
										id: quitButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										focus: !accountButton.visible && !settingsButton.visible && visible
										iconSize: 32 * DefaultStyle.dp
										text: qsTr("Quitter Linphone")
										iconSource: AppIcons.power
										onClicked: {
												settingsMenuButton.popup.close()
												UtilsCpp.getMainWindow().showConfirmationLambdaPopup(
												qsTr("Quitter Linphone ?"),
												"",
												function (confirmed) {
													if (confirmed) {
														console.info("Exiting App from Top Menu");
														Qt.quit()
													}
												}
											)
										}
										KeyNavigation.up: visibleChildren.length != 0 ?  settingsButtons.getPreviousItem(4) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsButtons.getNextItem(4) : null
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
						onActiveFocusChanged: if(activeFocus && currentIndex >= 0) children[currentIndex].forceActiveFocus()
						CallPage {
							id: callPage
							Connections {
								target: mainItem
								function onOpenNewCallRequest(){ callPage.goToNewCall()}
								function onCallCreated(){ callPage.resetLeftPanel()}
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
					id: accountSettingsPageComponent
					AccountSettingsPage {
						onGoBack: closeContextualMenuComponent()
						onAccountRemoved: mainItem.accountRemoved()
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
 
