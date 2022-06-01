import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0
import ColorsList 1.0

import 'MainWindow.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

ApplicationWindow {
	id: window
	
	property string _currentView
	property var _lockedInfo
	property SmartSearchBar mainSearchBar : (mainLoader.item ? mainLoader.item.mainSearchBar : null)
	
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
	
	title: Utils.capitalizeFirstLetter(Qt.application.name)
	
	// ---------------------------------------------------------------------------
	
	onActiveFocusItemChanged: Logic.handleActiveFocusItemChanged(activeFocusItem)
	onClosing: Logic.handleClosing(close)
	
	// ---------------------------------------------------------------------------
	
	Connections {
		target: CoreManager
		onCoreManagerInitialized: mainLoader.active = true
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
		
		sourceComponent: ColumnLayout {
			// Workaround to get these properties in `MainWindow.js`.
			readonly property alias contactsEntry: contactsEntry
			readonly property alias conferencesEntry: conferencesEntry
			
			readonly property alias contentLoader: contentLoader
			//readonly property alias conferencesEntry: conferencesEntry
			readonly property alias menu: menu
			
			readonly property alias timeline: timeline
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
					
					ActionButton {
						icon: (leftPanel.visible?'panel_shown':'panel_hidden')
						
						//: 'Hide Timeline' : Tooltip for a button that hide the timeline
						tooltipText : (leftPanel.visible?qsTr('hideTimeline')
														  //: 'Open Timeline' : Tooltip for a button that open the timeline
														:qsTr('openTimeline'))
						iconSize: MainWindowStyle.panelButtonSize
						//autoIcon: true
						onClicked: leftPanel.visible = !leftPanel.visible
					}
					ActionButton {
						isCustom: true
						backgroundRadius: 4
						colorSet: MainWindowStyle.buttons.home
						//: 'Open Home' : Tooltip for a button that open the home view
						tooltipText : qsTr('openHome')
						//autoIcon: true
						onClicked: setView('Home')
					}
					
					AccountStatus {
						id: accountStatus
						betterIcon:true
						Layout.preferredHeight: parent.height
						Layout.preferredWidth: MainWindowStyle.accountStatus.width
						Layout.fillWidth: false
						
						TooltipArea {
							text: AccountSettingsModel.sipAddress
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
							overwriteColor: MainWindowStyle.autoAnswerStatus.text.color
						}
						
						Text {
							clip: true
							color: MainWindowStyle.autoAnswerStatus.text.color
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
						onLaunchChat: CallsListModel.launchChat( sipAddress,0 )
						onLaunchSecureChat: CallsListModel.launchChat( sipAddress,1 )
						onLaunchVideoCall: CallsListModel.launchVideoCall(sipAddress, '')
					}
					
					
					ActionButton {
						isCustom: true
						backgroundRadius: 4
						colorSet: MainWindowStyle.buttons.newChatGroup

						//: 'Start a chat room' : Tooltip to illustrate a button
						tooltipText : qsTr('newChatRoom')
						visible: SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled
						onClicked: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/NewChatRoom.qml')
													   ,{})
						}
					}
					
					ActionButton {
						isCustom: true
						backgroundRadius: 4
						colorSet: MainWindowStyle.buttons.newConference
						visible: SettingsModel.conferenceEnabled
						tooltipText:qsTr('newConferenceButton')
						onClicked: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Utils.buildAppDialogUri('NewConference')
													   ,{})
						}
					}
					
					ActionButton {
						isCustom: true
						backgroundRadius: 4
						colorSet: MainWindowStyle.buttons.burgerMenu
						visible: Qt.platform.os !== 'osx'
						
						toggled: menuBar.isOpenned
						onClicked: toggled ? menuBar.close() : menuBar.open()// a bit useless as Menu will depopup on losing focus but this code is kept for giving idea
						MainWindowMenuBar {
							id: menuBar
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
				ColumnLayout {
					id:leftPanel
					Layout.maximumWidth: MainWindowStyle.menu.width
					Layout.preferredWidth: MainWindowStyle.menu.width
					
					spacing: 0
					
					ApplicationMenu {
						id: menu
						
						defaultSelectedEntry: null
						
						entryHeight: MainWindowStyle.menu.height+10
						entryWidth: MainWindowStyle.menu.width
						
						ApplicationMenuEntry {
							id: contactsEntry
							
							icon: MainWindowStyle.menu.contacts.icon
							iconSize: MainWindowStyle.menu.contacts.iconSize
							overwriteColor: isSelected ? MainWindowStyle.menu.contacts.selectedColor : MainWindowStyle.menu.contacts.color
							name: qsTr('contactsEntry')
							visible: SettingsModel.contactsEnabled
							
							onSelected: {
								timeline.model.unselectAll()
								setView('Contacts')
							}
							onClicked:{
								setView('Contacts')
							}
							Icon{
								anchors.right:parent.right
								anchors.verticalCenter: parent.verticalCenter
								anchors.rightMargin: 10
								icon: MainWindowStyle.menu.direction.icon
								overwriteColor: contactsEntry.overwriteColor
								iconSize: MainWindowStyle.menu.direction.iconSize
								
							}
						}
						ApplicationMenuEntry {
							id: conferencesEntry
							
							icon: MainWindowStyle.menu.conferences.icon
							iconSize: MainWindowStyle.menu.conferences.iconSize
							overwriteColor: isSelected ? MainWindowStyle.menu.conferences.selectedColor : MainWindowStyle.menu.conferences.color
							//: 'Conferences' : Conference title for main window.
							name: qsTr('mainWindowConferencesTitle').toUpperCase()
							visible: SettingsModel.conferenceEnabled
							
							onSelected: {
								timeline.model.unselectAll()
								setView('Conferences')
							}
							onClicked:{
								setView('Conferences')
							}
							Icon{
								anchors.right:parent.right
								anchors.verticalCenter: parent.verticalCenter
								anchors.rightMargin: 10
								icon: MainWindowStyle.menu.direction.icon
								overwriteColor: conferencesEntry.overwriteColor
								iconSize: MainWindowStyle.menu.direction.iconSize
							}
						}
					}
					
					// History.
					Timeline {
						id: timeline
						
						Layout.fillHeight: true
						Layout.fillWidth: true
						model: TimelineProxyModel{}
						
						onEntrySelected:{
							if( entry ) {
								if( entry.selected){
									console.log("Load conversation from entry selected on timeline")
									window.setView('Conversation', {
												chatRoomModel:entry.chatRoomModel
											   })
								}
							}else{
								
								window.setView('Home', {})
							}
							menu.resetSelectedEntry()
						}
						onShowHistoryRequest: {
							timeline.model.unselectAll()
							window.setView('HistoryView')
						}
					}
				}
				
				// Main content.
				Loader {
					id: contentLoader
					
					objectName: '__contentLoader'
					
					Layout.fillHeight: true
					Layout.fillWidth: true
					
					source: 'Home.qml'
					Component.onCompleted: if (AccountSettingsModel.accounts.length < 2) source= 'Assistant.qml' // default proxy = 1. Do not use this set diretly in source because of bindings that will override next setSource
				}
			}
		}
	}
	Loader{
		id: customMenuBar
		active:Qt.platform.os === 'osx'
		sourceComponent:MainWindowTopMenuBar{}
	}
	Component.onCompleted: if(Qt.platform.os === 'osx') menuBar = customMenuBar
	// ---------------------------------------------------------------------------
	// Url handlers.
	// ---------------------------------------------------------------------------
	
	Connections {
		target: UrlHandlers
		
		onSip: {
			 window.setView('Conversation', {
								  peerAddress: sipAddress,
								  localAddress: AccountSettingsModel.sipAddress,
								  fullPeerAddress: sipAddress,
								  fullLocalAddress: AccountSettingsModel.fullSipAddress
							  })
							 }
	}
}
