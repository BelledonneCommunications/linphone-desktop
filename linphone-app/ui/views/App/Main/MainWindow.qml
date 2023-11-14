import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0
import ColorsList 1.0
import UtilsCpp 1.0

import 'MainWindow.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

ApplicationWindow {
	id: window
	
	property string _currentView
	property var _lockedInfo
	property SmartSearchBar mainSearchBar : (mainLoader.item ? mainLoader.item.mainSearchBar : null)
	property var notifyNewVersionInstallWhenLoaded : false
	
	// ---------------------------------------------------------------------------
	
	function lockView (info) {
		Logic.lockView(info)
	}
	
	function unlockView () {
		Logic.unlockView()
	}
	
	function setView (view, props, callback) {
		Logic.setView(view, props, callback)
	}
	
	// ---------------------------------------------------------------------------
	// Window properties.
	// ---------------------------------------------------------------------------
	
	minimumHeight: MainWindowStyle.minimumHeight
	minimumWidth: MainWindowStyle.minimumWidth
	
	title: Utils.capitalizeFirstLetter(applicationName)
	
	// ---------------------------------------------------------------------------
	
	onActiveFocusItemChanged: Logic.handleActiveFocusItemChanged(activeFocusItem)
	onClosing: Logic.handleClosing(close)
	
	// ---------------------------------------------------------------------------
	
	Connections {
		target: CoreManager
		onCoreManagerInitialized: mainLoader.active = true
        onRemoteProvisioningFailed: if(mainLoader.active) Logic.warnProvisioningFailed(window)
		onUserInitiatedVersionUpdateCheckResult: switch(result) {
													case 0 : Utils.infoDialog(window, qsTr('newVersionCheckError')); break;
													case 1 : Logic.proposeDownloadUpdate(window, version, url); break;
													case 2 : Utils.infoDialog(window, qsTr('noNewVersionAvailable')+"\n"+Qt.application.version); break;
													case 3 : if (mainLoader.active)
																Utils.infoDialog(window, qsTr('newVersionInstalled')+"\n"+Qt.application.version)
															else
																notifyNewVersionInstallWhenLoaded = true
															break;
													default : {}
												}
	}
	
	Shortcut {
		sequence: StandardKey.Close
		onActivated: window.hide()
	}
	// ---------------------------------------------------------------------------
	
	Loader {
		id: mainLoader
		
		active: false
		anchors.fill: parent
		
		onLoaded: {
                if(!CoreManager.isLastRemoteProvisioningGood()) {
                    Logic.warnProvisioningFailed(window)
                }
				if (notifyNewVersionInstallWhenLoaded) {
					notifyNewVersionInstallWhenLoaded = false
					Utils.infoDialog(window, qsTr('newVersionInstalled')+"\n"+Qt.application.version)
				}
				switch(SettingsModel.getShowDefaultPage()) {
					case 1 : window.setView('Calls'); break;
					case 2 : window.setView('Conversations'); break;
					case 3 : ContactsListModel.update(); window.setView('Contacts'); break;
					case 4 : window.setView('Conferences'); break;
				default:{}
				}
		}
		
		sourceComponent: ColumnLayout {
			// Workaround to get these properties in `MainWindow.js`.
			readonly property alias contentLoader: contentLoader
			readonly property alias mainMenu: mainMenu
			
			//readonly property alias timeline: timeline
			readonly property alias mainSearchBar: toolBar.mainSearchBar
			
			spacing: 0
			
			// -----------------------------------------------------------------------
			
			AuthenticationNotifier {
				onAuthenticationRequested: Logic.handleAuthenticationRequested(authInfo, realm, sipAddress, userId)
			}
			
			// -----------------------------------------------------------------------
			// Toolbar properties.
			// -----------------------------------------------------------------------
			
			ToolBar {
				id: toolBar
				property alias mainSearchBar : smartSearchBar
				Layout.fillWidth: true
				Layout.preferredHeight: MainWindowStyle.toolBar.height
				hoverEnabled : true
				
				background: MainWindowStyle.toolBar.background
				
				RowLayout {
					anchors {
						fill: parent
						leftMargin: MainWindowStyle.toolBar.leftMargin
						rightMargin: MainWindowStyle.toolBar.rightMargin
					}
					spacing: MainWindowStyle.toolBar.spacing
					
					Avatar {
						id: avatar
						Layout.preferredHeight: smartSearchBar.height
						Layout.preferredWidth: height
						
						presenceLevel: OwnPresenceModel.presenceStatus===Presence.Offline?Presence.White:( SettingsModel.rlsUriEnabled ? OwnPresenceModel.presenceLevel : Presence.Green)
						username: UtilsCpp.getDisplayName(AccountSettingsModel.username)
					}
					AccountStatus {
						id: accountStatus
						betterIcon:true
						Layout.preferredHeight: parent.height
						Layout.preferredWidth: MainWindowStyle.accountStatus.width
						Layout.fillWidth: false
						
						TooltipArea {
							text: UtilsCpp.toDisplayString(AccountSettingsModel.sipAddress, SettingsModel.sipDisplayMode)
							hoveringCursor: Qt.PointingHandCursor
						}
						
						onClicked:  {
							CoreManager.forceRefreshRegisters()
							Logic.manageAccounts()
						}
					}
					
					ColumnLayout {
						Layout.preferredWidth: MainWindowStyle.autoAnswerStatus.width
						visible: SettingsModel.autoAnswerStatus
						
						Icon {
							icon: SettingsModel.autoAnswerStatus
								  ? 'auto_answer_custom'
								  : ''
							iconSize: MainWindowStyle.autoAnswerStatus.iconSize
							overwriteColor: MainWindowStyle.autoAnswerStatus.text.colorModel.color
						}
						
						Text {
							clip: true
							color: MainWindowStyle.autoAnswerStatus.text.colorModel.color
							font {
								bold: true
								pointSize: MainWindowStyle.autoAnswerStatus.text.pointSize
							}
							text: qsTr('autoAnswerStatus')
							visible: SettingsModel.autoAnswerStatus
							width: parent.width
						}
					}
					
					SmartSearchBar {
						id: smartSearchBar
						
						Layout.fillWidth: true
						
						
						maxMenuHeight: MainWindowStyle.searchBox.maxHeight
						placeholderText: qsTr('mainSearchBarPlaceholder')
						tooltipText: qsTr('smartSearchBarTooltip')
						closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
						
						onAddContact: window.setView('ContactEdit', {
														 sipAddress: sipAddress
													 })
						
						onEntryClicked: {
							if (SettingsModel.contactsEnabled) {
								window.setView('ContactEdit', { sipAddress: entry.sipAddress })
							} else {
								CallsListModel.createChatRoom( '', false, [entry.sipAddress], true )
							}
						}
						
						onLaunchCall: CallsListModel.launchAudioCall(sipAddress, '')
						onLaunchChat: {
							var model = CallsListModel.launchChat( sipAddress,0 )
							if(model && model.chatRoomModel) {
								window.setView('Conversations')
							}
						}
						onLaunchSecureChat: {
							var model = CallsListModel.launchChat( sipAddress,1 )
							if(model && model.chatRoomModel) {
								window.setView('Conversations')
							}
						}
						onLaunchVideoCall: CallsListModel.launchVideoCall(sipAddress, '')
					}
					Item{
						Layout.preferredWidth: telKeypad.width - 30
												- (keypadButton.visible ? keypadButton.width : 0)
												- (newChatGroupButton.visible ? newChatGroupButton.width : 0)
												- 4 * MainWindowStyle.toolBar.spacing
					}
					ActionButton {
						id: keypadButton
						isCustom: true
						backgroundRadius: 90
						colorSet: MainWindowStyle.buttons.telKeyad
						onClicked: telKeypad.visible = !telKeypad.visible
						toggled: telKeypad.visible
					}					
					ActionButton {
						id: newChatGroupButton
						isCustom: true
						backgroundRadius: 4
						colorSet: MainWindowStyle.buttons.newChatGroup

						//: 'Start a chat room' : Tooltip to illustrate a button
						tooltipText : qsTr('newChatRoom')
						visible: (SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled)
						enabled: SettingsModel.groupChatEnabled
						onClicked: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/NewChatRoom.qml')
													   ,{})
						}
						TooltipArea{
							visible: !SettingsModel.groupChatEnabled
							maxWidth: smartSearchBar.width
							delay:0
							//: 'Conference URI is not set. You have to change it in your account settings in order to create new group chats.' : Tooltip to warn the user to change a setting to activate an action.
							text: qsTr('newChatRoomUriMissing')
						}
					}
					
					ActionButton {
						id:newConferenceButton
						isCustom: true
						backgroundRadius: 4
						colorSet: MainWindowStyle.buttons.newConference
						visible: SettingsModel.conferenceEnabled
						enabled: SettingsModel.videoConferenceEnabled
						tooltipText:qsTr('newConferenceButton')
						onClicked: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Utils.buildAppDialogUri('NewConference')
													   ,{}, function (status) {
														if( status){
															setView('Conferences')
														}
													   })
						}
						TooltipArea{
							visible: !SettingsModel.videoConferenceEnabled
							maxWidth: smartSearchBar.width
							delay:0
							//: 'Video conference URI is not set. You have to change it in your account settings in order to create new meetings.' : Tooltip to warn the user to change a setting to activate an action.
							text: qsTr('newConferenceUriMissing')
						}
					}
				}
			}

			// -----------------------------------------------------------------------
			// Content.
			// -----------------------------------------------------------------------
			
			RowLayout {
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				spacing: 0
				
				// Main menu.
				Rectangle{
					id: mainMenu
					property int currentMenu: contentLoader.source == 'qrc:/ui/views/App/Main/Home.qml' || contentLoader.source == 'qrc:/ui/views/App/Main/Assistant.qml' ? 0
											: contentLoader.source == 'qrc:/ui/views/App/Main/Calls.qml' ? 1
											: contentLoader.source == 'qrc:/ui/views/App/Main/Conversations.qml' ? 2
											: contentLoader.source == 'qrc:/ui/views/App/Main/Contacts.qml' ? 3
											: contentLoader.source == 'qrc:/ui/views/App/Main/Conferences.qml' ? 4
											: -1
					Layout.fillHeight: true
					Layout.preferredWidth: MainWindowStyle.menu.leftMargin + MainWindowStyle.menu.rightMargin + MainWindowStyle.menu.buttonSize
					color: '#F3F3F3'
					ColumnLayout {
						anchors.fill: parent	
						spacing: 2*MainWindowStyle.menu.spacing
						anchors.topMargin: MainWindowStyle.menu.spacing
						anchors.bottomMargin: MainWindowStyle.menu.spacing
						anchors.leftMargin: MainWindowStyle.menu.leftMargin
						anchors.rightMargin: MainWindowStyle.menu.rightMargin
						
						
						ActionButton {
							id: homeButton
							isCustom: true
							backgroundRadius: 4
							colorSet: MainWindowStyle.buttons.home
							//: 'Open Home' : Tooltip for a button that open the home view
							tooltipText : qsTr('openHome')
							//autoIcon: true
							toggled: mainMenu.currentMenu == 0
							onClicked: window.setView('Home')
						}
						ActionButton {
							isCustom: true
							backgroundRadius: 4
							colorSet: MainWindowStyle.buttons.callHistoryMenu
							//: 'Open call history' : Tooltip for a button that open the call history view
							tooltipText : qsTr('openCalls')
							//autoIcon: true
							toggled: mainMenu.currentMenu == 1
							onClicked: {
								window.setView('Calls')
							}
							MessageCounter {
								id: callCounter
								anchors.horizontalCenter: parent.right
								anchors.verticalCenter: parent.top
								count: AccountSettingsModel.missedCallsCount
							}
						}
						ActionButton {
							visible: SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled
							isCustom: true
							backgroundRadius: 4
							colorSet: MainWindowStyle.buttons.chatMenu
							//: 'Open chats' : Tooltip for a button that open the conversations view
							tooltipText : qsTr('openChats')
							//autoIcon: true
							toggled: mainMenu.currentMenu == 2
							onClicked: {
								onClicked: window.setView('Conversations')
							}
							MessageCounter {
								id: messageCounter
								anchors.horizontalCenter: parent.right
								anchors.verticalCenter: parent.top
								count: AccountSettingsModel.unreadMessagesCount
							}
						}
						ActionButton {
							isCustom: true
							backgroundRadius: 4
							colorSet: MainWindowStyle.buttons.contactsMenu
							//: 'Open contacts' : Tooltip for a button that open the contacts view
							tooltipText : qsTr('openContacts')
							//autoIcon: true
							toggled: mainMenu.currentMenu == 3
							onClicked: {
								ContactsListModel.update()
								window.setView('Contacts')
							}
						}
						ActionButton {
							visible: SettingsModel.conferenceEnabled
							isCustom: true
							backgroundRadius: 4
							colorSet: MainWindowStyle.buttons.meetingsMenu
							//: 'Open meetings' : Tooltip for a button that open the meetings list
							tooltipText : qsTr('openMeetings')
							//autoIcon: true
							toggled: mainMenu.currentMenu == 4
							onClicked: {
								window.setView('Conferences')
							}
						}
						Item{
							Layout.fillHeight: true
						}
						ActionButton {
							isCustom: true
							backgroundRadius: 4
							colorSet: MainWindowStyle.buttons.settingsMenu
							
							toggled: menuBar.isOpenned
							onClicked: toggled ? menuBar.close() : menuBar.open()// a bit useless as Menu will depopup on losing focus but this code is kept for giving idea
							MainWindowMenuBar {
								id: menuBar
								onDisplayRecordings: {
									setView('Recordings')
								}
							}
						}
					}
				}
				// Main content.
				Item{
					Layout.fillHeight: true
					Layout.fillWidth: true
					Loader {
						id: contentLoader
						
						objectName: '__contentLoader'
						
						anchors.fill: parent
						
						source: SettingsModel.getShowHomePage() ? 'Home.qml' : 'Assistant.qml'
						Component.onCompleted: if(accountStatus.noAccountConfigured) source= 'Assistant.qml' // default proxy = 1. Do not use this set diretly in source because of bindings that will override next setSource
					}
					TelKeypad {
						anchors.right: parent.right
						anchors.top: parent.top
						id: telKeypad
						onSendDtmf: smartSearchBar.text += dtmf
						visible: SettingsModel.showTelKeypadAutomatically
					}
				}
			}
		}
	}
	Loader{
		id: customMenuBar
		active:Qt.platform.os === 'osx'
		sourceComponent:MainWindowTopMenuBar{
			onDisplayRecordings: {
				setView('Recordings')
			}
		}
	}
	Component.onCompleted: if(Qt.platform.os === 'osx') menuBar = customMenuBar
	// ---------------------------------------------------------------------------
	// Url handlers.
	// ---------------------------------------------------------------------------
	
	Connections {
		target: UrlHandlers
		
		onSip: {
			mainSearchBar.text = sipAddress
		}
	}
	Connections{
		target: App
		onRequestFetchConfig: {
			if (AccountSettingsModel.accounts.length <= ((SettingsModel.showLocalSipAccount ? 1 : 0))) {
						window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
										flat: true,
										//: 'Do you want to download and apply configuration from this URL?' : text to confirm to fetch a specified URL
										descriptionText: '<b>'+qsTr('confirmFetchUri')
												+'</b><br/><br/>'+filePath,
										}, function (status) {
											if (status) {
												App.setFetchConfig(filePath)
											}
										})
			} else {
							window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
											   descriptionText: qsTr('remoteProvisioningWarnAccountOverwrite'),
										   }, function (confirm) {
											   if (confirm) {
													window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
															flat: true,
															//: 'Do you want to download and apply configuration from this URL?' : text to confirm to fetch a specified URL
															descriptionText: '<b>'+qsTr('confirmFetchUri')
															+'</b><br/><br/>'+filePath,
															}, function (status) {
															if (status) {
																App.setFetchConfig(filePath)
															}
														})
											   } else {
												   window.setView('Home')
											   }
											})
			}
		}
	}
}
