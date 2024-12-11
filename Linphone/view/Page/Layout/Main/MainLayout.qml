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
		sourceModel: AppCpp.accounts
		onDefaultAccountChanged: if (tabbar.currentIndex === 0 && defaultAccount) defaultAccount.core?.lResetMissedCalls()
	}

	CallProxy {
		id: callsModel
		sourceModel: AppCpp.calls
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
			property string remoteName: currentCall ? currentCall.core.remoteName : ""
			contentItem: Button {
				text: currentCallNotif.currentCall 
				? currentCallNotif.currentCall.core.conference
					? ("Réunion en cours : ") + currentCallNotif.currentCall.core.conference.core.subject
					: (("Appel en cours : ") + currentCallNotif.remoteName) : "appel en cours"
				color: DefaultStyle.success_500main
				onClicked: {
					var callsWindow = UtilsCpp.getCallsWindow(currentCallNotif.currentCall)
					UtilsCpp.smartShowWindow(callsWindow)
				}
			}
		}
		anchors.fill: parent
		
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
						handleNumericPadPopupButtonsPressed: false

						onOpenNumericPadRequested:mainItem.goToNewCall()
					
                        Connections {
                            target: mainItem
                            function onCallCreated() {
                                magicSearchBar.focus = false
                                magicSearchBar.clearText()
                            }
                        }

						onTextChanged: {
							if (text.length != 0) listPopup.open()
							else listPopup.close()
						}
						KeyNavigation.down: contactList //contactLoader.item?.count > 0 || !contactLoader.item?.footerItem? contactLoader.item : contactLoader.item?.footerItem
						KeyNavigation.up: contactList//contactLoader.item?.footerItem ? contactLoader.item?.footerItem : contactLoader.item
						
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
							height: contactList.haveContacts ? Math.min(contactList.contentHeight + topPadding + bottomPadding, maxHeight) : 0
							y: magicSearchBar.height
							// closePolicy: Popup.NoAutoClose
							topPadding: contactList.haveContacts ? 20 * DefaultStyle.dp : 0
							bottomPadding: contactList.haveContacts ? 20 * DefaultStyle.dp : 0
							rightPadding: 10 * DefaultStyle.dp
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
							contentItem: AllContactListView {
									id: contactList
									visible: !loading && magicSearchBar.text.length != 0
									Layout.preferredHeight: visible ? contentHeight : 0
									Layout.fillWidth: true
									itemsRightMargin: 5 * DefaultStyle.dp	//(Actions have already 10 of margin)
									showInitials: false
									showContactMenu: false
									showActions: true
									showFavorites: false
									selectionEnabled: false
									showDefaultAddress: true
									searchOnEmpty: false
									
									sectionsPixelSize: 13 * DefaultStyle.dp
									sectionsWeight: 700 * DefaultStyle.dp
									sectionsSpacing: 5 * DefaultStyle.dp
									
									Control.ScrollBar.vertical: scrollbar
									searchBarText: magicSearchBar.text
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
							Layout.preferredWidth: 42 * DefaultStyle.dp
							Layout.preferredHeight: 36 * DefaultStyle.dp
							Repeater {
								model: accountProxy
								delegate: Item {
									Connections {
										target: modelData.core
										function onShowMwiChanged() {voicemail.updateCumulatedMwi()}
										function onVoicemailAddressChanged(){voicemail.updateCumulatedMwi()}
									}
								}
							}

							function updateCumulatedMwi() {
								var count = 0
								var showMwi = false
								var supportsVoiceMail = false
								for (var i=0 ; i < accountProxy.count ; i++ ) {
									var core = accountProxy.getAt(i).core
									count += core.voicemailCount
									showMwi |= core.showMwi
									supportsVoiceMail |= core.voicemailAddress.length > 0
								}
								voicemail.showMwi = showMwi
								voicemail.voicemailCount = count
								voicemail.visible = showMwi || supportsVoiceMail
							}

							Component.onCompleted: {
								updateCumulatedMwi()
							}
							
							onClicked: {
								if (accountProxy.count > 1) {
									avatarButton.popup.open()
								} else {
									if (accountProxy.defaultAccount.core.voicemailAddress.length > 0)
										UtilsCpp.createCall(accountProxy.defaultAccount.core.voicemailAddress)
									else
										UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("L'URI de messagerie vocale n'est pas définie."), false)
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
								implicitWidth: settingsButtons.implicitWidth
								Keys.onPressed: (event)=> {
									if (event.key == Qt.Key_Left || event.key == Qt.Key_Escape) {
										settingsMenuButton.popup.close()
										event.accepted = true;
									}
								}
								
								ColumnLayout {
									id: settingsButtons
									spacing: 16 * DefaultStyle.dp
									anchors.fill: parent
									
									IconLabelButton {
										id: accountButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										visible: !SettingsCpp.hideAccountSettings
										iconSize: 32 * DefaultStyle.dp
										text: qsTr("Mon compte")
										iconSource: AppIcons.manageProfile
										onClicked: openAccountSettings(accountProxy.defaultAccount ? accountProxy.defaultAccount : accountProxy.firstAccount())
										KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(0) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(0) : null
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
										KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(1) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(1) : null
									}
									IconLabelButton {
										id: settingsButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										visible: !SettingsCpp.hideSettings
										iconSize: 32 * DefaultStyle.dp
										text: qsTr("Paramètres")
										iconSource: AppIcons.settings
										onClicked:  openContextualMenuComponent(settingsPageComponent)
										KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(2) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(2) : null
									}
									IconLabelButton {
										id: recordsButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										visible: !SettingsCpp.disableCallRecordings
										iconSize: 32 * DefaultStyle.dp
										text: qsTr("Enregistrements")
										iconSource: AppIcons.micro
										KeyNavigation.up: visibleChildren.length != 0 ?  settingsMenuButton.getPreviousItem(3) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(3) : null
									}
									IconLabelButton {
										id: helpButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										iconSize: 32 * DefaultStyle.dp
										text: qsTr("Aide")
										iconSource: AppIcons.question
										onClicked: openContextualMenuComponent(helpPageComponent)
										KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(4) : null
										KeyNavigation.down: visibleChildren.length != 0 ?  settingsMenuButton.getNextItem(4) : null
									}
									IconLabelButton {
										id: quitButton
										Layout.preferredHeight: 32 * DefaultStyle.dp
										Layout.fillWidth: true
										iconSize: 32 * DefaultStyle.dp
										text: qsTr("Quitter Linphone")
										iconSource: AppIcons.power
										onClicked: {
											settingsMenuButton.popup.close()
											UtilsCpp.getMainWindow().showConfirmationLambdaPopup("",
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
										KeyNavigation.up: visibleChildren.length != 0 ?  settingsMenuButton.getPreviousItem(5) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(5) : null
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
										KeyNavigation.up: visibleChildren.length != 0 ? settingsMenuButton.getPreviousItem(7) : null
										KeyNavigation.down: visibleChildren.length != 0 ? settingsMenuButton.getNextItem(7) : null
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
						objectName: "mainStackLayout"
						currentIndex: tabbar.currentIndex
						onActiveFocusChanged: if(activeFocus && currentIndex >= 0) children[currentIndex].forceActiveFocus()
						CallPage {
							id: callPage
							Connections {
								target: mainItem
								function onOpenNewCallRequest(){ callPage.goToNewCall()}
								function onCallCreated(){ callPage.goToCallHistory()}
								function onOpenCallHistory(){ callPage.goToCallHistory()}
								function onOpenNumPadRequest(){ callPage.openNumPadRequest()}
							}
							onCreateContactRequested: (name, address) => {
								mainItem.createContact(name, address)
							}
							Component.onCompleted: {
								magicSearchBar.numericPadPopup = callPage.numericPadPopup
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
						onAccountRemoved: {
							closeContextualMenuComponent()
							mainItem.accountRemoved()
						}
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
 
